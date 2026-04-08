import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepQuizSelectionImages extends StatefulWidget {
  final List<Map<String, String>> choix;
  final VoidCallback onFinished;

  const StepQuizSelectionImages({
    super.key,
    required this.choix,
    required this.onFinished,
  });

  @override
  State<StepQuizSelectionImages> createState() => _StepQuizSelectionImagesState();
}

class _StepQuizSelectionImagesState extends State<StepQuizSelectionImages> {
  final List<int> _sequenceQuestions = [0, 1]; // Index 0 puis 1
  int _etapeActuelle = 0;
  String? _erreurSurNom;
  final Set<String> _motsTrouves = {};
  bool _isProcessing = false; // Empêche le multi-clic pendant le délai

  void _verifierSelection(Map<String, String> itemClique) {
    if (_isProcessing) return;

    int indexCible = _sequenceQuestions[_etapeActuelle];
    String traductionCible = widget.choix[indexCible]['traduction']!;

    if (itemClique['traduction'] == traductionCible) {
      setState(() {
        _isProcessing = true;
        _motsTrouves.add(itemClique['nom']!);
      });

      // Feedback visuel avant action
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          if (_etapeActuelle < _sequenceQuestions.length - 1) {
            setState(() {
              _etapeActuelle++;
              _erreurSurNom = null;
              _isProcessing = false;
            });
          } else {
            // DEUXIÈME RÉPONSE TROUVÉE -> Appel de la fonction de fin
            widget.onFinished();
          }
        }
      });
    } else {
      setState(() => _erreurSurNom = itemClique['nom']);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _erreurSurNom = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String motATrouver = widget.choix[_sequenceQuestions[_etapeActuelle]]['traduction']!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            "OÙ SE TROUVE :",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFFF8F00), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8F00).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              motATrouver.toUpperCase(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF8F00),
              ),
            ),
          ),
          SizedBox(height: 40.h),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 1.0,
              ),
              itemCount: widget.choix.length,
              itemBuilder: (context, index) {
                final item = widget.choix[index];
                bool estCorrect = _motsTrouves.contains(item['nom']) && item['traduction'] == motATrouver;
                bool estFaux = _erreurSurNom == item['nom'];

                return GestureDetector(
                  onTap: () => _verifierSelection(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: estCorrect
                            ? const Color(0xFF58CC02)
                            : (estFaux ? Colors.red : Colors.grey.shade200),
                        width: (estCorrect || estFaux) ? 4 : 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.r),
                      child: Image.asset(item['image']!, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 30.h), // Espace en bas puisque les boutons sont supprimés
        ],
      ),
    );
  }
}