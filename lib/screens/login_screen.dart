import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegister = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Register' : 'Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isRegister)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter valid email'
                      : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 16),
                if (authProvider.isLoading) const CircularProgressIndicator(),
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(authProvider.error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final nav = Navigator.of(context);
                          if (_isRegister) {
                            await authProvider.register(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              _nameController.text.trim(),
                            );
                          } else {
                            await authProvider.login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          }
                          if (authProvider.error == null &&
                              authProvider.isLoggedIn) {
                            nav.pushReplacementNamed('/');
                          }
                        },
                  child: Text(_isRegister ? 'Register' : 'Login'),
                ),
                TextButton(
                  onPressed: () => setState(() => _isRegister = !_isRegister),
                  child: Text(_isRegister
                      ? 'Already have an account? Login'
                      : 'No account? Register'),
                ),
                if (!_isRegister)
                  TextButton(
                    onPressed: () async {
                      if (_emailController.text.isEmpty) {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(const SnackBar(
                            content: Text('Enter your email first')));
                        return;
                      }
                      final messenger = ScaffoldMessenger.of(context);
                      await authProvider
                          .sendPasswordReset(_emailController.text.trim());
                      messenger.showSnackBar(const SnackBar(
                          content: Text(
                              'Password reset email sent (if account exists)')));
                    },
                    child: const Text('Forgot password?'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
