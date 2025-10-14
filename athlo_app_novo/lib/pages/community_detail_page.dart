import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// 👉 páginas internas
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

  void _toggleJoinLocal() {
    setState(() => _joined = !_joined);
    if (_joined) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatPage(nomeComunidade: widget.nome ?? 'Comunidade'),
        ),
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

  /// 🔹 Novo layout de imagens com carrossel horizontal
  Widget _buildImagesCarousel(List<String> imagens, String fallback) {
    final List<String> allImages =
        imagens.isNotEmpty ? imagens : [fallback];

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

  Widget _buildSubscribeButtonLocal() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 240,
          height: 55,
          child: ElevatedButton(
            onPressed: _toggleJoinLocal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEBCC6E),
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

  Widget _bottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_add), label: 'Grupos'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Adicionar'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
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
          _buildSubscribeButtonLocal(),
          if (mapsUrl != null && mapsUrl.isNotEmpty) _buildMapsButton(mapsUrl),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFromProps() {
    final nome = widget.nome ?? 'Comunidade';
    final imagem = widget.imagem ?? '';
    final descricao = widget.descricao ?? '';
    final imagens = widget.imagens ?? [];
    final memberCount = 0;
    final mapsUrl = widget.mapsUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(nome, imagem, memberCount),
          _buildDescription(descricao),
          _buildImagesCarousel(imagens, imagem),
          _buildSubscribeButtonLocal(),
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
      bottomNavigationBar: _bottomNavigationBar(),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                  : _buildFromProps(),
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
