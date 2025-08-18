import 'package:flutter/material.dart';
import 'home_feed_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    final isAdmin = email == "ADM123" && senha == "ADM123";
    final isUser = email == RegisterPage.userEmail && senha == RegisterPage.userPassword;

    if (isAdmin || isUser) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeFeedPage()));
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Erro"),
          content: const Text("Usuário não encontrado"),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    }
  }

  void _goRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
              child: const Text("Entrar", style: TextStyle(color: Colors.white)),
            ),
            TextButton(onPressed: _goRegister, child: const Text("Criar conta"))
          ],
        ),
      ),
    );
  }
}
