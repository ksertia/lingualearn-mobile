import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EnterPhonenumberPagge extends StatefulWidget {
  const EnterPhonenumberPagge({super.key});

  @override
  State<EnterPhonenumberPagge> createState() => _EnterPhonenumberPaggeState();
}

class _EnterPhonenumberPaggeState extends State<EnterPhonenumberPagge> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 40),
              Align(
                child:Image.asset(
                  "assets/images/logo/login.png",
                  height: 150,
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                "Veuillez saisir le numéro utilisé ayant servi à la création de votre compte",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: 50),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 8),
                  child: Text(
                    "Numéro de téléphone",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Veuillez entrer votre numéro de téléphone",
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 70),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offNamed("/otpCode");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 0, 153),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text(
                      'Envoyer code',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "se souvient du mot de passe?",
              style: TextStyle(color: Colors.black),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/login'),
              child: Text(
                "Se connecter",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 153),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}