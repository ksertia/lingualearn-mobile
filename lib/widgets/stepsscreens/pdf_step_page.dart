import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// TES IMPORTS
import '../decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import '../learning_content/step_discovery_audio.dart';
import '../learning_content/step_discovery_text.dart';

void main() {
  runApp(const PdfStepPage(data: {}));
}

class PdfStepPage extends StatelessWidget {
  final dynamic data;
  const PdfStepPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: GameFlowScreen(),
    );
  }
}

class GameFlowScreen extends StatefulWidget {
  @override
  _GameFlowScreenState createState() => _GameFlowScreenState();
}

class _GameFlowScreenState extends State<GameFlowScreen> {
  final PageController controller = PageController();
  int page = 0;
  final int totalPages = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFE1F5FE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(children: [
          const SizedBox(height: 50),

          /// 📊 BARRE DE PROGRESSION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Stack(children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 12,
                width: MediaQuery.of(context).size.width *
                    ((page + 1) / totalPages),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ]),
          ),

          Expanded(
            child: PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => page = i),
              children: [

                /// 🐶 ANIMAUX
                const LearningScreen(
                    message: "Découvrons les animaux !",
                    word: "Lion",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/616/616412.png"),
                const LearningScreen(
                    message: "Le singe rigolo !",
                    word: "Singe",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/616/616429.png"),
                const LearningScreen(
                    message: "La vache fait Meuh !",
                    word: "Vache",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/1998/1998610.png"),
                const LearningScreen(
                    message: "Wouf wouf !",
                    word: "Chien",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/616/616408.png"),

                /// 🍎 FRUITS
                const LearningScreen(
                    message: "Maintenant, les fruits !",
                    word: "Pomme",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/415/415733.png"),
                const LearningScreen(
                    message: "La fraise rouge !",
                    word: "Fraise",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/590/590685.png"),
                const LearningScreen(
                    message: "La banane jaune !",
                    word: "Banane",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/2909/2909761.png"),
                const LearningScreen(
                    message: "L'ananas piquant !",
                    word: "Ananas",
                    imageUrl:
                    "https://cdn-icons-png.flaticon.com/512/2153/2153713.png"),

                /// 🎥 VIDEO
                StepDiscoveryVideo(
                  videoTitle: "OBSERVE ATTENTIVEMENT",
                  videoUrl: "assets/images/video/videos.mp4",
                  onVideoFinished: () {
                    controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease);
                  },
                ),

                /// 🎧 QUIZ AUDIO
                GameScreenAudio(data: {
                  'Ba-ga':
                  'https://cdn-icons-png.flaticon.com/512/616/616408.png',
                  'Vache':
                  'https://cdn-icons-png.flaticon.com/512/1998/1998610.png',
                  'Gbi-gré':
                  'https://cdn-icons-png.flaticon.com/512/616/616412.png',
                  'Wãm-ba':
                  'https://cdn-icons-png.flaticon.com/512/616/616429.png',
                }),

                /// 🔤 QUIZ TEXTE
                GameScreenText(data: {
                  'Pòm':
                  'https://cdn-icons-png.flaticon.com/512/415/415733.png',
                  'Frɛz':
                  'https://cdn-icons-png.flaticon.com/512/590/590685.png',
                  'Banãndé':
                  'https://cdn-icons-png.flaticon.com/512/2909/2909761.png',
                  'Anana':
                  'https://cdn-icons-png.flaticon.com/512/2153/2153713.png',
                }),

                /// 🏆 FIN
                const Center(
                  child: Text(
                    "🎉 TU AS FINI ! 🎉",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
              ],
            ),
          ),

          /// 🔘 NAVIGATION NOUVEAU DESIGN
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                if (page > 0)
                  SizedBox(
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () => controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      label: const Text("Précédent"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF8F00),
                        side: const BorderSide(color: Color(0xFFFF8F00)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  )
                else
                  const SizedBox(),

                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      if (page < totalPages - 1) {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8F00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 30),
                    ),
                    child: Row(
                      children: [
                        Text(
                          page == totalPages - 1
                              ? "FIN"
                              : "Suivant",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🎨 LEARNING SCREEN (UNE SEULE VERSION)
////////////////////////////////////////////////////////////
class LearningScreen extends StatelessWidget {
  final String word, imageUrl, message;

  const LearningScreen({
    super.key,
    required this.word,
    required this.imageUrl,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(20),
          child: DefaultTextStyle(
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            child: AnimatedTextKit(
              key: ValueKey(message),
              animatedTexts: [
                TypewriterAnimatedText(message),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ),

        const Spacer(),

        FadeInUp(
          duration: const Duration(milliseconds: 800),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Image.network(
              imageUrl,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const Spacer(),

        Column(
          children: [
            GestureDetector(
              onTap: () {
                print("Play sound: $word");
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.volume_up,
                    color: Colors.white, size: 45),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              word,
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ],
    );
  }
}