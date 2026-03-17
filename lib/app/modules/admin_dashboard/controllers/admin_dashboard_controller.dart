import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class AdminDashboardController extends GetxController {
  AdminDashboardController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final displayName = 'Admin'.obs;
  final isLoading = true.obs;
  final isActionLoading = false.obs;
  final selectedPanel = 0.obs;

  final trainerApplications = <Map<String, dynamic>>[].obs;
  final users = <Map<String, dynamic>>[].obs;
  final bookings = <Map<String, dynamic>>[].obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final supportTickets = <Map<String, dynamic>>[].obs;
  final disputes = <Map<String, dynamic>>[].obs;
  final refunds = <Map<String, dynamic>>[].obs;
  final payouts = <Map<String, dynamic>>[].obs;
  final gdprRequests = <Map<String, dynamic>>[].obs;
  final auditLogs = <Map<String, dynamic>>[].obs;

  final activeTrainersCount = 0.obs;
  final pendingTrainerApplicationsCount = 0.obs;
  final activeUsersCount = 0.obs;
  final openBookingsCount = 0.obs;
  final supportOpenCount = 0.obs;
  final disputeOpenCount = 0.obs;
  final payoutPendingCount = 0.obs;
  final refundPendingCount = 0.obs;
  final gdprPendingCount = 0.obs;
  final monthlyRevenue = 0.0.obs;

  final recentActivity = <Map<String, String>>[].obs;

  final _subscriptions = <StreamSubscription<dynamic>>[];
  static const int _dashboardCollectionLimit = 120;
  Timer? _kpiRecomputeDebounce;
  Timer? _activityRecomputeDebounce;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      displayName.value = name;
    }
    _listenCollections();
  }

  @override
  void onClose() {
    _kpiRecomputeDebounce?.cancel();
    _activityRecomputeDebounce?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }

  void setPanel(int index) {
    selectedPanel.value = index;
  }

  void _listenCollections() {
    _subscriptions.add(
      _firestore
          .collection('trainerApplications')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            trainerApplications.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleRecentActivityRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('users')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            users.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('bookings')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            bookings.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
            _scheduleRecentActivityRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('transactions')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            transactions.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('supportTickets')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            supportTickets.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
            _scheduleRecentActivityRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('disputes')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            disputes.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
            _scheduleRecentActivityRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('refunds')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            refunds.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('payouts')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            payouts.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('gdprRequests')
          .limit(_dashboardCollectionLimit)
          .snapshots()
          .listen((snap) {
            gdprRequests.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleKpiRecompute();
          }, onError: (_) {}),
    );

    _subscriptions.add(
      _firestore
          .collection('auditLogs')
          .orderBy('createdAt', descending: true)
          .limit(120)
          .snapshots()
          .listen((snap) {
            auditLogs.assignAll(
              snap.docs.map((doc) {
                final data = doc.data();
                return {'id': doc.id, ...data};
              }),
            );
            _scheduleRecentActivityRecompute();
          }, onError: (_) {}),
    );

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      isLoading.value = false;
    });
  }

  void _scheduleKpiRecompute() {
    _kpiRecomputeDebounce?.cancel();
    _kpiRecomputeDebounce = Timer(const Duration(milliseconds: 220), () {
      _recomputeKpis();
    });
  }

  void _scheduleRecentActivityRecompute() {
    _activityRecomputeDebounce?.cancel();
    _activityRecomputeDebounce = Timer(const Duration(milliseconds: 280), () {
      _recomputeRecentActivity();
    });
  }

  void _recomputeKpis() {
    pendingTrainerApplicationsCount.value =
        trainerApplications.where((a) {
          final status = (a['status'] ?? 'pending').toString().toLowerCase();
          return status == 'pending';
        }).length;

    activeUsersCount.value =
        users.where((u) {
          final role = (u['role'] ?? 'user').toString().toLowerCase();
          final status =
              (u['accountStatus'] ?? 'active').toString().toLowerCase();
          return role == 'user' && status != 'suspended';
        }).length;

    activeTrainersCount.value =
        users.where((u) {
          final role = (u['role'] ?? '').toString().toLowerCase();
          final status =
              (u['accountStatus'] ?? 'active').toString().toLowerCase();
          return role == 'trainer' && status != 'suspended';
        }).length;

    openBookingsCount.value =
        bookings.where((b) {
          final status = (b['status'] ?? '').toString().toLowerCase();
          return status == 'pending' || status == 'confirmed';
        }).length;

    supportOpenCount.value =
        supportTickets.where((t) {
          final status = (t['status'] ?? '').toString().toLowerCase();
          return status == 'open' ||
              status == 'pending' ||
              status == 'received' ||
              status == 'in_progress';
        }).length;

    disputeOpenCount.value =
        disputes.where((d) {
          final status = (d['status'] ?? '').toString().toLowerCase();
          return status == 'open' ||
              status == 'pending' ||
              status == 'assigned';
        }).length;

    payoutPendingCount.value =
        payouts.where((p) {
          final status = (p['status'] ?? '').toString().toLowerCase();
          return status == 'requested' ||
              status == 'pending' ||
              status == 'approved';
        }).length;

    refundPendingCount.value =
        refunds.where((r) {
          final status = (r['status'] ?? '').toString().toLowerCase();
          return status == 'requested' ||
              status == 'pending' ||
              status == 'approved';
        }).length;

    gdprPendingCount.value =
        gdprRequests.where((g) {
          final status = (g['status'] ?? '').toString().toLowerCase();
          return status == 'received' ||
              status == 'pending' ||
              status == 'identity-verified';
        }).length;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    var revenue = 0.0;

    if (transactions.isNotEmpty) {
      for (final tx in transactions) {
        final status = (tx['status'] ?? '').toString().toLowerCase();
        final type = (tx['type'] ?? '').toString().toLowerCase();
        if (status != 'success' && status != 'completed' && status != 'paid') {
          continue;
        }
        if (type != 'payment' && type != 'credit') continue;

        final createdAt = _toDateTime(tx['createdAt']);
        if (createdAt != null && createdAt.isBefore(startOfMonth)) continue;

        revenue += _toDouble(tx['amount']);
      }
    } else {
      for (final booking in bookings) {
        final status = (booking['status'] ?? '').toString().toLowerCase();
        if (status != 'completed' && booking['paid'] != true) continue;

        final createdAt = _toDateTime(booking['createdAt']);
        if (createdAt != null && createdAt.isBefore(startOfMonth)) continue;

        revenue += _toDouble(booking['price'] ?? booking['amount']);
      }
    }
    monthlyRevenue.value = revenue;
  }

  void _recomputeRecentActivity() {
    final activity = <Map<String, String>>[];

    final pendingApplications =
        trainerApplications.where((a) {
          final status = (a['status'] ?? 'pending').toString().toLowerCase();
          return status == 'pending';
        }).length;
    if (pendingApplications > 0) {
      activity.add({
        'title': 'Trainer verification queue updated',
        'subtitle': '$pendingApplications pending applications',
        'time': 'Live',
      });
    }

    if (supportOpenCount.value > 0) {
      activity.add({
        'title': 'Support backlog requires review',
        'subtitle': '${supportOpenCount.value} open support tickets',
        'time': 'Live',
      });
    }

    if (disputeOpenCount.value > 0) {
      activity.add({
        'title': 'Disputes awaiting action',
        'subtitle': '${disputeOpenCount.value} unresolved dispute cases',
        'time': 'Live',
      });
    }

    if (payoutPendingCount.value > 0 || refundPendingCount.value > 0) {
      activity.add({
        'title': 'Finance approvals pending',
        'subtitle':
            '${payoutPendingCount.value} payouts and ${refundPendingCount.value} refunds pending',
        'time': 'Live',
      });
    }

    if (gdprPendingCount.value > 0) {
      activity.add({
        'title': 'GDPR queue requires verification',
        'subtitle': '${gdprPendingCount.value} GDPR requests in progress',
        'time': 'Live',
      });
    }

    if (auditLogs.isNotEmpty) {
      final log = auditLogs.first;
      activity.add({
        'title':
            'Latest admin action: ${(log['action'] ?? 'update').toString()}',
        'subtitle': 'Actor ${(log['actorId'] ?? 'unknown').toString()}',
        'time': 'Now',
      });
    }

    if (activity.isEmpty) {
      activity.add({
        'title': 'Operations look healthy',
        'subtitle': 'No pending escalations right now',
        'time': 'Now',
      });
    }

    recentActivity.assignAll(activity.take(5));
  }

  Future<void> approveTrainerApplication(
    Map<String, dynamic> application,
  ) async {
    final appId = application['id']?.toString();
    if (appId == null || appId.isEmpty) return;
    final userId = application['userId']?.toString();

    await _guardedAction(
      action: 'trainer_application.approve',
      targetId: appId,
      before: application,
      run: () async {
        await _firestore.collection('trainerApplications').doc(appId).set({
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': FirebaseAuth.instance.currentUser?.uid,
        }, SetOptions(merge: true));

        if (userId != null && userId.isNotEmpty) {
          await _firestore.collection('users').doc(userId).set({
            'role': 'trainer',
            'trainerApproved': true,
            'accountStatus': 'active',
          }, SetOptions(merge: true));
        }
      },
      onSuccess: () {
        Get.snackbar('Approved', 'Trainer application approved successfully.');
      },
    );
  }

  Future<void> rejectTrainerApplication(
    Map<String, dynamic> application,
  ) async {
    final appId = application['id']?.toString();
    if (appId == null || appId.isEmpty) return;

    await _guardedAction(
      action: 'trainer_application.reject',
      targetId: appId,
      before: application,
      run: () async {
        await _firestore.collection('trainerApplications').doc(appId).set({
          'status': 'rejected',
          'reviewedAt': FieldValue.serverTimestamp(),
          'reviewedBy': FirebaseAuth.instance.currentUser?.uid,
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Rejected', 'Trainer application was rejected.');
      },
    );
  }

  Future<void> setUserSuspended(Map<String, dynamic> user, bool suspend) async {
    final userId = user['id']?.toString();
    if (userId == null || userId.isEmpty) return;

    await _guardedAction(
      action: suspend ? 'user.suspend' : 'user.reactivate',
      targetId: userId,
      before: user,
      run: () async {
        await _firestore.collection('users').doc(userId).set({
          'accountStatus': suspend ? 'suspended' : 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar(
          suspend ? 'User suspended' : 'User reactivated',
          suspend
              ? 'Account has been suspended.'
              : 'Account access restored successfully.',
        );
      },
    );
  }

  Future<void> cancelBooking(Map<String, dynamic> booking) async {
    final bookingId = booking['id']?.toString();
    if (bookingId == null || bookingId.isEmpty) return;

    await _guardedAction(
      action: 'booking.cancel',
      targetId: bookingId,
      before: booking,
      run: () async {
        await _firestore.collection('bookings').doc(bookingId).set({
          'status': 'cancelled',
          'cancelledBy': 'admin',
          'cancelledAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar(
          'Booking cancelled',
          'The booking was cancelled by admin.',
        );
      },
    );
  }

  Future<void> resolveSupportTicket(Map<String, dynamic> ticket) async {
    final ticketId = ticket['id']?.toString();
    if (ticketId == null || ticketId.isEmpty) return;

    await _guardedAction(
      action: 'support.resolve',
      targetId: ticketId,
      before: ticket,
      run: () async {
        await _firestore.collection('supportTickets').doc(ticketId).set({
          'status': 'resolved',
          'resolvedAt': FieldValue.serverTimestamp(),
          'resolvedBy': FirebaseAuth.instance.currentUser?.uid,
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Ticket resolved', 'Support ticket marked as resolved.');
      },
    );
  }

  Future<void> markSupportInProgress(Map<String, dynamic> ticket) async {
    final ticketId = ticket['id']?.toString();
    if (ticketId == null || ticketId.isEmpty) return;

    await _guardedAction(
      action: 'support.in_progress',
      targetId: ticketId,
      before: ticket,
      run: () async {
        await _firestore.collection('supportTickets').doc(ticketId).set({
          'status': 'in_progress',
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': FirebaseAuth.instance.currentUser?.uid,
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Ticket updated', 'Support ticket moved to in-progress.');
      },
    );
  }

  Future<void> assignDisputeToSelf(Map<String, dynamic> dispute) async {
    final disputeId = dispute['id']?.toString();
    if (disputeId == null || disputeId.isEmpty) return;

    await _guardedAction(
      action: 'dispute.assign_self',
      targetId: disputeId,
      before: dispute,
      run: () async {
        await _firestore.collection('disputes').doc(disputeId).set({
          'status': 'assigned',
          'assignedTo': FirebaseAuth.instance.currentUser?.uid,
          'assignedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Dispute assigned', 'Dispute assigned to your queue.');
      },
    );
  }

  Future<void> resolveDispute(Map<String, dynamic> dispute) async {
    final disputeId = dispute['id']?.toString();
    if (disputeId == null || disputeId.isEmpty) return;

    await _guardedAction(
      action: 'dispute.resolve',
      targetId: disputeId,
      before: dispute,
      run: () async {
        await _firestore.collection('disputes').doc(disputeId).set({
          'status': 'resolved',
          'resolvedBy': FirebaseAuth.instance.currentUser?.uid,
          'resolvedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Dispute resolved', 'Dispute marked as resolved.');
      },
    );
  }

  Future<void> approveRefund(Map<String, dynamic> refund) async {
    await _setRefundStatus(refund, 'approved', 'Refund approved');
  }

  Future<void> rejectRefund(Map<String, dynamic> refund) async {
    await _setRefundStatus(refund, 'rejected', 'Refund rejected');
  }

  Future<void> processRefund(Map<String, dynamic> refund) async {
    await _setRefundStatus(refund, 'processed', 'Refund processed');
  }

  Future<void> _setRefundStatus(
    Map<String, dynamic> refund,
    String status,
    String message,
  ) async {
    final refundId = refund['id']?.toString();
    if (refundId == null || refundId.isEmpty) return;

    await _guardedAction(
      action: 'refund.$status',
      targetId: refundId,
      before: refund,
      run: () async {
        await _firestore.collection('refunds').doc(refundId).set({
          'status': status,
          'updatedBy': FirebaseAuth.instance.currentUser?.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Refund updated', message);
      },
    );
  }

  Future<void> approvePayout(Map<String, dynamic> payout) async {
    await _setPayoutStatus(payout, 'approved', 'Payout approved');
  }

  Future<void> rejectPayout(Map<String, dynamic> payout) async {
    await _setPayoutStatus(payout, 'rejected', 'Payout rejected');
  }

  Future<void> markPayoutPaid(Map<String, dynamic> payout) async {
    await _setPayoutStatus(payout, 'paid', 'Payout marked as paid');
  }

  Future<void> _setPayoutStatus(
    Map<String, dynamic> payout,
    String status,
    String message,
  ) async {
    final payoutId = payout['id']?.toString();
    if (payoutId == null || payoutId.isEmpty) return;

    await _guardedAction(
      action: 'payout.$status',
      targetId: payoutId,
      before: payout,
      run: () async {
        await _firestore.collection('payouts').doc(payoutId).set({
          'status': status,
          'updatedBy': FirebaseAuth.instance.currentUser?.uid,
          'updatedAt': FieldValue.serverTimestamp(),
          if (status == 'paid') 'paidAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('Payout updated', message);
      },
    );
  }

  Future<void> verifyGdprIdentity(Map<String, dynamic> request) async {
    await _setGdprStatus(
      request,
      'identity-verified',
      'GDPR identity verification completed.',
    );
  }

  Future<void> completeGdprRequest(Map<String, dynamic> request) async {
    await _setGdprStatus(request, 'completed', 'GDPR request marked complete.');
  }

  Future<void> _setGdprStatus(
    Map<String, dynamic> request,
    String status,
    String message,
  ) async {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty) return;

    await _guardedAction(
      action: 'gdpr.$status',
      targetId: requestId,
      before: request,
      run: () async {
        await _firestore.collection('gdprRequests').doc(requestId).set({
          'status': status,
          'updatedBy': FirebaseAuth.instance.currentUser?.uid,
          'updatedAt': FieldValue.serverTimestamp(),
          if (status == 'completed')
            'completedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      onSuccess: () {
        Get.snackbar('GDPR request updated', message);
      },
    );
  }

  Future<void> _guardedAction({
    required Future<void> Function() run,
    required String action,
    required String targetId,
    Map<String, dynamic>? before,
    void Function()? onSuccess,
  }) async {
    if (isActionLoading.value) return;
    isActionLoading.value = true;
    try {
      await run();
      await _writeAuditLog(
        action: action,
        targetId: targetId,
        before: before,
        after: {'result': 'success'},
        status: 'success',
      );
      onSuccess?.call();
    } catch (_) {
      await _writeAuditLog(
        action: action,
        targetId: targetId,
        before: before,
        after: {'result': 'failed'},
        status: 'failed',
      );
      Get.snackbar(
        'Action failed',
        'Unable to complete this action. Please check connectivity and retry.',
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> _writeAuditLog({
    required String action,
    required String targetId,
    required String status,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    final requestId =
        '${DateTime.now().millisecondsSinceEpoch}-${targetId.hashCode.abs()}';

    try {
      await _firestore.collection('auditLogs').add({
        'actorId': uid,
        'action': action,
        'targetId': targetId,
        'before': before,
        'after': after,
        'status': status,
        'requestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Keep user flow responsive if audit write fails.
    }
  }

  DateTime? _toDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
