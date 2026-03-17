import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

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
const Color gold = Color(0xFFFFBB33);

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

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
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: neon, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final unread = controller.unreadCount.value;
        return Column(
          children: [
            if (unread > 0)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: neon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: neon.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.bell_fill, color: neon, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '$unread unread notification${unread > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: neon,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.notifications.length,
                itemBuilder:
                    (_, i) => _buildNotifCard(controller.notifications[i]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNotifCard(Map<String, dynamic> n) {
    final isRead = n['read'] as bool;
    final colorKey = n['color'] as String;
    final Color accentColor =
        colorKey == 'neon'
            ? neon
            : colorKey == 'sky'
            ? sky
            : colorKey == 'coral'
            ? coral
            : colorKey == 'gold'
            ? gold
            : lilac;

    final IconData icon =
        n['icon'] == 'calendar'
            ? CupertinoIcons.calendar
            : n['icon'] == 'alarm'
            ? CupertinoIcons.alarm_fill
            : n['icon'] == 'payment'
            ? CupertinoIcons.creditcard_fill
            : n['icon'] == 'chat'
            ? CupertinoIcons.chat_bubble_fill
            : n['icon'] == 'review'
            ? CupertinoIcons.star_fill
            : n['icon'] == 'promo'
            ? CupertinoIcons.gift_fill
            : n['icon'] == 'check'
            ? CupertinoIcons.checkmark_circle_fill
            : n['icon'] == 'bell'
            ? CupertinoIcons.bell_fill
            : n['icon'] == 'clock'
            ? CupertinoIcons.clock_fill
            : CupertinoIcons.bell_fill;

    return GestureDetector(
      onTap: () => controller.tappedNotification(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? card : raised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead ? stroke : accentColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.25)),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: neon,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['body'] as String,
                    style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n['time'] as String,
                    style: TextStyle(
                      color: muted.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
