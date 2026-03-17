import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';

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

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBalanceCard(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 28),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 0),
      child: Row(
        children: [
          // ← Back arrow
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: raised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stroke),
              ),
              child: const Icon(
                CupertinoIcons.chevron_left,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Manage your funds',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/notifications'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stroke),
              ),
              child: const Icon(
                CupertinoIcons.bell,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E28), Color(0xFF14141C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: neon.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: neon.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: neon.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: neon,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$${controller.balance.value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 40,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated just now',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: stroke),
            const SizedBox(height: 16),
            Row(
              children: [
                _miniStat(
                  'Spent this month',
                  '\$${controller.spentThisMonth.value.toStringAsFixed(0)}',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: stroke,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _miniStat(
                  'Total sessions',
                  '${controller.totalSessions.value}',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: stroke,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _miniStat('Top-ups', '${controller.topUps.value}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(label, style: TextStyle(color: muted, fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'label': 'Deposit',
        'icon': CupertinoIcons.plus,
        'color': neon,
        'onTap': () => _showAddFundsSheet(),
      },
      {
        'label': 'Withdraw',
        'icon': CupertinoIcons.arrow_up,
        'color': sky,
        'onTap': () => _showWithdrawSheet(),
      },
      {
        'label': 'Pay',
        'icon': CupertinoIcons.qrcode,
        'color': lilac,
        'onTap': () => _showPaySheet(),
      },
      {
        'label': 'History',
        'icon': CupertinoIcons.time,
        'color': coral,
        'onTap': () => Get.toNamed('/tx-history'),
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children:
            actions.asMap().entries.map((entry) {
              final i = entry.key;
              final a = entry.value;
              final accent = a['color'] as Color;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < actions.length - 1 ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: a['onTap'] as VoidCallback,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: stroke),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              a['icon'] as IconData,
                              color: accent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a['label'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap:
                    () => Get.toNamed(
                      '/tx-history',
                      arguments: {'filter': 'wallet'},
                    ),
                child: Text(
                  'See all',
                  style: TextStyle(color: neon, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...controller.transactions.map((t) => _buildTxRow(t)),
        ],
      ),
    );
  }

  Widget _buildTxRow(Map<String, dynamic> t) {
    final isCredit = t['type'] == 'credit';
    final amount = (t['amount'] as int).abs();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isCredit ? neon : coral).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? CupertinoIcons.arrow_down_circle_fill
                  : CupertinoIcons.arrow_up_circle_fill,
              color: isCredit ? neon : coral,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  t['date'] as String,
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}\$$amount',
            style: TextStyle(
              color: isCredit ? neon : coral,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Add Funds Sheet ────────────────────────────────────────────────────
  void _showAddFundsSheet() {
    final amounts = [50, 100, 200, 500];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const SizedBox(height: 20),
            const Text(
              'Deposit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select an amount to top up your wallet.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  amounts
                      .map(
                        (amt) => GestureDetector(
                          onTap: () {
                            Get.back();
                            controller.addFunds(amt.toDouble());
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: neon.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: neon.withOpacity(0.35)),
                            ),
                            child: Center(
                              child: Text(
                                '+\$$amt',
                                style: const TextStyle(
                                  color: neon,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── Withdraw Sheet ──────────────────────────────────────────────────────
  void _showWithdrawSheet() {
    final amounts = [50, 100, 150, 200];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const SizedBox(height: 20),
            const Text(
              'Withdraw Funds',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => Text(
                'Available: \$${controller.balance.value.toStringAsFixed(2)}',
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  amounts
                      .map(
                        (amt) => GestureDetector(
                          onTap: () {
                            Get.back();
                            controller.withdraw(amt.toDouble());
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: sky.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: sky.withOpacity(0.35)),
                            ),
                            child: Center(
                              child: Text(
                                '\$$amt',
                                style: const TextStyle(
                                  color: sky,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── Pay / QR Sheet ──────────────────────────────────────────────────────
  void _showPaySheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            const Text(
              'Pay via QR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Let your trainer scan this to collect payment.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.qrcode,
                  size: 130,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'gymtrainer.app/pay/user123',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
