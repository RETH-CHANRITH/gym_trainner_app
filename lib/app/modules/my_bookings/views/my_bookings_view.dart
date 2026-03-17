import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/my_bookings_controller.dart';

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

class MyBookingsView extends GetView<MyBookingsController> {
  const MyBookingsView({super.key});

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
          'My Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildTabs(),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final list =
                  controller.tabIndex.value == 0
                      ? controller.upcomingBookings
                      : controller.pastBookings;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.calendar_badge_minus,
                        color: muted,
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings here',
                        style: TextStyle(color: muted, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                itemCount: list.length,
                itemBuilder: (_, i) => _buildBookingCard(list[i], i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Upcoming', 'Past'];
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stroke),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = controller.tabIndex.value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? neon : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active ? ink : muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showBookingDetail(
    BuildContext context,
    Map<String, dynamic> b,
    int index,
  ) {
    final status = b['status'] as String;
    final Color statusColor =
        status == 'confirmed'
            ? neon
            : status == 'pending'
            ? sky
            : status == 'completed'
            ? lilac
            : coral;
    final bool isActive = status == 'confirmed' || status == 'pending';
    final Color paymentColor =
        b['paid'] == true ? neon : const Color(0xFFFF8A8A);

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final offsetY = (1 - value) * 18;
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, offsetY),
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF17171F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: stroke,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Booking Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: stroke),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child:
                              b['portrait'] != null
                                  ? Image.network(
                                    'https://randomuser.me/api/portraits/men/${b['portrait']}.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          CupertinoIcons.person_fill,
                                          color: neon,
                                          size: 28,
                                        ),
                                  )
                                  : const Icon(
                                    CupertinoIcons.person_fill,
                                    color: neon,
                                    size: 28,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['trainer'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              b['specialty'] as String,
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statusColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: stroke),
                  const SizedBox(height: 16),
                  _detailRow(
                    CupertinoIcons.calendar,
                    'Date',
                    b['date'] as String,
                  ),
                  const SizedBox(height: 10),
                  _detailRow(CupertinoIcons.clock, 'Time', b['time'] as String),
                  const SizedBox(height: 10),
                  _detailRow(
                    CupertinoIcons.person_2,
                    'Type',
                    b['type'] as String,
                  ),
                  const SizedBox(height: 10),
                  _detailRow(
                    CupertinoIcons.money_dollar_circle,
                    'Price',
                    '\$${b['price']}',
                    valueColor: neon,
                  ),
                  const SizedBox(height: 10),
                  _detailRow(
                    CupertinoIcons.checkmark_shield,
                    'Payment',
                    b['paid'] == true ? 'Paid' : 'Unpaid',
                    valueColor: paymentColor,
                  ),
                  const SizedBox(height: 18),
                  if (isActive) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context);
                              controller.cancelBooking(index);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: coral,
                              side: const BorderSide(color: coral),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              b['paid'] == true
                                  ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: neon.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: neon.withOpacity(0.35),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.checkmark_circle_fill,
                                          color: neon,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Paid',
                                          style: TextStyle(
                                            color: neon,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ElevatedButton(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      Navigator.pop(context);
                                      controller.payForSession(index);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: neon,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      elevation: 6,
                                      shadowColor: neon.withOpacity(0.4),
                                    ),
                                    child: Text(
                                      'Pay \$${b['price']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: raised,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(CupertinoIcons.star, size: 16),
                        label: const Text(
                          'Leave a Review',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
    ).whenComplete(HapticFeedback.selectionClick);
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: raised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: stroke),
          ),
          child: Icon(icon, color: muted, size: 16),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: muted, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> b, int index) {
    final status = b['status'] as String;
    final Color statusColor =
        status == 'confirmed'
            ? neon
            : status == 'pending'
            ? sky
            : status == 'completed'
            ? lilac
            : coral;

    return GestureDetector(
      onTap: () => _showBookingDetail(Get.context!, b, index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: neon.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: neon.withOpacity(0.25)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        b['portrait'] != null
                            ? Image.network(
                              'https://randomuser.me/api/portraits/men/${b['portrait']}.jpg',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    CupertinoIcons.person_fill,
                                    color: neon,
                                    size: 22,
                                  ),
                            )
                            : const Icon(
                              CupertinoIcons.person_fill,
                              color: neon,
                              size: 22,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['trainer'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        b['specialty'] as String,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: stroke),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(CupertinoIcons.calendar, b['date'] as String),
                const SizedBox(width: 14),
                _infoChip(CupertinoIcons.clock, b['time'] as String),
                const SizedBox(width: 14),
                _infoChip(CupertinoIcons.person_2, b['type'] as String),
              ],
            ),
            if (status == 'confirmed' || status == 'pending') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.cancelBooking(index),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: coral,
                        side: const BorderSide(color: coral),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        b['paid'] == true
                            ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: neon.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: neon.withOpacity(0.35),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    color: neon,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Paid',
                                    style: TextStyle(
                                      color: neon,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ElevatedButton(
                              onPressed: () => controller.payForSession(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: neon,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                'Pay \$${b['price']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ink,
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: muted, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: muted, fontSize: 12)),
      ],
    );
  }
}
