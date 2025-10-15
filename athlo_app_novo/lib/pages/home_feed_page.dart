import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'community_detail_page.dart';
import 'search_page.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  final List<String> videoUrls = const [
    "https://youtube.com/shorts/b3OeMC5iKb8?si=FL5swtMhWM869MGn", // Jiu-Jitsu
    "https://youtube.com/shorts/vc2wRHYr9cc?si=VC8ayj1DkOPQZV-z", // Kung Fu
    "https://youtube.com/shorts/shNivqqCo4Y?si=9dEihEYiVre7tMcr", // Muay Thai
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          final controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(videoUrls[index]));

          Widget videoWidget = WebViewWidget(controller: controller);

          // Vídeo 1 -> Jiu-Jitsu (botão invisível central)
          if (index == 0) {
            videoWidget = Stack(
              children: [
                WebViewWidget(controller: controller),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CommunityDetailPage(
                              nome: "Jiu-Jitsu",
                              imagem:
                                  "https://i.ytimg.com/vi/yiDDwBHLolo/hqdefault.jpg",
                              descricao:
                                  "Se você gosta de artes marciais e quer aprender ou melhorar no Jiu-Jitsu, essa comunidade é para você!",
                              mapsUrl:
                                  "https://www.google.com/maps/search/?api=1&query=Academia+de+Jiu-Jitsu",
                            ),
                          ),
                        );
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            );
          }

          // Vídeo 2 -> Kung Fu (tela toda clicável)
          if (index == 1) {
            videoWidget = Stack(
              children: [
                WebViewWidget(controller: controller),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommunityDetailPage(
                            nome: "Kung Fu",
                            imagem:
                                "https://fator01.wordpress.com/wp-content/uploads/2011/04/brucelee.jpg?w=400",
                            descricao:
                                "Comunidade para praticantes e fãs de Kung Fu. Aprenda técnicas e troque experiências.",
                            imagens: [
                              "https://fotos.perfil.com/2020/11/27/la-camara-36-de-shaolin-1087690.jpg"
                            ],
                            mapsUrl:
                                "https://www.google.com/maps/search/?api=1&query=Academia+de+Kung+Fu",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Vídeo 3 -> Muay Thai (apenas clique no centro)
          if (index == 2) {
            videoWidget = Stack(
              children: [
                WebViewWidget(controller: controller),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CommunityDetailPage(
                              nome: "Muay Thai",
                              imagem:
                                  "https://lh3.googleusercontent.com/gps-cs-s/AC9h4npPOdbYg1E6i9BGQ2KhEc0qmTGcOsFe4ol87EgBO84QaJKiTkS0N-wfMTfqHkcwglQzgQMMiH8mtZq8EQUqDZCJD3JiPVoRxBOxn6YEBjrXIG_grdF0sH1QQ8kkibuUs4T2ArMn=s680-w680-h510-rw",
                              descricao:
                                  "Treinamentos, técnicas e condicionamento para Muay Thai.",
                              imagens: [
                                "https://lh3.googleusercontent.com/gps-cs-s/AC9h4npPOdbYg1E6i9BGQ2KhEc0qmTGcOsFe4ol87EgBO84QaJKiTkS0N-wfMTfqHkcwglQzgQMMiH8mtZq8EQUqDZCJD3JiPVoRxBOxn6YEBjrXIG_grdF0sH1QQ8kkibuUs4T2ArMn=s680-w680-h510-rw",
                                "https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrliA5f__lFtbNHJS44g09OHwHP2Wq3kWKGjPH06EMShaOVSaIJ9xuCmh7VXTShI8bqvzPdj8-44pD7ryaOKrBvI8gKN581Oqr4-KaRmj8_ZgiANNmfbnXRAoc_redKSwFVEkjb=s680-w680-h510-rw"
                              ],
                              mapsUrl:
                                  "https://www.google.com/maps/search/?api=1&query=Academia+de+Muay+Thai",
                            ),
                          ),
                        );
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            );
          }

          return SafeArea(child: videoWidget);
        },
      ),
    );
  }
}
