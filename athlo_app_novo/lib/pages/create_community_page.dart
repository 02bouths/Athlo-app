import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  File? imagemPrincipal;
  final List<File> imagensExtras = [];
  bool _isUploading = false;

  // Selecionar imagem principal
  Future<void> _selecionarImagemPrincipal() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        setState(() => imagemPrincipal = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem principal: $e');
    }
  }

  // Selecionar até 3 imagens extras
  Future<void> _selecionarImagensExtras() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(imageQuality: 85);

      if (pickedFiles.isNotEmpty) {
        setState(() {
          imagensExtras.clear();
          imagensExtras.addAll(
            pickedFiles.take(3).map((f) => File(f.path)),
          );
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagens extras: $e');
    }
  }

  // Upload para Firebase Storage
  Future<String?> _uploadImagemParaStorage(File imagem) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('community_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imagem);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Imagem enviada: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Erro no upload: $e');
      return null;
    }
  }

  Future<void> _criarComunidade() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();

    if (nome.isEmpty || descricao.isEmpty) {
      _showDialog("Campos obrigatórios", "Preencha o nome e a descrição da comunidade.");
      return;
    }

    if (imagemPrincipal == null) {
      _showDialog("Imagem principal", "Selecione a foto principal da comunidade.");
      return;
    }

    if (imagensExtras.length < 3) {
      _showDialog("Fotos adicionais", "Adicione pelo menos 3 fotos para a comunidade.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você precisa estar logado para criar uma comunidade.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload da imagem principal
      final imagemPrincipalUrl = await _uploadImagemParaStorage(imagemPrincipal!);

      // Upload das 3 imagens extras
      List<String> imagensExtrasUrls = [];
      for (final img in imagensExtras) {
        final url = await _uploadImagemParaStorage(img);
        if (url != null) imagensExtrasUrls.add(url);
      }

      // Salvar no Firestore
      await FirebaseFirestore.instance.collection('communities').add({
        "nome": nome,
        "tipo": _tipoEsporteController.text.trim(),
        "endereco": _enderecoController.text.trim(),
        "descricao": descricao,
        "imagem": imagemPrincipalUrl ?? "",
        "imagensExtras": imagensExtrasUrls,
        "criadoEm": FieldValue.serverTimestamp(),
        "criadoPor": user.uid,
      });

      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comunidade criada com sucesso!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Erro ao criar comunidade: $e');
      setState(() => _isUploading = false);
      _showDialog("Erro", "Falha ao criar comunidade: $e");
    }
  }

  void _showDialog(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 16),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                _buildSectionTitle("Tipo de esporte:"),
                TextField(
                  controller: _tipoEsporteController,
                  decoration: const InputDecoration(
                    hintText: "Ex: Futebol, Vôlei, Basquete...",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                _buildSectionTitle("Endereço principal de prática:"),
                TextField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(
                    hintText: "Rua Exemplo, 123 - Bairro, Cidade",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                _buildSectionTitle("Descrição da comunidade:"),
                TextField(
                  controller: _descricaoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Escreva sua descrição aqui",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                _buildSectionTitle("Foto principal da comunidade:"),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selecionarImagemPrincipal,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: imagemPrincipal == null
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.black54)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(imagemPrincipal!, fit: BoxFit.cover),
                          ),
                  ),
                ),

                _buildSectionTitle("Adicione 3 fotos da comunidade:"),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selecionarImagensExtras,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imagensExtras.isEmpty
                        ? const Center(
                            child: Text(
                              "Toque para selecionar até 3 imagens",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: imagensExtras.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(imagensExtras[index],
                                    width: 100, height: 100, fit: BoxFit.cover),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _criarComunidade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A4632),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Criar comunidade", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text("Enviando imagens...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
