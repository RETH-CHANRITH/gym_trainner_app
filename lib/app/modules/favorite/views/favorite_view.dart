import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../my_bookings/controllers/my_bookings_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../services/favourites_service.dart';

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

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});
  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  int _mainTab = 0; // 0 = Favourites, 1 = My Bookings
  int _bookingTab = 0; // 0 = Upcoming,   1 = Past

  late final MyBookingsController _bookingsCtrl;
  late final FavouritesService _favSvc;

  @override
  void initState() {
    super.initState();
    _favSvc = Get.find<FavouritesService>();
    if (!Get.isRegistered<WalletController>()) {
      Get.put<WalletController>(WalletController(), permanent: false);
    }
    if (!Get.isRegistered<MyBookingsController>()) {
      Get.put<MyBookingsController>(MyBookingsController(), permanent: false);
    }
    _bookingsCtrl = Get.find<MyBookingsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainTabs(),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _mainTab == 0
                      ? _buildFavouritesList()
                      : _buildBookingsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [coral.withOpacity(0.2), coral.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: coral.withOpacity(0.3)),
            ),
            child: const Icon(
              CupertinoIcons.heart_fill,
              color: coral,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Favourites',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    '${_favSvc.favourites.length} trainer${_favSvc.favourites.length == 1 ? '' : 's'} saved',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main tab bar (Favourites | My Bookings) ──────────────────────────────
  Widget _buildMainTabs() {
    final tabs = ['Favourites', 'My Bookings'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _mainTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mainTab = i),
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
    );
  }

  // ─── Favourites tab ──────────────────────────────────────────────────────
  Widget _buildFavouritesList() {
    return Obx(() {
      final list = _favSvc.favourites;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: card,
                  shape: BoxShape.circle,
                  border: Border.all(color: stroke),
                ),
                child: Icon(CupertinoIcons.heart, color: muted, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'No favourites yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Heart a trainer from Search or Home',
                style: TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildTrainerCard(list[index], index),
      );
    });
  }

  // ─── My Bookings tab ────────────────────────────────────────────────────
  Widget _buildBookingsSection() {
    return Column(
      children: [
        _buildBookingSubTabs(),
        const SizedBox(height: 12),
        Expanded(
          child: GetX<MyBookingsController>(
            builder: (ctrl) {
              final list =
                  _bookingTab == 0 ? ctrl.upcomingBookings : ctrl.pastBookings;
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: list.length,
                itemBuilder: (_, i) => _buildBookingCard(list[i], i),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSubTabs() {
    final tabs = ['Upcoming', 'Past'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _bookingTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _bookingTab = i),
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
                              _bookingsCtrl.cancelBooking(index);
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
                                      _bookingsCtrl.payForSession(index);
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
      onTap: () => _showBookingDetail(context, b, index),
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
                      onPressed: () => _bookingsCtrl.cancelBooking(index),
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
                              onPressed:
                                  () => _bookingsCtrl.payForSession(index),
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

  // ─── Trainer card ───────────────────────────────────────────────────────
  Widget _buildTrainerCard(Map<String, dynamic> t, int index) {
    final bool isAvailable =
        (t['available'] ?? t['isAvailable'] ?? false) as bool;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [card, card.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: stroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap:
                () => Get.toNamed(
                  '/trainer-details',
                  arguments: {...t, 'isAvailable': t['available'] ?? false},
                ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar with status dot
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: Image.network(
                                'https://randomuser.me/api/portraits/men/${t['portrait']}.jpg',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: raised,
                                      child: const Icon(
                                        CupertinoIcons.person_fill,
                                        color: muted,
                                        size: 30,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: isAvailable ? neon : muted,
                                shape: BoxShape.circle,
                                border: Border.all(color: card, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t['name'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: raised,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: stroke),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.star_fill,
                                        color: neon,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${t['rating']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['specialty'] as String,
                              style: TextStyle(color: muted, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.square_grid_2x2,
                                  color: muted,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${t['sessions']} sessions',
                                  style: TextStyle(
                                    color: muted.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '|',
                                  style: TextStyle(color: stroke, fontSize: 13),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '\$${t['price']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '/hr',
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Action buttons
                  Row(
                    children: [
                      // Red heart remove button
                      GestureDetector(
                        onTap: () => _favSvc.toggle(t),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: coral.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: coral.withOpacity(0.35)),
                          ),
                          child: const Icon(
                            CupertinoIcons.heart_fill,
                            color: coral,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionButton(
                          icon: CupertinoIcons.chat_bubble,
                          label: 'Message',
                          filled: false,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _actionButton(
                          icon: CupertinoIcons.calendar,
                          label: 'Book Session',
                          filled: true,
                          onTap:
                              () => Get.toNamed(
                                '/book-session',
                                arguments: {
                                  'name': t['name'],
                                  'specialty': t['specialty'],
                                  'portrait': t['portrait'],
                                  'price': t['price'],
                                },
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final radius = filled ? 100.0 : 14.0;
    return Material(
      color: filled ? neon : Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: filled ? null : Border.all(color: stroke),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? ink : muted, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: filled ? ink : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
