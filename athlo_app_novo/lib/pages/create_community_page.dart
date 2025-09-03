import 'package:flutter/material.dart';
import 'search_page.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _tipoEsporteController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
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
      imagemFinal = "https://cdn-icons-png.flaticon.com/512/5110/5110286.png";
    }

    SearchPage.comunidadesGlobais.add({
      "nome": _nomeController.text.trim(),
      "tipo": _tipoEsporteController.text.trim(),
      "endereco": _enderecoController.text.trim(),
      "imagem": imagemFinal,
      "descricao": _descricaoController.text.trim(),
      "imagemDetalhes": imagemFinal,
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Cadastro da comunidade concluído!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Nome da comunidade:"),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                hintText: "Comunidade de ...",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),

            _buildSectionTitle("Qual o tipo de esporte:"),
            TextField(
              controller: _tipoEsporteController,
              decoration: const InputDecoration(
                hintText: "Escreva seu esporte aqui",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),

            _buildSectionTitle("Escreva o principal endereço de prática:"),
            TextField(
              controller: _enderecoController,
              decoration: const InputDecoration(
                hintText: "Ex: Rua Exemplo, 123 - Bairro, Cidade",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),

            _buildSectionTitle("Adicione uma descrição para sua comunidade:"),
            TextField(
              controller: _descricaoController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Escreva sua descrição aqui",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(color: Colors.black),
            ),

            _buildSectionTitle("Selecione a foto da comunidade"),
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
                        color: imagemSelecionada == url ? Colors.amber : Colors.black54,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            const Text(
              "(Essa foto não poderá ser alterada posteriormente)",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),

            _buildSectionTitle("Selecione as fotos de apresentação da comunidade"),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                ),
                child: const Icon(Icons.add, size: 40, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "(Essa foto não poderá ser alterada posteriormente)",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _criarComunidade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A4632),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Criar comunidade",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
