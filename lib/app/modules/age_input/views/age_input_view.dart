import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/age_input_controller.dart';
import '../../../../config/glass_ui.dart';

class AgeInputView extends GetView<AgeInputController> {
  const AgeInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(title: 'Your Age', onBack: () => controller.goBack()),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -100,
            child: GlowOrb(color: kNeon, radius: 270),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(color: kLilac, radius: 230),
          ),
          Positioned(
            top: 300,
            right: -40,
            child: GlowOrb(color: kSky, radius: 130),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [Colors.white, kNeon],
                        ).createShader(b),
                    child: Text(
                      'How old\nare you?',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Helps us create age-appropriate workouts',
                    style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback:
                              (b) => const LinearGradient(
                                colors: [Colors.white, kNeon],
                              ).createShader(b),
                          child: Obx(
                            () => Text(
                              '${controller.age.value ?? 20}',
                              style: const TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'years old',
                          style: GoogleFonts.dmSans(
                            color: kMuted,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: kNeon,
                            inactiveTrackColor: Colors.white.withOpacity(0.10),
                            thumbColor: kNeon,
                            overlayColor: kNeon.withOpacity(0.15),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                            ),
                          ),
                          child: Obx(
                            () => Slider(
                              value: (controller.age.value ?? 20).toDouble(),
                              min: 13,
                              max: 100,
                              divisions: 87,
                              onChanged: (v) => controller.setAge(v.toInt()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        LiquidTile(
                          padding: EdgeInsets.zero,
                          child: TextField(
                            controller: controller.ageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) controller.setAge(n);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Or type here',
                              hintStyle: TextStyle(color: kMuted),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  neonButton(
                    label: 'Continue',
                    onPressed: () => controller.nextStep(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
