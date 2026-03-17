import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/book_session_controller.dart';

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

class BookSessionView extends GetView<BookSessionController> {
  const BookSessionView({super.key});

  String _uiDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

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
          'Book a Session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrainerCard(),
            const SizedBox(height: 24),
            _buildSectionLabel('Session Type'),
            const SizedBox(height: 12),
            _buildSessionTypes(),
            const SizedBox(height: 24),
            _buildSectionLabel('Select Date'),
            const SizedBox(height: 12),
            _buildDatePicker(context),
            const SizedBox(height: 10),
            _buildQuickDateChips(),
            const SizedBox(height: 24),
            _buildSectionLabel('Morning'),
            const SizedBox(height: 12),
            _buildSlots(controller.morningSlots),
            const SizedBox(height: 20),
            _buildSectionLabel('Afternoon'),
            const SizedBox(height: 12),
            _buildSlots(controller.afternoonSlots),
            const SizedBox(height: 20),
            _buildSectionLabel('Evening'),
            const SizedBox(height: 12),
            _buildSlots(controller.eveningSlots),
            const SizedBox(height: 26),
            _buildBookingSummary(),
            const SizedBox(height: 32),
            _buildConfirmButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: neon.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: neon.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child:
                  controller.portrait.value != null
                      ? Image.network(
                        'https://randomuser.me/api/portraits/men/${controller.portrait.value}.jpg',
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
                Obx(
                  () => Text(
                    controller.trainerName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.specialty.value,
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(CupertinoIcons.star_fill, color: neon, size: 12),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        color: neon,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      CupertinoIcons.money_dollar_circle,
                      color: muted,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Obx(
                      () => Text(
                        '\$${controller.price.value}/session',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  Widget _buildSessionTypes() {
    return Obx(
      () => Row(
        children:
            controller.sessionTypes.map((type) {
              final selected = controller.selectedType.value == type;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => controller.pickType(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? neon.withOpacity(0.15) : card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected ? neon : stroke,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: selected ? neon : muted,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      final picked = controller.selectedDate.value;
      return GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 60)),
            builder:
                (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: neon,
                      onPrimary: ink,
                      surface: card,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: surface,
                  ),
                  child: child!,
                ),
          );
          if (date != null) controller.pickDate(date);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: picked != null ? neon : stroke,
              width: picked != null ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                color: picked != null ? neon : muted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                picked != null
                    ? '${picked.day}/${picked.month}/${picked.year}'
                    : 'Tap to pick a date',
                style: TextStyle(
                  color: picked != null ? Colors.white : muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSlots(List<Map<String, dynamic>> slots) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            slots.map((slot) {
              final time = slot['time'] as String;
              final available = slot['available'] as bool;
              final selected = controller.selectedSlot.value == time;
              return GestureDetector(
                onTap: available ? () => controller.pickSlot(time) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        !available
                            ? raised.withOpacity(0.5)
                            : selected
                            ? neon.withOpacity(0.15)
                            : card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          !available
                              ? stroke.withOpacity(0.4)
                              : selected
                              ? neon
                              : stroke,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color:
                          !available
                              ? muted.withOpacity(0.4)
                              : selected
                              ? neon
                              : Colors.white,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 13,
                      decoration:
                          !available
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildQuickDateChips() {
    final options = [
      {'label': 'Today', 'days': 0},
      {'label': 'Tomorrow', 'days': 1},
      {'label': '+2 Days', 'days': 2},
    ];

    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            options.map((opt) {
              final date = DateTime.now().add(
                Duration(days: opt['days']! as int),
              );
              final selected =
                  controller.selectedDate.value != null &&
                  controller.selectedDate.value!.year == date.year &&
                  controller.selectedDate.value!.month == date.month &&
                  controller.selectedDate.value!.day == date.day;
              return GestureDetector(
                onTap: () => controller.pickQuickDate(opt['days']! as int),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? neon.withOpacity(0.16) : card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? neon : stroke),
                  ),
                  child: Text(
                    opt['label']! as String,
                    style: TextStyle(
                      color: selected ? neon : muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Obx(() {
      final date = controller.selectedDate.value;
      final slot = controller.selectedSlot.value;
      final ready = controller.canConfirm;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ready ? neon.withOpacity(0.7) : stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.doc_text, color: sky, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Booking Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${controller.price.value}',
                  style: const TextStyle(
                    color: neon,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(CupertinoIcons.calendar, color: muted, size: 14),
                const SizedBox(width: 8),
                Text(
                  date != null ? _uiDate(date) : 'Select a date',
                  style: TextStyle(
                    color: date != null ? Colors.white : muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(CupertinoIcons.clock, color: muted, size: 14),
                const SizedBox(width: 8),
                Text(
                  slot.isNotEmpty ? slot : 'Select time',
                  style: TextStyle(
                    color: slot.isNotEmpty ? Colors.white : muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(CupertinoIcons.person_2, color: muted, size: 14),
                const SizedBox(width: 8),
                Text(
                  controller.selectedType.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildConfirmButton() {
    return Obx(() {
      final enabled = controller.canConfirm && !controller.isSubmitting.value;
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: enabled ? controller.confirmBooking : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? neon : raised,
            disabledBackgroundColor: raised,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child:
              controller.isSubmitting.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(ink),
                    ),
                  )
                  : Text(
                    enabled ? 'Confirm Booking' : 'Select Date & Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: enabled ? ink : muted,
                    ),
                  ),
        ),
      );
    });
  }
}
