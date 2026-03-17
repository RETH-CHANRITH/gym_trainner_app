import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/welcome_controller.dart';

// ─── Design Tokens (matching home_view) ────────────────────────────────────────
const Color ink = Color(0xFF0A0A0F);
const Color surface = Color(0xFF111118);
const Color card = Color(0xFF17171F);
const Color raised = Color(0xFF1E1E28);
const Color stroke = Color(0xFF2A2A36);
const Color neon = Color(0xFFCBFF47);
const Color coral = Color(0xFFFF5C5C);
const Color sky = Color(0xFF5CE8FF);
const Color lilac = Color(0xFFA78BFA);
const Color muted = Color(0xFF6B6B7E);

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with logo/welcome text
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: neon.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/image/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'to Your Fitness Journey',
                    style: TextStyle(fontSize: 18, color: muted),
                  ),
                ],
              ),
            ),

            // Middle section with welcome message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: stroke),
                ),
                child: Text(
                  'Get ready to transform your body and achieve your fitness goals with professional trainers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
              ),
            ),

            // Bottom section with button
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0, left: 30, right: 30),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => controller.goToGetStarted(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
