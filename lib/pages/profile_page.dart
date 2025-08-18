import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  static String nomeGlobal = "";
  static String idadeGlobal = "";
  static String fotoPerfil =
      "https://cdn-icons-png.flaticon.com/512/1077/1077114.png"; // foto padrão branca

  bool salvo = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();

  void _selecionarFoto() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Escolha sua foto", style: TextStyle(color: Color(0xFF6A1B9A))),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  fotoPerfil =
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaH4PPW5arjBr8xai0OremoV_w2ZSPH6622Q&s"; // Foto 1
                });
                Navigator.pop(context);
              },
              child: const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaH4PPW5arjBr8xai0OremoV_w2ZSPH6622Q&s"),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  fotoPerfil =
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1UQ_FN2DhS4J3DDxoCfzy9QF6KdS9DubXUA&s"; // Foto 2
                });
                Navigator.pop(context);
              },
              child: const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1UQ_FN2DhS4J3DDxoCfzy9QF6KdS9DubXUA&s"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarPerfil() {
    setState(() {
      nomeGlobal = _nomeController.text;
      idadeGlobal = _idadeController.text;
      salvo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF6A1B9A)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!salvo) ...[
              GestureDetector(
                onTap: _selecionarFoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(fotoPerfil),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.black),
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.black),
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: "Idade",
                  labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarPerfil,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
                child: const Text("Salvar", style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              GestureDetector(
                onTap: _selecionarFoto,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(fotoPerfil),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nomeGlobal,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text("Idade: $idadeGlobal", style: const TextStyle(color: Colors.black)),
            ]
          ],
        ),
      ),
    );
  }
}
