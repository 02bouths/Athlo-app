import 'package:flutter/material.dart';
import 'community_detail_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  // TROCA: "Corrida e Maratona" foi substituída por "Muay Thai" com as imagens que você enviou.
  static List<Map<String, String>> comunidadesGlobais = [
    {
      "nome": "Jiu-Jitsu",
      "imagem": "https://primeiroround.com.br/wp-content/uploads/2024/10/poatan2.jpg",
      "descricao": "Se você gosta de artes marciais e quer aprender ou melhorar no Jiu-Jitsu, essa comunidade é para você! Participe de treinos, eventos e troque experiências com outros praticantes.",
      "imagemDetalhes": "https://i.ytimg.com/vi/yiDDwBHLolo/hqdefault.jpg",
      "mapsUrl": "https://www.google.com/maps/search/?api=1&query=Academia+de+Jiu-Jitsu",
    },
    {
      "nome": "Muay Thai",
      "imagem": "https://lh3.googleusercontent.com/gps-cs-s/AC9h4npPOdbYg1E6i9BGQ2KhEc0qmTGcOsFe4ol87EgBO84QaJKiTkS0N-wfMTfqHkcwglQzgQMMiH8mtZq8EQUqDZCJD3JiPVoRxBOxn6YEBjrXIG_grdF0sH1QQ8kkibuUs4T2ArMn=s680-w680-h510-rw",
      "imagem2": "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrliA5f__lFtbNHJS44g09OHwHP2Wq3kWKGjPH06EMShaOVSaIJ9xuCmh7VXTShI8bqvzPdj8-44pD7ryaOKrBvI8gKN581Oqr4-KaRmj8_ZgiANNmfbnXRAoc_redKSwFVEkjb=s680-w680-h510-rw",
      "descricao": "Treinamentos, técnicas e condicionamento para Muay Thai.",
      "imagemDetalhes": "https://lh3.googleusercontent.com/gps-cs-s/AC9h4npPOdbYg1E6i9BGQ2KhEc0qmTGcOsFe4ol87EgBO84QaJKiTkS0N-wfMTfqHkcwglQzgQMMiH8mtZq8EQUqDZCJD3JiPVoRxBOxn6YEBjrXIG_grdF0sH1QQ8kkibuUs4T2ArMn=s680-w680-h510-rw",
      "mapsUrl": "https://www.google.com/maps/search/?api=1&query=Academia+de+Muay+Thai",
    },
    {
      "nome": "Kung Fu",
      "imagem": "https://fator01.wordpress.com/wp-content/uploads/2011/04/brucelee.jpg?w=400",
      "descricao": "Comunidade para praticantes e fãs de Kung Fu. Aprenda técnicas e troque experiências.",
      "imagemDetalhes": "https://fotos.perfil.com/2020/11/27/la-camara-36-de-shaolin-1087690.jpg",
      "mapsUrl": "https://www.google.com/maps/search/?api=1&query=Academia+de+Kung+Fu",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE37B40),
        title: const Text("Pesquisar Comunidades", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Digite o nome da comunidade",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: comunidadesGlobais.length,
                itemBuilder: (context, index) {
                  final comunidade = comunidadesGlobais[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          comunidade["imagem"]!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(comunidade["nome"]!),
                      onTap: () {
                        // monta lista de imagens para o carrossel (se houver imagem2)
                        final List<String> galeria = [
                          (comunidade["imagemDetalhes"] ?? comunidade["imagem"])!
                        ];
                        if (comunidade["imagem2"] != null && comunidade["imagem2"]!.isNotEmpty) {
                          galeria.add(comunidade["imagem2"]!);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityDetailPage(
                              nome: comunidade["nome"]!,
                              imagem: comunidade["imagemDetalhes"] ?? comunidade["imagem"]!,
                              descricao: comunidade["descricao"]!,
                              imagens: galeria,
                              mapsUrl: comunidade["mapsUrl"],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
