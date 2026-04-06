import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StepDiscoveryAudio extends StatelessWidget {
  final String texteOriginal;
  final String traduction;
  final String lottie;

  const StepDiscoveryAudio({
    super.key,
    required this.texteOriginal,
    required this.traduction,
    required this.lottie,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_pin,
                            size: 20, color: Colors.redAccent),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "RÉPÈTE APRÈS MOI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    SizedBox(
      width: 120,
      height: 120,
      child: Lottie.asset(lottie),
    ),
    const SizedBox(width: 8),
    Flexible(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:  Colors.grey,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.volume_up,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: texteOriginal,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: -6.5, 
            top: 22,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(-45 / 360), 
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(
                      color:  Colors.grey,
                      width: 1.5,
                    ),
                    top: BorderSide(
                      color:  Colors.grey,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 0,
            top: 19,
            child: Container(
              width: 5,
              height: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ],
)
                ],
              ),
            ),
          ),
          Container(
            height: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.withOpacity(0.5), Colors.grey],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            flex: 1,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text("TRADUCTION",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          traduction,
                          style: TextStyle(
                              fontSize: 16, height: 1.6, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
