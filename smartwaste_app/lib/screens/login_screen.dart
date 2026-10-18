import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../state/auth_controller.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _obscure = true;
  String _zone = AppConfig.zones.first;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _password.text;
    final name = _name.text.trim();

    if (email.isEmpty || pass.isEmpty || (_register && name.isEmpty)) {
      setState(() { _error = 'Please fill in all fields.'; _info = null; });
      return;
    }
    if (_register && pass.length < 6) {
      setState(() { _error = 'Password must be at least 6 characters.'; _info = null; });
      return;
    }

    setState(() { _busy = true; _error = null; _info = null; });
    final auth = context.read<AuthController>();

    if (_register) {
      final (err, needsConfirm) =
          await auth.signUp(name: name, email: email, zone: _zone, password: pass);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = err;
        if (err == null && needsConfirm) {
          _info = 'Account created. Check your email to confirm it, then sign in.';
          _register = false;
        }
      });
    } else {
      final err = await auth.signIn(email, pass);
      if (!mounted) return;
      setState(() { _busy = false; _error = err; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Center(child: Text('♻️', style: TextStyle(fontSize: 44))),
                const SizedBox(height: 8),
                const Center(child: Logo(color: C.accent, size: 30)),
                const SizedBox(height: 6),
                Center(child: Text('AI-powered waste management', style: mono(size: 11))),
                const SizedBox(height: 28),
                Row(children: [
                  Expanded(child: _tab('Sign In', !_register, () => setState(() { _register = false; _error = null; }))),
                  const SizedBox(width: 8),
                  Expanded(child: _tab('Create Account', _register, () => setState(() { _register = true; _error = null; _info = null; }))),
                ]),
                const SizedBox(height: 18),
                if (_register) ...[
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'FULL NAME'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'EMAIL'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  onSubmitted: (_) => _busy ? null : _submit(),
                  decoration: InputDecoration(
                    labelText: 'PASSWORD',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: C.text3, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (_register) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _zone,
                    dropdownColor: C.surface2,
                    decoration: const InputDecoration(labelText: 'YOUR ZONE'),
                    items: AppConfig.zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                    onChanged: (v) => setState(() => _zone = v ?? _zone),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: const TextStyle(color: C.danger, fontSize: 12)),
                ],
                if (_info != null) ...[
                  const SizedBox(height: 14),
                  Text(_info!, style: const TextStyle(color: C.accent, fontSize: 12)),
                ],
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_register ? 'Create Citizen Account' : 'Sign In'),
                ),
                const SizedBox(height: 18),
                Text(
                  _register
                      ? 'Citizen accounts only. Driver accounts are created by your administrator.'
                      : 'Drivers: use the account your administrator created for you.',
                  textAlign: TextAlign.center,
                  style: mono(size: 10),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? C.accent.withValues(alpha: 0.12) : C.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? C.accent : C.border2),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: active ? C.accent : C.text2)),
        ),
      );
}
