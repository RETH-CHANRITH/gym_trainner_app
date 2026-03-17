import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/fitness_goal_controller.dart';
import '../../../../config/glass_ui.dart';

// ─── Design Tokens (matching home_view) ────────────────────────────────────
class FitnessGoalView extends GetView<FitnessGoalController> {
  const FitnessGoalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(
        title: 'Fitness Goal',
        onBack: () => controller.goBack(),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -100,
            child: GlowOrb(color: kLilac, radius: 280),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(color: kPink, radius: 230),
          ),
          Positioned(
            top: 310,
            right: -50,
            child: GlowOrb(color: kNeon, radius: 140),
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
                          colors: [kLilac, kPink],
                        ).createShader(b),
                    child: Text(
                      'What is your\nfitness goal?',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the goal that matters most to you',
                    style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.goals.length,
                      itemBuilder: (context, index) {
                        final goal = controller.goals[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedGoal.value == goal['id'];
                          return GestureDetector(
                            onTap:
                                () =>
                                    controller.selectGoal(goal['id'] as String),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LiquidTile(
                                selected: isSelected,
                                accent: kLilac,
                                child: Row(
                                  children: [
                                    Text(
                                      goal['icon'] as String,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        goal['label'] as String,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? kLilac
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? kLilac : kMuted,
                                          width: 2,
                                        ),
                                        color:
                                            isSelected
                                                ? kLilac
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
                    accent: kLilac,
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
