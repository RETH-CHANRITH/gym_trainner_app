import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/notification_permission_controller.dart';
import '../../../../config/glass_ui.dart';

// ─── Design Tokens (matching home_view) ────────────────────────────────────────
class NotificationPermissionView
    extends GetView<NotificationPermissionController> {
  const NotificationPermissionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar(
        title: 'Notifications',
        onBack: () => controller.goBack(),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -100,
            child: GlowOrb(color: kSky, radius: 280),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(color: kNeon, radius: 230),
          ),
          Positioned(
            top: 310,
            right: -50,
            child: GlowOrb(color: kLilac, radius: 140),
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
                          colors: [kSky, kNeon],
                        ).createShader(b),
                    child: Text(
                      'Stay\nUpdated',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enable notifications to get reminders about your workouts',
                    style: GoogleFonts.dmSans(fontSize: 13, color: kMuted),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kSky.withOpacity(0.12),
                                border: Border.all(
                                  color: kSky.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_rounded,
                                size: 52,
                                color: kSky,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(() {
                          final enabled = controller.notificationEnabled.value;
                          return GestureDetector(
                            onTap:
                                () => controller.toggleNotification(!enabled),
                            child: LiquidTile(
                              selected: enabled,
                              accent: kSky,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    color: enabled ? kSky : kMuted,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enable Notifications',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                enabled ? kSky : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Get reminders and updates',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: kMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: enabled,
                                    onChanged: controller.toggleNotification,
                                    activeColor: kInk,
                                    activeTrackColor: kSky,
                                    inactiveThumbColor: kMuted,
                                    inactiveTrackColor: Colors.white
                                        .withOpacity(0.08),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        Text(
                          'You can change this anytime in settings',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: kMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  neonButton(
                    label: 'Continue',
                    accent: kSky,
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
