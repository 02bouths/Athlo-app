import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  // armazenamento simples (apenas enquanto o app está aberto)
  static String? userEmail;
  static String? userPassword;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _apelidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _registrar() {
    RegisterPage.userEmail = _emailController.text.trim();
    RegisterPage.userPassword = _senhaController.text.trim();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cadastro realizado! Faça login.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF655643),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Cadastre-se",
                style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _apelidoController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Digite seu apelido',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: 'Digite seu email',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: 'Digite sua senha',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE37B40)),
              onPressed: _registrar,
              child: const Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
