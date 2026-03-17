import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/profile_summary_controller.dart';
import '../../../../config/glass_ui.dart';

// ─── Design Tokens (matching home_view) ────────────────────────────────────────
class ProfileSummaryView extends GetView<ProfileSummaryController> {
  const ProfileSummaryView({Key? key}) : super(key: key);

  Future<void> _openEditSheet(BuildContext context) async {
    final p = controller.profile;
    final nameCtrl = TextEditingController(text: p.name.value);
    final ageCtrl = TextEditingController(text: p.age.value.toString());
    final weightCtrl = TextEditingController(text: p.weight.value.toString());
    final heightCtrl = TextEditingController(text: p.height.value.toString());

    final genders = ['Male', 'Female', 'Other'];
    final goals = [
      'Weight Loss',
      'Muscle Gain',
      'Build Endurance',
      'Improve Flexibility',
    ];
    final activities = [
      'Sedentary',
      'Lightly Active',
      'Moderately Active',
      'Very Active',
    ];
    final fitnessLevels = ['Beginner', 'Intermediate', 'Advanced'];

    final selectedGender =
        (genders.contains(p.gender.value) ? p.gender.value : genders.first).obs;
    final selectedGoal =
        (goals.contains(p.fitnessGoal.value)
                ? p.fitnessGoal.value
                : goals.first)
            .obs;
    final selectedActivity =
        (activities.contains(p.activityLevel.value)
                ? p.activityLevel.value
                : activities.first)
            .obs;
    final selectedFitness =
        (fitnessLevels.contains(p.fitnessLevel.value)
                ? p.fitnessLevel.value
                : fitnessLevels.first)
            .obs;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: const Color(0xFF17171F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Obx(() {
                        final p = controller.profile;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [kNeon, kSky],
                                    ),
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(45),
                                    child: SizedBox(
                                      width: 90,
                                      height: 90,
                                      child:
                                          p.photoUrl.value.isNotEmpty
                                              ? Image.network(
                                                p.photoUrl.value,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => Container(
                                                      color: const Color(
                                                        0xFF1E1E28,
                                                      ),
                                                      child: const Icon(
                                                        Icons.person_rounded,
                                                        color: kMuted,
                                                        size: 30,
                                                      ),
                                                    ),
                                              )
                                              : Container(
                                                color: const Color(0xFF1E1E28),
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  color: kMuted,
                                                  size: 30,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [kNeon, kSky],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF17171F),
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        p.isUploadingPhoto.value
                                            ? const Padding(
                                              padding: EdgeInsets.all(7),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: kInk,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.camera_alt_rounded,
                                              size: 16,
                                              color: kInk,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed:
                                  p.isUploadingPhoto.value
                                      ? null
                                      : () => controller.changeProfileImage(),
                              child: Text(
                                p.isUploadingPhoto.value
                                    ? 'Uploading...'
                                    : 'Change photo',
                                style: GoogleFonts.dmSans(
                                  color: kNeon,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    _editField(
                      nameCtrl,
                      'Full Name',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 10),
                    _editField(
                      ageCtrl,
                      'Age',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _editField(
                      weightCtrl,
                      'Weight (kg)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _editField(
                      heightCtrl,
                      'Height (cm)',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => _dropdownField(
                        label: 'Gender',
                        value: selectedGender.value,
                        items: genders,
                        onChanged: (v) => selectedGender.value = v,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => _dropdownField(
                        label: 'Fitness Goal',
                        value: selectedGoal.value,
                        items: goals,
                        onChanged: (v) => selectedGoal.value = v,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => _dropdownField(
                        label: 'Activity Level',
                        value: selectedActivity.value,
                        items: activities,
                        onChanged: (v) => selectedActivity.value = v,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => _dropdownField(
                        label: 'Fitness Level',
                        value: selectedFitness.value,
                        items: fitnessLevels,
                        onChanged: (v) => selectedFitness.value = v,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final saved = await controller.saveProfile(
                            fullName: nameCtrl.text,
                            selectedGender: selectedGender.value,
                            ageText: ageCtrl.text,
                            weightText: weightCtrl.text,
                            heightText: heightCtrl.text,
                            selectedGoal: selectedGoal.value,
                            selectedActivity: selectedActivity.value,
                            selectedFitness: selectedFitness.value,
                          );
                          if (saved) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kNeon,
                          foregroundColor: kInk,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _editField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: kMuted),
        filled: true,
        fillColor: const Color(0xFF1E1E28),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kNeon),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF17171F),
          style: GoogleFonts.dmSans(color: Colors.white),
          iconEnabledColor: kNeon,
          items:
              items
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          hint: Text(label, style: GoogleFonts.dmSans(color: kMuted)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(
        title: 'Profile Summary',
        onBack: () => controller.goBack(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF121021),
                    Color(0xFF0D1226),
                    Color(0xFF090B14),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -140,
            child: GlowOrb(color: kLilac, radius: 260),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: GlowOrb(color: kSky, radius: 220),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 18),
                  Expanded(
                    child: GetBuilder<ProfileSummaryController>(
                      builder: (c) {
                        final p = c.profile;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [kNeon, kSky],
                                    ),
                                    borderRadius: BorderRadius.circular(52),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(49),
                                    child: SizedBox(
                                      width: 98,
                                      height: 98,
                                      child:
                                          p.photoUrl.value.isNotEmpty
                                              ? Image.network(
                                                p.photoUrl.value,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => Container(
                                                      color: const Color(
                                                        0xFF1E1E28,
                                                      ),
                                                      child: const Icon(
                                                        Icons.person_rounded,
                                                        color: kMuted,
                                                        size: 34,
                                                      ),
                                                    ),
                                              )
                                              : Container(
                                                color: const Color(0xFF1E1E28),
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  color: kMuted,
                                                  size: 34,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap:
                                        p.isUploadingPhoto.value
                                            ? null
                                            : () => c.changeProfileImage(),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [kNeon, kSky],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: const Color(0xFF17171F),
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          p.isUploadingPhoto.value
                                              ? const Padding(
                                                padding: EdgeInsets.all(7),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: kInk,
                                                    ),
                                              )
                                              : const Icon(
                                                Icons.edit_rounded,
                                                size: 17,
                                                color: kInk,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p.name.value,
                              style: GoogleFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.email.value.isNotEmpty
                                  ? p.email.value
                                  : 'No email linked',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: kMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Review your information before continuing',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: kMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    _profileInfoCard(
                                      icon: Icons.person_rounded,
                                      title: 'Gender',
                                      value: p.gender.value,
                                      accent: kNeon,
                                    ),
                                    const SizedBox(height: 12),
                                    _profileInfoCard(
                                      icon: Icons.cake_rounded,
                                      title: 'Age',
                                      value: '${p.age.value} years',
                                      accent: kCoral,
                                    ),
                                    const SizedBox(height: 12),
                                    _profileInfoCard(
                                      icon: Icons.monitor_weight_rounded,
                                      title: 'Weight',
                                      value: '${p.weight.value} kg',
                                      accent: kSky,
                                    ),
                                    const SizedBox(height: 12),
                                    _profileInfoCard(
                                      icon: Icons.straighten_rounded,
                                      title: 'Height',
                                      value: '${p.height.value} cm',
                                      accent: kLilac,
                                    ),
                                    const SizedBox(height: 12),
                                    _profileInfoCard(
                                      icon: Icons.emoji_events_rounded,
                                      title: 'Fitness Goal',
                                      value: p.fitnessGoal.value,
                                      accent: kNeon,
                                    ),
                                    const SizedBox(height: 12),
                                    _profileInfoCard(
                                      icon: Icons.bolt_rounded,
                                      title: 'Activity Level',
                                      value: p.activityLevel.value,
                                      accent: kCoral,
                                    ),
                                    const SizedBox(height: 12),
                                    _profileInfoCard(
                                      icon: Icons.fitness_center_rounded,
                                      title: 'Fitness Level',
                                      value: p.fitnessLevel.value,
                                      accent: kSky,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openEditSheet(context),
                          child: LiquidTile(
                            radius: 28,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: Center(
                              child: Text(
                                'Edit',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: kNeon,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: neonButton(
                          label: 'Continue',
                          onPressed: () => controller.completeProfile(),
                        ),
                      ),
                    ],
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

  Widget _profileInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return LiquidTile(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
