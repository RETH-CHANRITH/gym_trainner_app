import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../../config/glass_ui.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  // ─── Design Tokens (matching home_view) ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'Welcome Back', onBack: () => Get.back()),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -100,
            child: GlowOrb(color: kNeon, radius: 280),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(color: kLilac, radius: 240),
          ),
          Positioned(
            top: 340,
            right: -50,
            child: GlowOrb(color: kSky, radius: 140),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glass logo icon
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: glassDecoration(
                            radius: 24,
                            glowColor: kNeon,
                          ),
                          child: ShaderMask(
                            shaderCallback:
                                (b) => const LinearGradient(
                                  colors: [Colors.white, kNeon],
                                ).createShader(b),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Title
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [Colors.white, kNeon],
                        ).createShader(b),
                    child: Text(
                      'Welcome\nBack',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 46,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to your account',
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Email
                  Text(
                    'Email Address',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: TextField(
                        controller: controller.emailController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: glassFieldDecoration(
                          hint: 'Enter your email',
                          icon: CupertinoIcons.mail,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Password
                  Text(
                    'Password',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: TextField(
                        controller: controller.passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: glassFieldDecoration(
                          hint: 'Enter your password',
                          icon: CupertinoIcons.lock,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.dmSans(
                          color: kNeon.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login CTA
                  neonButton(
                    label: 'Login',
                    onPressed: controller.login,
                    child: Obx(
                      () =>
                          controller.isLoading.value
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: kInk,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : Text(
                                'Login',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: kInk,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // OR divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: GoogleFonts.dmSans(
                            color: kMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.white.withOpacity(0.1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Google sign-in
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.30),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: controller.signInWithGoogle,
                          child: Obx(
                            () =>
                                controller.isGoogleLoading.value
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: kNeon,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/google_logo.svg',
                                          width: 22,
                                          height: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Continue with Google',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Sign-up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.dmSans(
                            color: kMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.SIGN_UP),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.dmSans(
                              color: kNeon,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
