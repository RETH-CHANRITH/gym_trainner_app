import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/gender_selection_controller.dart';
import '../../../../config/glass_ui.dart';

class GenderSelectionView extends GetView<GenderSelectionController> {
  const GenderSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(
        title: 'Your Gender',
        onBack: () => controller.goBack(),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            right: -100,
            child: GlowOrb(color: kNeon, radius: 270),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: GlowOrb(color: kSky, radius: 220),
          ),
          Positioned(
            top: 280,
            left: -60,
            child: GlowOrb(color: kLilac, radius: 140),
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
                      'What is your\ngender?',
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
                    'This helps us personalise your fitness experience',
                    style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Column(
                      children: [
                        _buildOption(
                          label: 'Male',
                          value: 'male',
                          icon: Icons.male_rounded,
                        ),
                        _buildOption(
                          label: 'Female',
                          value: 'female',
                          icon: Icons.female_rounded,
                        ),
                        _buildOption(
                          label: 'Other',
                          value: 'other',
                          icon: Icons.transgender_rounded,
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

  Widget _buildOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => controller.selectGender(value),
          child: LiquidTile(
            selected: isSelected,
            accent: kNeon,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isSelected ? kNeon : Colors.white).withOpacity(
                      0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? kNeon : kMuted,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? kNeon : Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !isSelected ? Colors.white.withOpacity(0.3) : kNeon,
                      width: 2,
                    ),
                    color: isSelected ? kNeon : Colors.transparent,
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check_rounded,
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
  }
}
