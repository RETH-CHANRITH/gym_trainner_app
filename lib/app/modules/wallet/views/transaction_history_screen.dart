import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';

// ─── Design Tokens (same as wallet_screen) ──────────────────────────────────
const Color _ink = Color(0xFF0A0A0F);
const Color _card = Color(0xFF17171F);
const Color _raised = Color(0xFF1E1E28);
const Color _stroke = Color(0xFF2A2A36);
const Color _neon = Color(0xFFCBFF47);
const Color _coral = Color(0xFFFF5C5C);
const Color _muted = Color(0xFF6B6B7E);

class TransactionHistoryScreen extends GetView<WalletController> {
  const TransactionHistoryScreen({super.key});

  /// true  → show only deposits & withdrawals (from "See all" on wallet screen)
  /// false → show trainer payment breakdown + all transactions (from "History" button)
  bool get _walletOnly {
    final args = Get.arguments;
    return args is Map && args['filter'] == 'wallet';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (!_walletOnly) ...[
                _buildTrainerSummary(),
                const SizedBox(height: 28),
              ],
              _buildFullList(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _raised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _stroke),
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
                Text(
                  _walletOnly ? 'Deposits & Withdrawals' : 'Payment History',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                Text(
                  _walletOnly
                      ? 'Your top-ups and withdrawals'
                      : 'All your trainer payments',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trainer Summary Cards ────────────────────────────────────────────────
  Widget _buildTrainerSummary() {
    final summary = controller.trainerSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Paid to Trainers',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: summary.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _buildTrainerCard(summary[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerCard(Map<String, dynamic> s) {
    final portrait = s['portrait'] as int?;
    final name = s['name'] as String;
    final total = s['total'] as int;
    final count = s['count'] as int;

    return GestureDetector(
      onTap: () => _showTrainerDetail(s),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _neon.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _neon.withOpacity(0.25)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child:
                    portrait != null
                        ? Image.network(
                          'https://randomuser.me/api/portraits/men/$portrait.jpg',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                CupertinoIcons.person_fill,
                                color: _neon,
                                size: 22,
                              ),
                        )
                        : const Icon(
                          CupertinoIcons.person_fill,
                          color: _neon,
                          size: 22,
                        ),
              ),
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              name.split(' ').first,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$count session${count > 1 ? 's' : ''}',
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
            const Spacer(),
            // Total paid
            Text(
              '-\$$total',
              style: const TextStyle(
                color: _coral,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainerDetail(Map<String, dynamic> s) {
    final name = s['name'] as String;
    final portrait = s['portrait'] as int?;
    final total = s['total'] as int;
    final count = s['count'] as int;
    // Get all sessions for this trainer
    final sessions =
        controller.transactions
            .where((t) => t['title'] == 'Session — $name')
            .toList();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Avatar + name row
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _neon.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _neon.withOpacity(0.25)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        portrait != null
                            ? Image.network(
                              'https://randomuser.me/api/portraits/men/$portrait.jpg',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    CupertinoIcons.person_fill,
                                    color: _neon,
                                    size: 26,
                                  ),
                            )
                            : const Icon(
                              CupertinoIcons.person_fill,
                              color: _neon,
                              size: 26,
                            ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count session${count > 1 ? 's' : ''} · Total paid: \$$total',
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: _stroke),
            const SizedBox(height: 16),
            // Session breakdown
            ...sessions.map((t) {
              final amount = (t['amount'] as int).abs();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _coral.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.creditcard_fill,
                        color: _coral,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Session Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            t['date'] as String,
                            style: const TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-\$$amount',
                      style: const TextStyle(
                        color: _coral,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── Full Transaction List ────────────────────────────────────────────────
  Widget _buildFullList() {
    final allTxs = controller.transactions;
    // In wallet-only mode show only deposits (credit) and withdrawals (non-session debits)
    final txs =
        _walletOnly
            ? allTxs
                .where(
                  (t) =>
                      t['type'] == 'credit' ||
                      !(t['title'] as String).startsWith('Session'),
                )
                .toList()
            : allTxs;

    final label = _walletOnly ? 'Deposits & Withdrawals' : 'All Transactions';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(color: _muted, fontSize: 14),
                ),
              ),
            )
          else
            ...txs.map((t) => _buildTxRow(t)),
        ],
      ),
    );
  }

  Widget _buildTxRow(Map<String, dynamic> t) {
    final isCredit = t['type'] == 'credit';
    final isSession = !isCredit && (t['title'] as String).startsWith('Session');
    final amount = (t['amount'] as int).abs();
    final portrait = t['portrait'] as int?;

    return GestureDetector(
      onTap: () => _showTxDetail(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _stroke),
        ),
        child: Row(
          children: [
            // Avatar / icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isCredit ? _neon : _coral).withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child:
                  isSession && portrait != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          'https://randomuser.me/api/portraits/men/$portrait.jpg',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                CupertinoIcons.arrow_up_circle_fill,
                                color: _coral,
                                size: 20,
                              ),
                        ),
                      )
                      : Icon(
                        isCredit
                            ? CupertinoIcons.arrow_down_circle_fill
                            : CupertinoIcons.arrow_up_circle_fill,
                        color: isCredit ? _neon : _coral,
                        size: 20,
                      ),
            ),
            const SizedBox(width: 12),
            // Title + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t['date'] as String,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${isCredit ? '+' : '-'}\$$amount',
              style: TextStyle(
                color: isCredit ? _neon : _coral,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTxDetail(Map<String, dynamic> t) {
    final isCredit = t['type'] == 'credit';
    final isSession = !isCredit && (t['title'] as String).startsWith('Session');
    final isWithdrawal = !isCredit && (t['title'] as String) == 'Withdrawal';
    final amount = (t['amount'] as int).abs();
    final portrait = t['portrait'] as int?;
    final accent = isCredit ? _neon : _coral;
    final title = t['title'] as String;
    final dateStr = t['date'] as String;

    // Deterministic reference number from transaction data
    final rawSeed = '$amount$dateStr$title'.hashCode.abs();
    final ref = '100${(rawSeed % 10000000000).toString().padLeft(10, '0')}';

    final fromLabel = isCredit ? 'Bank Account' : 'My Wallet';
    final toLabel =
        isSession
            ? title.replaceFirst('Session — ', '')
            : isCredit
            ? 'My Wallet'
            : 'Bank Account';
    final statusLabel = isWithdrawal ? 'Processing' : 'Completed';
    final statusColor = isWithdrawal ? const Color(0xFF5CE8FF) : _neon;

    // Initials for avatar fallback
    final initials =
        toLabel
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase();

    Widget avatar = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withOpacity(0.35), width: 2),
      ),
      child:
          isSession && portrait != null
              ? ClipOval(
                child: Image.network(
                  'https://randomuser.me/api/portraits/men/$portrait.jpg',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                ),
              )
              : isSession
              ? Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              )
              : Icon(
                isCredit
                    ? CupertinoIcons.arrow_down_circle_fill
                    : isWithdrawal
                    ? CupertinoIcons.arrow_up_circle_fill
                    : CupertinoIcons.creditcard_fill,
                color: accent,
                size: 26,
              ),
    );

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────────────────────────────────
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // ── Header: avatar + amount (bank receipt style) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Avatar with debit badge overlay
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      avatar,
                      if (!isCredit)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _coral,
                              shape: BoxShape.circle,
                              border: Border.all(color: _card, width: 2),
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_up,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isCredit ? '+' : '-'}\$$amount.00',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Dashed receipt tear line with notch circles ───────────────
            SizedBox(
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final count = (constraints.maxWidth / 10).floor();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            count,
                            (_) => Container(
                              width: 5,
                              height: 1.5,
                              color: _stroke,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Left notch
                  Positioned(
                    left: -12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: _ink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Right notch
                  Positioned(
                    right: -12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: _ink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Receipt detail rows ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
              child: Column(
                children: [
                  _receiptRow('Reference #', ref),
                  _receiptDivider(),
                  _receiptRow('From', fromLabel),
                  _receiptDivider(),
                  _receiptRow('Original amount', '\$$amount.00'),
                  _receiptDivider(),
                  _receiptRow('To', toLabel),
                  _receiptDivider(),
                  _receiptRow('Transaction date', dateStr),
                  _receiptDivider(),
                  _receiptRow('Status', statusLabel, valueColor: statusColor),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _receiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptDivider() =>
      Container(height: 1, color: _stroke.withOpacity(0.5));
}
