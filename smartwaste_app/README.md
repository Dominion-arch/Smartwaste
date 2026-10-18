# SmartWaste — Flutter mobile app (Supabase backend)

Native Android/iOS app for **citizens** and **drivers**. It talks to the **same Supabase
project** as the existing admin dashboard, so bins, sensors and the ESP8266 firmware
keep working untouched. **Admins keep using the web dashboard** — nothing in it was changed.

```
ESP8266 bins ──► Supabase ◄── Admin dashboard (web, unchanged)
                     ▲
                     └──────── Flutter app (citizen + driver)
```

## 1. Database (one time)

Supabase → **SQL Editor** → paste and run `supabase/mobile_app_setup.sql`.

It only *adds* `profiles`, `reports`, `pickups`, `collections` (all with row-level security,
so a user can only see their own rows). It does not modify `bins`, `readings`, `alerts`
or `sensors`.

Then, for easy testing: **Authentication → Providers → Email** → turn off
"Confirm email" (or leave it on and users must confirm via email before signing in).

## 2. Create the platform folders

```bash
cd smartwaste_app
flutter create --org com.smartwaste --project-name smartwaste_app .
flutter pub get
```
`flutter create .` adds `android/`, `ios/` etc. without touching `lib/` or `pubspec.yaml`.
If it generated `test/widget_test.dart`, delete it (it references the default counter app).

**Android only — two manifest edits** in `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- inside <manifest>, above <application> -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- inside <manifest>, e.g. below <application>…</application> — lets "Navigate" open Maps -->
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https"/>
  </intent>
</queries>
```
Without INTERNET the app works in debug but cannot reach Supabase in a release build.

## 3. Run

```bash
flutter run
```
The Supabase URL and anon key default to your project's values (same as `js/supabase.js`).
To point at another project:
```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```
Release build: `flutter build apk --release` (or `appbundle` / `ios`).

## 4. Accounts

| Role | How it's created | Where they sign in |
|------|------------------|--------------------|
| Citizen | Self-register in the app (**Create Account**) | App |
| Driver | See below | App |
| Admin | Existing `admin` account | **Web dashboard** (the app shows a "use the web dashboard" screen) |

**Creating a driver**
1. Supabase → Authentication → Users → **Add user** (email + password, tick *Auto Confirm User*).
2. In the SQL editor:
   ```sql
   select public.make_driver('driver@example.com', 'Kwame Mensah', 'TRK-01', 'Route A', 'Fiapre');
   ```
The app signs in with **email + password** (Supabase Auth), not the web app's usernames.

## 5. What maps to what

| Web portal | Flutter app |
|------------|-------------|
| `citizen/index.html` — home, report, pickup, recycling guide, eco | `lib/screens/citizen/*` |
| `driver/index.html` — stops, map, stats | `lib/screens/driver/*` |
| `js/supabase.js` (`bins` polling every 15 s) | `lib/state/bins_state.dart`, `lib/services/api.dart` |
| `js/auth.js` (localStorage) | Supabase Auth + `profiles` table |
| localStorage reports / pickups / collections | `reports` / `pickups` / `collections` tables |

Changes from the web version, on purpose:
- **Persistence:** reports, pickups, eco points and collected stops now live in Supabase, so
  they survive reinstalling and follow the user across devices (before: one browser's localStorage).
- **Eco score** is computed from the saved rows (50/report, 30/pickup), not a client-editable number.
- **Report status** is read from the database (`pending` → `review` → `resolved`); the web version faked it.
- **Driver map** is a real OpenStreetMap view with a route line (web: a canvas sketch). Each stop also has a **Navigate** button that opens Google Maps.
- The web citizen page listed point-earning actions that didn't exist (plant a tree, refer a friend…); the app only lists the two that work.

## 6. Known limitations

1. **Drivers created in the admin dashboard don't exist in Supabase.** The dashboard's Drivers
   panel stores drivers in the browser's localStorage (`js/auth.js`), which the app cannot see.
   Use the `make_driver` flow above for app drivers. (Making the dashboard create real
   Supabase users would need a small change to the dashboard — deliberately not done here.)
2. **The dashboard doesn't show citizen reports or pickups** — its Reports page is environmental
   stats and has no link to the new `reports`/`pickups` tables. View them in Supabase's Table Editor.
3. **"Collected" does not reset a bin's fill level.** It is recorded in `collections`; the fill
   reading still comes from the sensor, as before.
4. Bin data refreshes by polling every 15 s (same as the dashboard), not websockets.
5. The existing `bins`/`readings`/`alerts`/`sensors` tables use allow-all RLS policies (needed by
   the ESP8266 and the dashboard, both of which use the anon key). That is unchanged, but it means
   anyone holding the anon key can write to those tables — worth tightening before production.

## Tests
```bash
flutter test      # eco-score + driver-stop-selection logic
```
