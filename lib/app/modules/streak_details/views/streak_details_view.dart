import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../config/glass_ui.dart';
import '../controllers/streak_details_controller.dart';

// ─── Design Tokens ──────────────────────────────────────────────────────────
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

class StreakDetailsView extends GetView<StreakDetailsController> {
  const StreakDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Workout Streak',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: trainerBackground()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ─── Streak Counter ────────────────────────────────────────
                Obx(
                  () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: stroke),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.flame,
                              color: coral,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${controller.streak.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.streak.value == 1
                              ? 'Day Streak'
                              : 'Days Streak',
                          style: const TextStyle(color: coral, fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Keep it up! 🔥',
                          style: TextStyle(color: muted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Streak History ────────────────────────────────────────
                Text(
                  'Last 7 Days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      controller.streakHistory.length > 7
                          ? 7
                          : controller.streakHistory.length,
                      (index) {
                        final item =
                            controller.streakHistory[controller
                                    .streakHistory
                                    .length -
                                7 +
                                index];
                        return Container(
                          width: 45,
                          height: 60,
                          decoration: BoxDecoration(
                            color: item['completed'] ? coral : raised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: stroke),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['dayOfWeek'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (item['completed'])
                                const Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: Colors.white,
                                  size: 20,
                                )
                              else
                                const Icon(
                                  CupertinoIcons.circle,
                                  color: muted,
                                  size: 20,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
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
