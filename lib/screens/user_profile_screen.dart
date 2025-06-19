import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _newEmailController;
  bool _editing = false;
  bool _editingEmail = false;
  bool _editingPassword = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AuthProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile?['name'] ?? '');
    _emailController = TextEditingController(text: profile?['email'] ?? '');
    _passwordController = TextEditingController();
    _newEmailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('No user profile found.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: _editing,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: false, // Email editing not allowed for now
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              if (_editingEmail) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newEmailController,
                  decoration: const InputDecoration(labelText: 'New Email'),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter valid email'
                      : null,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _saving = true);
                          try {
                            await authProvider._client.auth.updateUser(
                              UserAttributes(
                                  email: _newEmailController.text.trim()),
                            );
                            await authProvider.fetchProfile();
                            setState(() {
                              _editingEmail = false;
                              _saving = false;
                              _error = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Email update requested. Check your inbox.')));
                          } catch (e) {
                            setState(() {
                              _saving = false;
                              _error = e.toString();
                            });
                          }
                        },
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save Email'),
                ),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() => _editingEmail = false),
                  child: const Text('Cancel'),
                ),
              ],
              if (_editingPassword) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _saving = true);
                          try {
                            await authProvider._client.auth.updateUser(
                              UserAttributes(
                                  password: _passwordController.text.trim()),
                            );
                            setState(() {
                              _editingPassword = false;
                              _saving = false;
                              _error = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Password updated.')));
                          } catch (e) {
                            setState(() {
                              _saving = false;
                              _error = e.toString();
                            });
                          }
                        },
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save Password'),
                ),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() => _editingPassword = false),
                  child: const Text('Cancel'),
                ),
              ],
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (!_editing && !_editingEmail && !_editingPassword) ...[
                ElevatedButton(
                  onPressed: () => setState(() => _editing = true),
                  child: const Text('Edit'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _editingEmail = true),
                  child: const Text('Change Email'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => _editingPassword = true),
                  child: const Text('Change Password'),
                ),
              ],
              const SizedBox(height: 24),
              if (profile['is_admin'] == true)
                const Text('Role: Admin', style: TextStyle(color: Colors.blue)),
              if (profile['is_admin'] != true)
                const Text('Role: User', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
