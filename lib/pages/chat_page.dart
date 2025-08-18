import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class ChatPage extends StatefulWidget {
  final String nomeComunidade;

  const ChatPage({super.key, required this.nomeComunidade});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  String get communityId => _slugify(widget.nomeComunidade);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _ensureSignedInAnonymously();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
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

  Future<void> _enviarMensagem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) await _ensureSignedInAnonymously();

    final senderName = (ProfilePageState.nomeGlobal.isNotEmpty)
        ? ProfilePageState.nomeGlobal
        : 'Usuário';

    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('messages')
          .add({
        'text': text,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeComunidade),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                    child: Text('Seja o primeiro a enviar uma mensagem 👋',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final msg = data['text'] as String? ?? '';
                    final senderId = data['senderId'] as String? ?? '';
                    final senderName = data['senderName'] as String? ?? 'Usuário';
                    final isMe = senderId == uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.orange[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                senderName,
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            Text(msg, style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.black),
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarMensagem(),
                      decoration: InputDecoration(
                        hintText: "Digite sua mensagem...",
                        border: const OutlineInputBorder(),
                        filled: _isFocused,
                        fillColor: _isFocused ? const Color(0xFFFFF3CD) : null,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _enviarMensagem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
