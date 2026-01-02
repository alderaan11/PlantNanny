import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth/auth_notifier.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authNotifierProvider.notifier).signUp(_emailController.text.trim(), _passwordController.text);
      Navigator.of(context).pop(); // back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inscription échouée: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v == null || v.isEmpty) ? 'Email requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6) ? 'Mot de passe min 6 caractères' : null,
            ),
            const SizedBox(height: 24),
            auth.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Text('S\'inscrire'))),
          ]),
        ),
      ),
    );
  }
}
