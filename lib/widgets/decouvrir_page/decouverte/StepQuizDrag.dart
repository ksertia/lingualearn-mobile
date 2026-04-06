import 'package:confetti/confetti.dart';
import 'package:fasolingo/widgets/decouvrir_page/and_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepQuizDrag extends StatefulWidget {
  final List<Map<String, String>> choix;
  final String title;

  const StepQuizDrag({
    super.key,
    required this.choix,
    required this.title,

  });

  @override
  State<StepQuizDrag> createState() => _StepQuizDragState();
}

class _StepQuizDragState extends State<StepQuizDrag>
    with TickerProviderStateMixin {
  final DiscoveryController controller = Get.find();
  late ConfettiController _confettiController;

  int _indexMotActuel = 0;
  String? _erreurSurNom;
  final Set<String> _motsTrouves = {};
  bool _jeuTermine = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_jeuTermine) {
      _confettiController.play();
      return StepSuccess(confettiController: _confettiController);
    }

    final currentItem = widget.choix[_indexMotActuel];
    String motATirerFr = currentItem['traduction']!;

    return Column(
      children: [
        SizedBox(height: 10.h),
        Text(
          widget.title,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black87),
        ),
        SizedBox(height: 20.h),

        _buildRow(0, 2, motATirerFr),

        Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h),
          child: Draggable<String>(
            data: motATirerFr,
            feedback: _buildToken(motATirerFr, isFloating: true),
            childWhenDragging:
                Opacity(opacity: 0.2, child: _buildToken(motATirerFr)),
            child: _buildToken(motATirerFr),
          ),
        ),

        _buildRow(2, 4, motATirerFr),
      ],
    );
  }

  Widget _buildRow(int start, int end, String motATirerFr) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: widget.choix.sublist(start, end).map((item) {
          String nomMoore = item['nom']!;
          String traductionFr = item['traduction']!;

          bool estDejaTrouve = _motsTrouves.contains(nomMoore);
          bool estMauvais = _erreurSurNom == nomMoore;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: DragTarget<String>(
                onWillAcceptWithDetails: (details) => !estDejaTrouve,
                onAcceptWithDetails: (details) {
                  if (details.data == traductionFr) {
                    _validerCase(nomMoore);
                  } else {
                    _notifierErreur(nomMoore);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 170.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: estDejaTrouve
                            ? const Color(0xFF58CC02)
                            : (estMauvais
                                ? Colors.red
                                : Colors.grey.shade300),
                        width: (estDejaTrouve || estMauvais) ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15.r)),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                            nomMoore,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: estDejaTrouve
                                  ? const Color(0xFF58CC02)
                                  : (estMauvais
                                      ? Colors.red
                                      : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _validerCase(String nom) {
    setState(() {
      _motsTrouves.add(nom);
      if (_indexMotActuel < widget.choix.length - 1) {
        _indexMotActuel++;
      } else {
        _jeuTermine = true;
      }
    });
  }

  void _notifierErreur(String nom) {
    setState(() => _erreurSurNom = nom);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _erreurSurNom = null);
    });
  }

  Widget _buildToken(String text, {bool isFloating = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            if (isFloating)
              const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_up, 
            color: Colors.blueAccent,
            size: 28,),
            SizedBox(width: 10.w),
            Text(
              text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

