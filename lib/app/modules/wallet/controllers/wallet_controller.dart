import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../notifications/controllers/notifications_controller.dart';

class WalletController extends GetxController {
  static const _kBalance = 'wallet_balance';
  static const _kSpent = 'wallet_spent';
  static const _kSessions = 'wallet_sessions';
  static const _kTopUps = 'wallet_topups';
  static const _kTxList = 'wallet_transactions';

  // ─── Reactive state ───────────────────────────────────────────────────────
  var balance = 255.0.obs;
  var spentThisMonth = 270.0.obs;
  var totalSessions = 7.obs;
  var topUps = 2.obs;

  final transactions =
      <Map<String, dynamic>>[
        {
          'title': 'Session — Alex Carter',
          'date': 'Mar 6, 2026',
          'amount': -65,
          'type': 'debit',
          'portrait': 10,
        },
        {
          'title': 'Session — Priya Shah',
          'date': 'Mar 3, 2026',
          'amount': -75,
          'type': 'debit',
          'portrait': 47,
        },
        {
          'title': 'Top-up via Card',
          'date': 'Mar 1, 2026',
          'amount': 200,
          'type': 'credit',
        },
        {
          'title': 'Session — Jordan Miles',
          'date': 'Feb 28, 2026',
          'amount': -55,
          'type': 'debit',
          'portrait': 11,
        },
        {
          'title': 'Session — Sam Rivera',
          'date': 'Feb 24, 2026',
          'amount': -70,
          'type': 'debit',
          'portrait': 12,
        },
        {
          'title': 'Top-up via Card',
          'date': 'Feb 20, 2026',
          'amount': 300,
          'type': 'credit',
        },
        {
          'title': 'Session — Chris Lee',
          'date': 'Feb 18, 2026',
          'amount': -80,
          'type': 'debit',
          'portrait': 13,
        },
      ].obs;

  /// Groups all session debits by trainer name → total paid + session count.
  List<Map<String, dynamic>> get trainerSummary {
    final Map<String, Map<String, dynamic>> map = {};
    for (final t in transactions) {
      if (t['type'] != 'debit' || !(t['title'] as String).startsWith('Session'))
        continue;
      final name = (t['title'] as String).replaceFirst('Session — ', '');
      final amount = (t['amount'] as int).abs();
      if (map.containsKey(name)) {
        map[name]!['total'] = (map[name]!['total'] as int) + amount;
        map[name]!['count'] = (map[name]!['count'] as int) + 1;
      } else {
        map[name] = {
          'name': name,
          'total': amount,
          'count': 1,
          'portrait': t['portrait'],
        };
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    return list;
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    balance.value = prefs.getDouble(_kBalance) ?? balance.value;
    spentThisMonth.value = prefs.getDouble(_kSpent) ?? spentThisMonth.value;
    totalSessions.value = prefs.getInt(_kSessions) ?? totalSessions.value;
    topUps.value = prefs.getInt(_kTopUps) ?? topUps.value;
    final raw = prefs.getString(_kTxList);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      transactions.value =
          decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_kBalance, balance.value);
    prefs.setDouble(_kSpent, spentThisMonth.value);
    prefs.setInt(_kSessions, totalSessions.value);
    prefs.setInt(_kTopUps, topUps.value);
    prefs.setString(_kTxList, jsonEncode(transactions.toList()));
  }

  void addFunds(double amount) {
    balance.value += amount;
    topUps.value += 1;
    transactions.insert(0, {
      'title': 'Top-up via Card',
      'date': _today(),
      'amount': amount.toInt(),
      'type': 'credit',
    });
    _save();
    _pushNotification(
      title: 'Deposit Successful',
      body:
          '\$${amount.toStringAsFixed(0)} has been added to your wallet. New balance: \$${balance.value.toStringAsFixed(2)}.',
      icon: 'payment',
      color: 'neon',
    );
    Get.snackbar(
      'Funds Added',
      '\$${amount.toStringAsFixed(0)} added to your wallet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Deducts [amount] from the wallet to pay for a trainer session.
  /// Returns true if successful, false if insufficient balance.
  bool payForSession(String trainerName, int amount, {int? portrait}) {
    if (amount > balance.value) {
      Get.snackbar(
        'Insufficient Balance',
        'Top up your wallet to pay for this session.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    balance.value -= amount;
    spentThisMonth.value += amount;
    totalSessions.value += 1;
    transactions.insert(0, {
      'title': 'Session — $trainerName',
      'date': _today(),
      'amount': -amount,
      'type': 'debit',
      if (portrait != null) 'portrait': portrait,
    });
    _save();
    return true;
  }

  void withdraw(double amount) {
    if (amount > balance.value) {
      Get.snackbar(
        'Insufficient Balance',
        'You don\'t have enough funds.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    balance.value -= amount;
    transactions.insert(0, {
      'title': 'Withdrawal',
      'date': _today(),
      'amount': -amount.toInt(),
      'type': 'debit',
    });
    _save();
    _pushNotification(
      title: 'Withdrawal Submitted',
      body:
          '\$${amount.toStringAsFixed(0)} withdrawal is being processed. Funds arrive in 1-3 business days.',
      icon: 'payment',
      color: 'sky',
    );
    Get.snackbar(
      'Withdrawal Submitted',
      '\$${amount.toStringAsFixed(0)} will arrive in 1-3 business days.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _pushNotification({
    required String title,
    required String body,
    required String icon,
    required String color,
  }) {
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().addNotification({
        'title': title,
        'body': body,
        'time': 'Just now',
        'icon': icon,
        'read': false,
        'color': color,
        'route': '/wallet',
        'routeArgs': null,
      });
    }
  }

  String _today() {
    final now = DateTime.now();
    const months = [
      '',
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
    return '${months[now.month]} ${now.day}, ${now.year}';
  }
}
