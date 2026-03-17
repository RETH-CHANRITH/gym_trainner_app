import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../config/glass_ui.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Admin Console',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -110,
            child: GlowOrb(color: kNeon, radius: 300),
          ),
          Positioned(
            top: 220,
            right: -120,
            child: GlowOrb(color: kLilac, radius: 250),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: GlowOrb(color: kSky, radius: 240),
          ),
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: kNeon),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _HeaderCard(controller: controller),
                  const SizedBox(height: 16),
                  Text(
                    'Today Overview',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: 'Active Trainers',
                          value: '${controller.activeTrainersCount.value}',
                          delta:
                              '${controller.pendingTrainerApplicationsCount.value} pending approvals',
                          accent: kNeon,
                          onTap:
                              () => Get.to(
                                () => _AdminModulePage(
                                  title: 'Trainer Applications',
                                  child: _TrainerApplicationsPanel(
                                    controller: controller,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          title: 'Open Bookings',
                          value: '${controller.openBookingsCount.value}',
                          delta: 'Live across the platform',
                          accent: kSky,
                          onTap:
                              () => Get.to(
                                () => _AdminModulePage(
                                  title: 'Booking Monitor',
                                  child: _BookingMonitorPanel(
                                    controller: controller,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          title: 'Monthly Revenue',
                          value: _formatCurrency(
                            controller.monthlyRevenue.value,
                          ),
                          delta: 'From completed or paid bookings',
                          accent: kLilac,
                          onTap:
                              () => Get.to(
                                () => _AdminModulePage(
                                  title: 'Finance Operations',
                                  child: _FinancePanel(controller: controller),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          title: 'Support Tickets',
                          value: '${controller.supportOpenCount.value}',
                          delta: 'Open / pending queue',
                          accent: kCoral,
                          onTap:
                              () => Get.to(
                                () => _AdminModulePage(
                                  title: 'Support Tickets',
                                  child: _SupportTicketsPanel(
                                    controller: controller,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.verified_user_rounded,
                    title: 'Trainer Applications',
                    subtitle: 'Approve or reject trainer onboarding requests',
                    accent: kNeon,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Trainer Applications',
                            child: _TrainerApplicationsPanel(
                              controller: controller,
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.people_alt_rounded,
                    title: 'User Management',
                    subtitle: 'Suspend or reactivate user accounts',
                    accent: kSky,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'User Management',
                            child: _UserManagementPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.event_note_rounded,
                    title: 'Booking Monitor',
                    subtitle: 'Review and cancel problematic bookings',
                    accent: kLilac,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Booking Monitor',
                            child: _BookingMonitorPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports & Analytics',
                    subtitle: 'Platform KPIs and operational snapshot',
                    accent: kCoral,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Reports & Analytics',
                            child: _AnalyticsPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Support Tickets',
                    subtitle: 'Track SLA, assign and resolve support requests',
                    accent: kSky,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Support Tickets',
                            child: _SupportTicketsPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.gavel_rounded,
                    title: 'Disputes Center',
                    subtitle: 'Assign disputes and close resolution workflow',
                    accent: kLilac,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Disputes Center',
                            child: _DisputesPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Finance Operations',
                    subtitle: 'Refund approvals and payout processing',
                    accent: kNeon,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Finance Operations',
                            child: _FinancePanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'GDPR Queue',
                    subtitle: 'Verify identity and complete GDPR requests',
                    accent: kCoral,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'GDPR Queue',
                            child: _GdprPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.fact_check_rounded,
                    title: 'Audit Logs',
                    subtitle: 'Immutable timeline of admin actions',
                    accent: kSky,
                    onTap:
                        () => Get.to(
                          () => _AdminModulePage(
                            title: 'Audit Logs',
                            child: _AuditLogsPanel(controller: controller),
                          ),
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...controller.recentActivity.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActivityTile(
                        title: item['title'] ?? 'Activity',
                        subtitle: item['subtitle'] ?? 'No details',
                        time: item['time'] ?? 'Now',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed:
                        controller.isActionLoading.value
                            ? null
                            : controller.logout,
                    icon:
                        controller.isActionLoading.value
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                            ),
                    label: Text(
                      'Log Out',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: BorderSide(color: Colors.white.withOpacity(0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(double amount) {
    if (amount >= 1000) {
      final compact = (amount / 1000).toStringAsFixed(1);
      return '\$${compact}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  static String _formatDateTime(dynamic raw) {
    DateTime? dt;
    if (raw is DateTime) {
      dt = raw;
    } else if (raw is String) {
      dt = DateTime.tryParse(raw);
    } else if (raw != null) {
      try {
        dt = (raw as dynamic).toDate() as DateTime?;
      } catch (_) {
        dt = null;
      }
    }
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class _AdminModulePage extends StatelessWidget {
  const _AdminModulePage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: liquidBackground()),
          Positioned(
            top: -160,
            left: -110,
            child: GlowOrb(color: kNeon, radius: 300),
          ),
          Positioned(
            top: 220,
            right: -120,
            child: GlowOrb(color: kLilac, radius: 250),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: GlowOrb(color: kSky, radius: 240),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [child],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerApplicationsPanel extends StatelessWidget {
  const _TrainerApplicationsPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.trainerApplications;
    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No trainer applications yet',
        subtitle: 'New trainer requests will appear here for review.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trainer Applications',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(8).map((item) {
            final status = (item['status'] ?? 'pending').toString();
            final applicantName =
                (item['name'] ?? item['fullName'] ?? 'Unknown applicant')
                    .toString();
            final email = (item['email'] ?? 'No email').toString();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          applicantName,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  if (status.toLowerCase() == 'pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () => controller.rejectTrainerApplication(
                                      item,
                                    ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kCoral,
                              side: BorderSide(color: kCoral.withOpacity(0.55)),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () => controller
                                        .approveTrainerApplication(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kNeon,
                              foregroundColor: kInk,
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _UserManagementPanel extends StatelessWidget {
  const _UserManagementPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items =
        controller.users.where((u) {
          final role = (u['role'] ?? 'user').toString().toLowerCase();
          return role == 'user' || role == 'trainer';
        }).toList();

    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No user data found',
        subtitle: 'User records will appear here once synced from Firestore.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kSky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(12).map((user) {
            final name =
                (user['name'] ?? user['fullName'] ?? 'Unnamed').toString();
            final email = (user['email'] ?? 'No email').toString();
            final role = (user['role'] ?? 'user').toString();
            final suspended =
                (user['accountStatus'] ?? 'active').toString().toLowerCase() ==
                'suspended';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$email • $role',
                          style: GoogleFonts.dmSans(
                            color: kMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        controller.isActionLoading.value
                            ? null
                            : () =>
                                controller.setUserSuspended(user, !suspended),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: suspended ? kNeon : kCoral,
                      foregroundColor: kInk,
                      minimumSize: const Size(104, 38),
                    ),
                    child: Text(suspended ? 'Activate' : 'Suspend'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BookingMonitorPanel extends StatelessWidget {
  const _BookingMonitorPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.bookings;
    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No bookings found',
        subtitle: 'Bookings will appear here as soon as users start sessions.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kLilac,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Monitor',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(12).map((booking) {
            final user =
                (booking['userName'] ?? booking['clientName'] ?? 'Unknown user')
                    .toString();
            final trainer =
                (booking['trainerName'] ??
                        booking['trainer'] ??
                        'Unknown trainer')
                    .toString();
            final date =
                (booking['date'] ?? booking['sessionDate'] ?? '-').toString();
            final time =
                (booking['time'] ?? booking['sessionTime'] ?? '-').toString();
            final status = (booking['status'] ?? 'pending').toString();
            final cancellable =
                status.toLowerCase() == 'pending' ||
                status.toLowerCase() == 'confirmed';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$user with $trainer',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date • $time',
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
                  ),
                  if (cancellable) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed:
                            controller.isActionLoading.value
                                ? null
                                : () => controller.cancelBooking(booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCoral,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SupportTicketsPanel extends StatelessWidget {
  const _SupportTicketsPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.supportTickets;
    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No support tickets',
        subtitle:
            'Incoming user support tickets will appear here in real time.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kSky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Tickets',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(14).map((ticket) {
            final title =
                (ticket['subject'] ?? ticket['message'] ?? 'Support request')
                    .toString();
            final user =
                (ticket['userEmail'] ?? ticket['userId'] ?? '-').toString();
            final status = (ticket['status'] ?? 'open').toString();
            final priority = (ticket['priority'] ?? 'normal').toString();
            final resolved =
                status.toLowerCase() == 'resolved' ||
                status.toLowerCase() == 'closed';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$user • Priority: $priority',
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
                  ),
                  if (!resolved) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () => controller.markSupportInProgress(
                                      ticket,
                                    ),
                            child: const Text('In Progress'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () =>
                                        controller.resolveSupportTicket(ticket),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kNeon,
                              foregroundColor: kInk,
                            ),
                            child: const Text('Resolve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DisputesPanel extends StatelessWidget {
  const _DisputesPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.disputes;
    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No disputes',
        subtitle: 'Dispute inbox will update here in real time.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kLilac,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispute Inbox',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(14).map((dispute) {
            final title =
                (dispute['title'] ?? dispute['reason'] ?? 'Dispute case')
                    .toString();
            final status = (dispute['status'] ?? 'open').toString();
            final bookingRef =
                (dispute['bookingId'] ?? dispute['bookingRef'] ?? '-')
                    .toString();
            final resolved = status.toLowerCase() == 'resolved';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Booking: $bookingRef',
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
                  ),
                  if (!resolved) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () =>
                                        controller.assignDisputeToSelf(dispute),
                            child: const Text('Assign To Me'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () => controller.resolveDispute(dispute),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kNeon,
                              foregroundColor: kInk,
                            ),
                            child: const Text('Resolve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FinancePanel extends StatelessWidget {
  const _FinancePanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final payouts = controller.payouts;
    final refunds = controller.refunds;

    if (payouts.isEmpty && refunds.isEmpty) {
      return const _EmptyPanel(
        title: 'No finance operations',
        subtitle: 'Refund and payout workflows will appear here in real time.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finance Operations',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          if (payouts.isNotEmpty) ...[
            Text(
              'Payouts',
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...payouts.take(8).map((payout) {
              final status = (payout['status'] ?? 'requested').toString();
              final trainer =
                  (payout['trainerName'] ?? payout['trainerId'] ?? '-')
                      .toString();
              final amount = payout['amount']?.toString() ?? '0';
              final isFinal =
                  status.toLowerCase() == 'paid' ||
                  status.toLowerCase() == 'rejected';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  color: Colors.white.withOpacity(0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Trainer: $trainer • \$$amount',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    if (!isFinal) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  controller.isActionLoading.value
                                      ? null
                                      : () => controller.rejectPayout(payout),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  controller.isActionLoading.value
                                      ? null
                                      : () => controller.approvePayout(payout),
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  controller.isActionLoading.value
                                      ? null
                                      : () => controller.markPayoutPaid(payout),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kNeon,
                                foregroundColor: kInk,
                              ),
                              child: const Text('Mark Paid'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          if (refunds.isNotEmpty) ...[
            Text(
              'Refunds',
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...refunds.take(8).map((refund) {
              final status = (refund['status'] ?? 'requested').toString();
              final user =
                  (refund['userName'] ?? refund['userId'] ?? '-').toString();
              final amount = refund['amount']?.toString() ?? '0';
              final isFinal =
                  status.toLowerCase() == 'processed' ||
                  status.toLowerCase() == 'rejected';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  color: Colors.white.withOpacity(0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'User: $user • \$$amount',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    if (!isFinal) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  controller.isActionLoading.value
                                      ? null
                                      : () => controller.rejectRefund(refund),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  controller.isActionLoading.value
                                      ? null
                                      : () => controller.approveRefund(refund),
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  controller.isActionLoading.value
                                      ? null
                                      : () => controller.processRefund(refund),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kNeon,
                                foregroundColor: kInk,
                              ),
                              child: const Text('Process'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _GdprPanel extends StatelessWidget {
  const _GdprPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.gdprRequests;
    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No GDPR requests',
        subtitle:
            'GDPR requests will be streamed here for compliance handling.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kCoral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GDPR Requests',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(12).map((item) {
            final status = (item['status'] ?? 'received').toString();
            final user =
                (item['userEmail'] ?? item['userId'] ?? '-').toString();
            final complete = status.toLowerCase() == 'completed';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'User: $user',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  if (!complete) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () => controller.verifyGdprIdentity(item),
                            child: const Text('Verify Identity'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                controller.isActionLoading.value
                                    ? null
                                    : () =>
                                        controller.completeGdprRequest(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kNeon,
                              foregroundColor: kInk,
                            ),
                            child: const Text('Complete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AuditLogsPanel extends StatelessWidget {
  const _AuditLogsPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.auditLogs;
    if (items.isEmpty) {
      return const _EmptyPanel(
        title: 'No audit logs yet',
        subtitle: 'Admin mutations will create immutable logs in real time.',
      );
    }

    return LiquidTile(
      radius: 20,
      accent: kSky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audit Logs',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          ...items.take(20).map((log) {
            final action = (log['action'] ?? 'action').toString();
            final actor = (log['actorId'] ?? 'unknown').toString();
            final status = (log['status'] ?? 'success').toString();
            final target = (log['targetId'] ?? '-').toString();
            final time = AdminDashboardView._formatDateTime(log['createdAt']);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          action,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actor: $actor • Target: $target',
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: GoogleFonts.dmSans(
                      color: Colors.white60,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnalyticsPanel extends StatelessWidget {
  const _AnalyticsPanel({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return LiquidTile(
      radius: 20,
      accent: kCoral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports & Analytics',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _MetricRow(
            label: 'Active Trainers',
            value: '${controller.activeTrainersCount.value}',
          ),
          _MetricRow(
            label: 'Active Users',
            value: '${controller.activeUsersCount.value}',
          ),
          _MetricRow(
            label: 'Open Bookings',
            value: '${controller.openBookingsCount.value}',
          ),
          _MetricRow(
            label: 'Open Support Tickets',
            value: '${controller.supportOpenCount.value}',
          ),
          _MetricRow(
            label: 'Open Disputes',
            value: '${controller.disputeOpenCount.value}',
          ),
          _MetricRow(
            label: 'Pending Payouts',
            value: '${controller.payoutPendingCount.value}',
          ),
          _MetricRow(
            label: 'Pending Refunds',
            value: '${controller.refundPendingCount.value}',
          ),
          _MetricRow(
            label: 'GDPR Pending',
            value: '${controller.gdprPendingCount.value}',
          ),
          _MetricRow(
            label: 'Monthly Revenue',
            value: AdminDashboardView._formatCurrency(
              controller.monthlyRevenue.value,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'These metrics are calculated in real time from users, trainerApplications, bookings, transactions, disputes, payouts, refunds, supportTickets, gdprRequests, and auditLogs.',
            style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return LiquidTile(
      radius: 18,
      accent: kMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color =
        normalized == 'approved' ||
                normalized == 'confirmed' ||
                normalized == 'active' ||
                normalized == 'resolved' ||
                normalized == 'paid' ||
                normalized == 'completed' ||
                normalized == 'processed' ||
                normalized == 'success'
            ? kNeon
            : normalized == 'rejected' ||
                normalized == 'cancelled' ||
                normalized == 'failed' ||
                normalized == 'denied'
            ? kCoral
            : normalized == 'suspended'
            ? kLilac
            : kSky;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        status,
        style: GoogleFonts.dmSans(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return LiquidTile(
      radius: 22,
      accent: kNeon,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kNeon.withOpacity(0.85), kSky.withOpacity(0.85)],
              ),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: kInk),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${controller.displayName.value}',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor operations, approvals, and platform health.',
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.accent,
    this.onTap,
  });

  final String title;
  final String value;
  final String delta;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = LiquidTile(
      radius: 18,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: kMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            delta,
            style: GoogleFonts.dmSans(
              color: accent.withOpacity(0.95),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: content,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: LiquidTile(
        radius: 18,
        accent: accent,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: accent.withOpacity(0.18),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(color: kMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return LiquidTile(
      radius: 16,
      accent: kSky,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: kSky,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: GoogleFonts.dmSans(
              color: Colors.white60,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
