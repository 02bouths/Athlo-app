import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_page.dart';
import 'profile_page.dart';

class CommunityDetailPage extends StatelessWidget {
  final String nome;
  final String imagem;
  final String descricao;

  // Suporte a galeria e link de mapa (opcionais)
  final List<String>? imagens;
  final String? mapsUrl;

  const CommunityDetailPage({
    super.key,
    required this.nome,
    required this.imagem,
    required this.descricao,
    this.imagens,
    this.mapsUrl,
  });



  void _entrarNaComunidade(BuildContext context) {
    if (ProfilePageState.nomeGlobal.isEmpty || ProfilePageState.idadeGlobal.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Perfil incompleto"),
          content: const Text("Você precisa preencher seu nome e idade no perfil para entrar na comunidade."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(nomeComunidade: nome),
        ),
      );
    }
  }

  Future<void> _abrirNoMaps() async {
    final String destino = mapsUrl ??
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent("$nome academia")}";
    final uri = Uri.parse(destino);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> galeria = (imagens != null && imagens!.isNotEmpty)
        ? imagens!
        : [imagem];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "32 membros",
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Carrossel horizontal de fotos
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: galeria.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      galeria[index],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Link para Google Maps (abre no navegador externo)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _abrirNoMaps,
                icon: const Icon(Icons.map, color: Colors.blue),
                label: const Text(
                  "Abrir no Google Maps",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),

            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D25C),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _entrarNaComunidade(context),
                child: const Text(
                  "Inscreva-se",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
