import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────
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

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  int _tabIndex = 0;
  final _tabs = [
    {'label': 'All', 'icon': CupertinoIcons.chat_bubble_2},
    {'label': 'Unread', 'icon': CupertinoIcons.envelope_badge},
    {'label': 'Online', 'icon': CupertinoIcons.circle},
  ];

  static const List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Alex Carter',
      'specialty': 'Strength Coach',
      'message': 'Ready for today\'s HIIT session?',
      'time': '2m',
      'unread': 2,
      'online': true,
      'portrait': 10,
    },
    {
      'name': 'Jordan Miles',
      'specialty': 'Yoga Instructor',
      'message': 'Great progress on flexibility!',
      'time': '1h',
      'unread': 1,
      'online': true,
      'portrait': 11,
    },
    {
      'name': 'Sam Rivera',
      'specialty': 'Boxing Coach',
      'message': 'See you tomorrow at 7am',
      'time': '3h',
      'unread': 0,
      'online': false,
      'portrait': 12,
    },
    {
      'name': 'Chris Lee',
      'specialty': 'Powerlifting',
      'message': 'Your form looked great today',
      'time': '1d',
      'unread': 0,
      'online': true,
      'portrait': 13,
    },
    {
      'name': 'Priya Shah',
      'specialty': 'Pilates Expert',
      'message': 'Don\'t forget to hydrate!',
      'time': '2d',
      'unread': 0,
      'online': false,
      'portrait': 47,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_tabIndex == 1)
      return _conversations.where((c) => (c['unread'] as int) > 0).toList();
    if (_tabIndex == 2)
      return _conversations.where((c) => c['online'] == true).toList();
    return _conversations;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _conversations.where((c) => (c['unread'] as int) > 0).length;
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(unreadCount),
            const SizedBox(height: 24),
            _buildTabs(),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: _filtered.length,
                        itemBuilder:
                            (context, index) =>
                                _buildConversationCard(_filtered[index], index),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sky.withOpacity(0.2), sky.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sky.withOpacity(0.3)),
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_fill,
              color: sky,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_conversations.length} conversations',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: coral.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: coral.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$unreadCount new',
                    style: const TextStyle(
                      color: coral,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? neon : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _tabs[i]['icon'] as IconData,
                      color: active ? ink : muted,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tabs[i]['label'] as String,
                      style: TextStyle(
                        color: active ? ink : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: Icon(CupertinoIcons.chat_bubble, color: muted, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'No messages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with a trainer',
            style: TextStyle(color: muted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conv, int index) {
    final int unread = conv['unread'] as int;
    final bool isOnline = conv['online'] as bool;
    final bool hasUnread = unread > 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient:
              hasUnread
                  ? LinearGradient(
                    colors: [neon.withOpacity(0.08), card],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                  : null,
          color: hasUnread ? null : card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: hasUnread ? neon.withOpacity(0.3) : stroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.toNamed('/message-screen', arguments: conv),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient:
                              isOnline
                                  ? LinearGradient(
                                    colors: [neon, neon.withOpacity(0.5)],
                                  )
                                  : LinearGradient(
                                    colors: [stroke, stroke.withOpacity(0.5)],
                                  ),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Image.network(
                              'https://randomuser.me/api/portraits/men/${conv['portrait']}.jpg',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: raised,
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      color: muted,
                                      size: 24,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: card,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isOnline ? neon : muted,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conv['name'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight:
                                      hasUnread
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              conv['time'] as String,
                              style: TextStyle(
                                color: hasUnread ? neon : muted,
                                fontSize: 11,
                                fontWeight:
                                    hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conv['specialty'] as String,
                          style: TextStyle(color: muted, fontSize: 11),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conv['message'] as String,
                                style: TextStyle(
                                  color: hasUnread ? Colors.white : muted,
                                  fontSize: 13,
                                  fontWeight:
                                      hasUnread
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: neon,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(
                                      color: ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
