-- ============================================================
-- SmartWaste mobile app — Supabase setup
-- Run ONCE in Supabase → SQL Editor, AFTER the original
-- bins / readings / alerts / sensors tables from the
-- dashboard README already exist.
--
-- This script only ADDS tables. It does not touch bins,
-- readings, alerts or sensors, so the admin dashboard and the
-- ESP8266 firmware keep working exactly as before.
-- ============================================================

-- ── 1. Profiles (one row per Supabase Auth user) ─────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text,
  name        text not null default '',
  role        text not null default 'citizen'
              check (role in ('admin','driver','citizen')),
  zone        text not null default '',
  truck_id    text not null default '',
  route       text not null default '',
  created_at  timestamptz not null default now()
);
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- Users may only ever change name + zone. Role/truck/route are
-- admin-controlled, so a citizen can't promote themselves.
revoke update on public.profiles from authenticated;
grant  update (name, zone) on public.profiles to authenticated;

-- Auto-create a profile on sign-up. Role is ALWAYS 'citizen' here —
-- it is never read from client-supplied metadata.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, name, zone, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.raw_user_meta_data->>'zone', ''),
    'citizen'
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Helper used by RLS (security definer avoids policy recursion)
create or replace function public.is_driver()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'driver');
$$;

-- ── 2. Citizen reports ───────────────────────────────────────
create table if not exists public.reports (
  id          bigserial primary key,
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  type        text not null,
  zone        text not null default '',
  description text not null default '',
  urgency     text not null default 'medium' check (urgency in ('low','medium','high')),
  status      text not null default 'pending' check (status in ('pending','review','resolved')),
  created_at  timestamptz not null default now()
);
alter table public.reports enable row level security;

drop policy if exists "reports_select_own" on public.reports;
create policy "reports_select_own" on public.reports
  for select to authenticated using (user_id = auth.uid());
drop policy if exists "reports_insert_own" on public.reports;
create policy "reports_insert_own" on public.reports
  for insert to authenticated with check (user_id = auth.uid());

-- ── 3. Citizen pickups ───────────────────────────────────────
create table if not exists public.pickups (
  id          bigserial primary key,
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  waste_type  text not null,
  pickup_date date not null,
  time_slot   text not null default 'Any time',
  notes       text not null default '',
  status      text not null default 'scheduled' check (status in ('scheduled','completed','cancelled')),
  created_at  timestamptz not null default now()
);
alter table public.pickups enable row level security;

drop policy if exists "pickups_select_own" on public.pickups;
create policy "pickups_select_own" on public.pickups
  for select to authenticated using (user_id = auth.uid());
drop policy if exists "pickups_insert_own" on public.pickups;
create policy "pickups_insert_own" on public.pickups
  for insert to authenticated with check (user_id = auth.uid());

-- ── 4. Driver collections ────────────────────────────────────
create table if not exists public.collections (
  id           bigserial primary key,
  bin_id       text not null,
  driver_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  collected_at timestamptz not null default now()
);
create index if not exists collections_driver_time on public.collections (driver_id, collected_at desc);
alter table public.collections enable row level security;

drop policy if exists "collections_select_own" on public.collections;
create policy "collections_select_own" on public.collections
  for select to authenticated using (driver_id = auth.uid());
drop policy if exists "collections_insert_driver" on public.collections;
create policy "collections_insert_driver" on public.collections
  for insert to authenticated with check (driver_id = auth.uid() and public.is_driver());

-- ── 5. Creating drivers ──────────────────────────────────────
-- Step A: Supabase → Authentication → Users → "Add user"
--         (tick "Auto Confirm User"), using the driver's email + a password.
-- Step B: run the function below in the SQL editor:
--
--   select public.make_driver('driver@example.com', 'Kwame Mensah', 'TRK-01', 'Route A', 'Fiapre');
--
create or replace function public.make_driver(
  p_email text, p_name text, p_truck text, p_route text, p_zone text
) returns void language plpgsql security definer set search_path = public as $$
begin
  update public.profiles
     set role = 'driver', name = p_name, truck_id = p_truck, route = p_route, zone = p_zone
   where lower(email) = lower(p_email);
  if not found then
    raise exception 'No user with email % — create it under Authentication → Users first.', p_email;
  end if;
end $$;

-- Only the SQL editor (postgres role) may call it — never the app.
revoke all on function public.make_driver(text,text,text,text,text) from public, anon, authenticated;
