import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_page.dart';

class CommunityDetailPage extends StatefulWidget {
  final String? communityId;
  final String? nome;
  final String? imagem;
  final String? descricao;
  final List<String>? imagens;
  final String? mapsUrl;

  const CommunityDetailPage({
    super.key,
    this.communityId,
    this.nome,
    this.imagem,
    this.descricao,
    this.imagens,
    this.mapsUrl,
  }) : assert(
          communityId != null || nome != null,
          'Forneça communityId ou nome (ou ambos).',
        );

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  bool _joined = false;
  bool _showFullDescription = false;
  String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _checkIfJoined();
  }

  Future<void> _checkIfJoined() async {
    if (widget.communityId == null || _uid == null) return;
    final memberDoc = await FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.communityId)
        .collection('members')
        .doc(_uid)
        .get();
    if (mounted) setState(() => _joined = memberDoc.exists);
  }

    Future<void> _toggleJoinFirebase() async {
    if (widget.communityId == null || _uid == null) return;

    final communityRef =
        FirebaseFirestore.instance.collection('communities').doc(widget.communityId);
    final memberRef = communityRef.collection('members').doc(_uid);
    final userSavedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('savedCommunities')
        .doc(widget.communityId);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final commSnap = await tx.get(communityRef);
        final memberSnap = await tx.get(memberRef);

        // Se communauté não existe, abortamos (pouco provável)
        if (!commSnap.exists) {
          throw Exception('Comunidade não encontrada');
        }

        final commData = commSnap.data() as Map<String, dynamic>? ?? {};
        final commName = (commData['nome'] ?? widget.nome ?? '').toString();
        final commImage = (commData['imagem'] ?? widget.imagem ?? '').toString();
        final currentCount = (commData['memberCount'] is int) ? commData['memberCount'] as int : 0;

        if (memberSnap.exists) {
          // -> usuário já é membro: remover
          tx.delete(memberRef);
          tx.update(communityRef, {
            'memberCount': FieldValue.increment(-1),
          });

          // também removemos savedCommunities do usuário (se existir)
          tx.delete(userSavedRef);
        } else {
          // -> usuário não é membro: adicionar
          tx.set(memberRef, {
            'joinedAt': FieldValue.serverTimestamp(),
          });

          tx.update(communityRef, {
            'memberCount': FieldValue.increment(1),
          });

          // gravar doc simplificado em users/{uid}/savedCommunities/{communityId}
          tx.set(userSavedRef, {
            'communityId': widget.communityId,
            'nome': commName,
            'imagem': commImage,
            // memberCount salvo aqui é apenas informativo; a contagem "viva" deve vir do doc communities/{id}
            'memberCount': currentCount + 1,
            'joinedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Se chegou aqui, transação foi bem sucedida -> atualizar UI localmente
      // re-check para garantir estado consistente
      final memberDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('members')
          .doc(_uid)
          .get();
      if (!mounted) return;
      setState(() => _joined = memberDoc.exists);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_joined
              ? 'Você entrou na comunidade — boa conversa! 🟢'
              : 'Você saiu da comunidade.'),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao (un)join/update saved (transação): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar comunidade: ${e.toString()}')),
      );
    }
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Maps')),
      );
    }
  }

  int _parseMemberCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  List<String> _parseImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  Widget _buildHeader(String nome, String avatarUrl, int memberCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage:
                avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome.isNotEmpty ? nome : 'Comunidade',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$memberCount membros',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF35AA00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDescription(String descricao) {
    final text = descricao.trim();
    if (text.isEmpty) return const SizedBox.shrink();
    const collapsedLines = 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign: TextAlign.justify,
            maxLines: _showFullDescription ? null : collapsedLines,
            overflow:
                _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _showFullDescription = !_showFullDescription),
            child: Text(
              _showFullDescription ? 'Mostrar menos' : 'Ler mais',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesCarousel(List<String> imagens, String fallback) {
    final List<String> allImages = imagens.isNotEmpty ? imagens : [fallback];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 280,
        child: PageView.builder(
          itemCount: allImages.length,
          controller: PageController(viewportFraction: 0.85),
          itemBuilder: (context, index) {
            final img = allImages[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 240,
          height: 55,
          child: ElevatedButton(
            onPressed: _toggleJoinFirebase,
            style: ElevatedButton.styleFrom(
              backgroundColor: _joined
                  ? Colors.grey.shade400
                  : const Color(0xFFEBCC6E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _joined ? 'Inscrito' : 'Inscreva-se',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapsButton(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: 240,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _openMaps(url),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF595643),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Ver no Maps",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFromDocument(DocumentSnapshot doc) {
    final raw = doc.data();
    if (raw == null || raw is! Map<String, dynamic>) {
      return const Center(child: Text('Dados da comunidade inválidos'));
    }

    final data = Map<String, dynamic>.from(raw);
    final nome = (data['nome'] ?? '').toString();
    final imagem = (data['imagem'] ?? '').toString();
    final descricao = (data['descricao'] ?? '').toString();
    final imagensExtras = _parseImages(data['imagensExtras']);
    final memberCount = _parseMemberCount(data['memberCount']);
    final mapsUrl = data['mapsUrl']?.toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(nome, imagem, memberCount),
          _buildDescription(descricao),
          _buildImagesCarousel(imagensExtras, imagem),
          _buildSubscribeButton(),
          if (mapsUrl != null && mapsUrl.isNotEmpty) _buildMapsButton(mapsUrl),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.communityId != null
                  ? StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('communities')
                          .doc(widget.communityId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Erro ao carregar: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final doc = snapshot.data;
                        if (doc == null || !doc.exists) {
                          return const Center(
                              child: Text('Comunidade não encontrada'));
                        }
                        return _buildFromDocument(doc);
                      },
                    )
                  : const Center(child: Text('Comunidade inválida')),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
