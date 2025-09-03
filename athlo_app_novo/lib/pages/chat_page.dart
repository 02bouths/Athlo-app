import 'dart:io'; // ✅ necessário para File
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatPage extends StatefulWidget {
  final String nomeComunidade;

  const ChatPage({super.key, required this.nomeComunidade});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  String? _senderNameCache;

  String get communityId => _slugify(widget.nomeComunidade);

  @override
  void initState() {
    super.initState();
    _ensureSignedInAnonymously();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _ensureSignedInAnonymously() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  String _slugify(String input) {
    final s = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return s.isEmpty ? 'comunidade' : s;
  }

  Future<String> _getSenderName() async {
    if (_senderNameCache != null && _senderNameCache!.isNotEmpty) {
      return _senderNameCache!;
    }

    final user = FirebaseAuth.instance.currentUser;
    final authName = user?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) {
      _senderNameCache = authName;
      return authName;
    }

    if (user != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        final n = (data?['nome'] as String?)?.trim();
        if (n != null && n.isNotEmpty) {
          _senderNameCache = n;
          return n;
        }
      } catch (_) {}
    }

    _senderNameCache = 'Usuário';
    return 'Usuário';
  }

  Future<void> _enviarMensagem({
    String? text,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
  }) async {
    if ((text == null || text.trim().isEmpty) &&
        imageUrl == null &&
        videoUrl == null &&
        audioUrl == null) {
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      await _ensureSignedInAnonymously();
    }

    final senderName = await _getSenderName();

    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('messages')
          .add({
        'text': text,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'audioUrl': audioUrl,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e')),
      );
    }
  }

  Future<String?> _uploadFileToStorage({
    required String localPath,
    required String folder,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final fileName = localPath.split('/').last;
      final ref = _storage.ref().child(
          'communities/$communityId/$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no upload: $e')),
      );
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final url =
          await _uploadFileToStorage(localPath: picked.path, folder: 'images');
      if (url != null) {
        await _enviarMensagem(imageUrl: url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? picked = await _picker.pickVideo(
          source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
      if (picked == null) return;

      final url =
          await _uploadFileToStorage(localPath: picked.path, folder: 'videos');
      if (url != null) {
        await _enviarMensagem(videoUrl: url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar vídeo: $e')),
      );
    }
  }

  Future<void> _toggleRecord() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        setState(() => _isRecording = false);
        if (path == null) return;

        final url =
            await _uploadFileToStorage(localPath: path, folder: 'audios');
        if (url != null) {
          await _enviarMensagem(audioUrl: url);
        }
        return;
      }

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permita o microfone para gravar áudio.')),
        );
        return;
      }

      final dir = await getTemporaryDirectory();
      final savePath =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: savePath,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gravar áudio: $e')),
      );
    }
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String senderId,
    required String senderName,
    String? text,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
  }) {
    final bg = isMe ? const Color(0xFF4A4A4A) : const Color(0xFFE5E5E5);
    final fg = isMe ? Colors.white : Colors.black87;

    return GestureDetector(
      onLongPress: () {
        if (!isMe) {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Ir para o perfil'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userId: senderId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    color: fg.withAlpha((0.7 * 255).toInt()),
                  ),
                ),
              if (text != null && text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(text, style: TextStyle(color: fg)),
                ),
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (videoUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Vídeo enviado. Reprodutor ainda simples.')),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam, color: fg),
                        const SizedBox(width: 8),
                        Text('Vídeo', style: TextStyle(color: fg)),
                      ],
                    ),
                  ),
                ),
              if (audioUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _AudioBubble(
                    url: audioUrl,
                    isDark: isMe,
                    player: _player,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raposo Tavares Basquetebol',
                style: TextStyle(color: Colors.white)),
            Text('32 membros',
                style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communities')
                  .doc(communityId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(200)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar mensagens'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Seja o primeiro a enviar uma mensagem 👋'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>? ?? {};
                    final msg = (data['text'] as String?) ?? '';
                    final imageUrl = data['imageUrl'] as String?;
                    final videoUrl = data['videoUrl'] as String?;
                    final audioUrl = data['audioUrl'] as String?;
                    final senderId = data['senderId'] as String? ?? '';
                    final senderName =
                        data['senderName'] as String? ?? 'Usuário';
                    final isMe = senderId == uid;

                    return _buildMessageBubble(
                      isMe: isMe,
                      senderId: senderId,
                      senderName: senderName,
                      text: msg,
                      imageUrl: imageUrl,
                      videoUrl: videoUrl,
                      audioUrl: audioUrl,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.black),
                    onPressed: _pickImage,
                    tooltip: 'Enviar imagem',
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.black),
                    onPressed: _pickVideo,
                    tooltip: 'Enviar vídeo',
                  ),
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic,
                      color: _isRecording ? Colors.red : Colors.black,
                    ),
                    onPressed: _toggleRecord,
                    tooltip: _isRecording ? 'Parar gravação' : 'Gravar áudio',
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _controller,
                      style: const TextStyle(color: Colors.black),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarMensagem(text: _controller.text),
                      decoration: InputDecoration(
                        hintText: "Digite sua mensagem",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () => _enviarMensagem(text: _controller.text),
                    tooltip: 'Enviar',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  const _AudioBubble({
    required this.url,
    required this.isDark,
    required this.player,
  });

  final String url;
  final bool isDark;
  final AudioPlayer player;

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    widget.player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  Future<void> _toggle() async {
    if (_playing) {
      await widget.player.stop();
    } else {
      await widget.player.play(UrlSource(widget.url));
    }
    if (mounted) setState(() => _playing = !_playing);
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: _toggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: fg,
          ),
          const SizedBox(width: 8),
          Text('Áudio', style: TextStyle(color: fg)),
        ],
      ),
    );
  }
}

/// 🚀 Tela simples de Perfil (abre ao segurar msg)
class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final nome = data['nome'] ?? 'Usuário';
          final bio = data['bio'] ?? '';
          final fotoPerfil = data['fotoPerfil'] ?? '';
          final fotosGrid = List<String>.from(
              data['fotosGrid'] ?? List.generate(6, (_) => ''));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (fotoPerfil.isNotEmpty)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(fotoPerfil),
                  ),
                const SizedBox(height: 12),
                Text(nome,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(bio),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fotosGrid.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final url = fotosGrid[index];
                    if (url.isEmpty) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image, color: Colors.white),
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, fit: BoxFit.cover),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}