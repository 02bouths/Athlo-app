import 'package:flutter/material.dart';
import 'search_page.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();

  String? imagemSelecionada;

  final List<String> imagensPreDefinidas = [
    "https://primeiroround.com.br/wp-content/uploads/2024/10/poatan2.jpg",
    "https://i.ytimg.com/vi/yiDDwBHLolo/hqdefault.jpg",
    "https://fator01.wordpress.com/wp-content/uploads/2011/04/brucelee.jpg?w=400",
    "https://fotos.perfil.com/2020/11/27/la-camara-36-de-shaolin-1087690.jpg"
  ];

  void _criarComunidade() {
    if (_nomeController.text.trim().isEmpty || _descricaoController.text.trim().isEmpty) {
      // Mostra alerta caso não tenha preenchido campos obrigatórios
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Campos obrigatórios"),
          content: const Text("Por favor, preencha o nome e a descrição da comunidade."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    String imagemFinal = imagemSelecionada ?? _imagemController.text.trim();
    if (imagemFinal.isEmpty) {
      imagemFinal = "https://cdn-icons-png.flaticon.com/512/5110/5110286.png"; // padrão
    }

    SearchPage.comunidadesGlobais.add({
      "nome": _nomeController.text.trim(),
      "imagem": imagemFinal,
      "descricao": _descricaoController.text.trim(),
      "imagemDetalhes": imagemFinal,
      // opcionalmente, você pode adicionar "mapsUrl" ou "imagem2" depois
    });

    // Mostra mensagem de sucesso
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Cadastro da comunidade concluído!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha o alerta
              Navigator.pop(context); // volta para a tela anterior
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Comunidade", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome da Comunidade",
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: "Descrição",
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.black),
              controller: _imagemController,
              decoration: const InputDecoration(
                labelText: "URL da Imagem (opcional)",
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            const Text("Ou escolha uma imagem pré-definida:", style: TextStyle(color: Colors.black)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: imagensPreDefinidas.map((url) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      imagemSelecionada = url;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: imagemSelecionada == url ? Colors.orange : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _criarComunidade,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Criar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
