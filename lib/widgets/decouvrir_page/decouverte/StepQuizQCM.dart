import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:lottie/lottie.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepQuizQCM extends StatefulWidget {
  final String question;
  final String title;
  final List<String> options;
  final String lottieQuestion; 
  final String lottieCorrect;
  final String lottieIncorrect;
  final String correctOption;

  const StepQuizQCM({
    super.key,
    required this.question,
    required this.title,
    required this.options,
    required this.lottieQuestion,
    required this.lottieCorrect,
    required this.lottieIncorrect,
    required this.correctOption,
  });

  @override
  State<StepQuizQCM> createState() => _StepQuizQCMState();
}

class _StepQuizQCMState extends State<StepQuizQCM> {
  final DiscoveryController controller = Get.find();
  int? selectedIndex;
  String? currentLottie;
  
  bool hasValidated = false;

  @override
  void initState() {
    super.initState();
    currentLottie = widget.lottieQuestion;
  }

  void _showResultBottomSheet(bool isCorrect) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    isCorrect ? "Bravo 🥳!" : "Désolé 😥!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    ),
                  ),
                ],
              ),
              if (!isCorrect) ...[
                SizedBox(height: 10),
                Text(
                  "Bonne réponse :",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFEE2B2B)),
                ),
                Text(
                  widget.correctOption,
                  style: TextStyle(fontSize: 16, color: const Color(0xFFEE2B2B)),
                ),
              ],
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.nextPage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFEE2B2B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text(
                    isCorrect ? "CONTINUER" : "D'ACCORD",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getBorderColor(int index) {
    String optionText = widget.options[index];
    bool isSelected = selectedIndex == index;

    if (!hasValidated) {
      return isSelected ? const Color(0xFF000099) : Colors.grey.shade300;
    }

    if (isSelected) {
      if (optionText == widget.correctOption) {
        return const Color(0xFF58CC02);
      }
      return const Color(0xFFEE2B2B);
    }

    if (optionText == widget.correctOption && hasValidated) {
      return const Color(0xFF58CC02);
    }

    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(widget.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black54)),
              
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: currentLottie != null 
                    ? Lottie.asset(currentLottie!, height: 140, repeat: true)
                    : SizedBox(height: 140),
              ),
              
              Padding(
<<<<<<< HEAD
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
=======
                padding: EdgeInsets.symmetric(horizontal: 20),
>>>>>>> f7a79ff9b1e1a9fb04ed679b828aaaa11fd55db5
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, color: Colors.blueAccent, size: 28),
                      SizedBox(width: 15),
                      Expanded(child: Text(widget.question, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 12, 
                    mainAxisSpacing: 12, 
                    childAspectRatio: 2.1
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: hasValidated ? null : () { 
                        setState(() {
                          selectedIndex = index;
                          currentLottie = widget.lottieQuestion;
                        });
                      },
                      child: AnimatedContainer( 
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _getBorderColor(index), 
                            width: (selectedIndex == index || (hasValidated && widget.options[index] == widget.correctOption)) ? 2.5 : 1.0,
                          ),
                        ),
                        child: Text(widget.options[index], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: selectedIndex != null && !hasValidated
                ? () {
                    bool isCorrect = widget.options[selectedIndex!] == widget.correctOption;
                    
                    setState(() {
                      hasValidated = true; 
                      currentLottie = isCorrect ? widget.lottieCorrect : widget.lottieIncorrect;
                    });
                    
                    _showResultBottomSheet(isCorrect);
                  } 
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("VALIDER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}