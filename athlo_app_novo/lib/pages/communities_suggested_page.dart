import 'package:flutter/material.dart';

class CommunitiesSuggestedPage extends StatefulWidget {
  const CommunitiesSuggestedPage({super.key});

  @override
  State<CommunitiesSuggestedPage> createState() => _CommunitiesSuggestedPageState();
}

class _CommunitiesSuggestedPageState extends State<CommunitiesSuggestedPage> {
  final TextEditingController _searchController = TextEditingController();

  // Mock de comunidades para fase 1
  final List<Map<String, dynamic>> _communities = [
    {
      'name': 'Raposos Tavares – Basquetebol',
      'members': 124,
      'image': 'https://picsum.photos/200?1',
    },
    {
      'name': 'Comunidade de Vôlei Zona Sul',
      'members': 87,
      'image': 'https://picsum.photos/200?2',
    },
    {
      'name': 'Corrida de Rua SP',
      'members': 230,
      'image': 'https://picsum.photos/200?3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Busque sua comunidade',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Título Comunidades Sugeridas
                const Text(
                  'Comunidades Sugeridas:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Lista de comunidades sugeridas
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _communities.length,
                  itemBuilder: (context, index) {
                    final community = _communities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CommunityCard(
                        name: community['name'],
                        members: community['members'],
                        imageUrl: community['image'],
                        onTap: () {
                          // TODO: Navegar para CommunityDetailPage passando dados reais
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Botão "Criar comunidade"
                GestureDetector(
                  onTap: () {
                    // TODO: ação para criar comunidade
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Criar comunidade',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD2691E), // laranja
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.double_arrow, color: Color(0xFFD2691E)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Seção "Minhas comunidades"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Minhas comunidades',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Comunidades ativo
        onTap: (index) {
          // TODO: navegação real entre telas
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Comunidades'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Criar'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Local'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ---------- Widget customizado: Card de comunidade preto arredondado ----------
class CommunityCard extends StatelessWidget {
  final String name;
  final int members;
  final String imageUrl;
  final VoidCallback onTap;

  const CommunityCard({
    super.key,
    required this.name,
    required this.members,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 56, height: 56, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$members membros',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2ED573), // verde
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
