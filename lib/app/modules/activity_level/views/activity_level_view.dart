import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/activity_level_controller.dart';
import '../../../../config/glass_ui.dart';

// ─── Design Tokens (matching home_view) ────────────────────────────────────
class ActivityLevelView extends GetView<ActivityLevelController> {
  const ActivityLevelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(
        title: 'Activity Level',
        onBack: () => controller.goBack(),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -100,
            child: GlowOrb(color: kCoral, radius: 280),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(color: kNeon, radius: 230),
          ),
          Positioned(
            top: 310,
            left: -50,
            child: GlowOrb(color: kSky, radius: 140),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [kCoral, kNeon],
                        ).createShader(b),
                    child: Text(
                      'What is your\nactivity level?',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This helps us understand your lifestyle',
                    style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.levels.length,
                      itemBuilder: (context, index) {
                        final level = controller.levels[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedLevel.value == level['id'];
                          return GestureDetector(
                            onTap:
                                () => controller.selectLevel(
                                  level['id'] as String,
                                ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LiquidTile(
                                selected: isSelected,
                                accent: kCoral,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            level['label'] as String,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isSelected
                                                      ? kCoral
                                                      : Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            level['description'] as String,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: kMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? kCoral : kMuted,
                                          width: 2,
                                        ),
                                        color:
                                            isSelected
                                                ? kCoral
                                                : Colors.transparent,
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: kInk,
                                                size: 14,
                                              )
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  neonButton(
                    label: 'Continue',
                    accent: kCoral,
                    onPressed: () => controller.nextStep(),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
