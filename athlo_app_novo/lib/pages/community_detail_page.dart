import 'package:flutter/material.dart';
import 'chat_page.dart';

class CommunityDetailPage extends StatelessWidget {
  final String nome;
  final String imagem;
  final String descricao;
  final List<String>? imagens;
  final String? mapsUrl;

  const CommunityDetailPage({
    super.key,
    required this.nome,
    required this.imagem,
    required this.descricao,
    this.imagens,
    this.mapsUrl,
  }); // ✅ corrigido super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nome)),
      body: Column(
        children: [
          Image.network(imagem),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(descricao),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage(nomeComunidade: nome)),
              );
            },
            child: const Text("Entrar no chat da comunidade"),
          ),
        ],
      ),
    );
  }
}
