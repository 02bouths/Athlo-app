import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommunityAdminPage extends StatefulWidget {
  final String communityName;
  final String communityId;

  const CommunityAdminPage({
    super.key,
    required this.communityName,
    required this.communityId,
  });

  @override
  State<CommunityAdminPage> createState() => _CommunityAdminPageState();
}

class _CommunityAdminPageState extends State<CommunityAdminPage> {
  int _memberCount = 0;
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  Future<void> _loadCommunityData() async {
    // Simula uma chamada ao Firestore
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _members = [
        {'name': 'Daniel', 'role': 'Admin'},
        {'name': 'Julia', 'role': 'Membro'},
        {'name': 'Carlos', 'role': 'Membro'},
      ];
      _memberCount = _members.length;
      _isLoading = false;
    });
  }

  void _showAddMemberDialog() {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Membro'),
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email do novo membro',
            prefixIcon: Icon(LucideIcons.mail),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aqui você integraria com o Firestore
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Convite enviado com sucesso')),
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _removeMember(String name) {
    setState(() {
      _members.removeWhere((m) => m['name'] == name);
      _memberCount = _members.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name removido da comunidade')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: _showAddMemberDialog,
            tooltip: 'Adicionar Membro',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCommunityData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildMemberList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.communityName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_memberCount membros',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(Icons.people_outline, 'Membros', _memberCount),
                _buildStatCard(Icons.post_add_outlined, 'Postagens', 14),
                _buildStatCard(Icons.bar_chart_outlined, 'Engajamento', 85),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, int value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 30),
        const SizedBox(height: 6),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildMemberList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(LucideIcons.users),
            title: Text(
              'Membros da Comunidade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 0),
          ..._members.map((member) {
            return ListTile(
              leading: CircleAvatar(
                child: Text(member['name'][0]),
              ),
              title: Text(member['name']),
              subtitle: Text(member['role']),
              trailing: member['role'] == 'Admin'
                  ? const Icon(Icons.shield, color: Colors.blue)
                  : IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.red),
                      onPressed: () => _removeMember(member['name']),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
