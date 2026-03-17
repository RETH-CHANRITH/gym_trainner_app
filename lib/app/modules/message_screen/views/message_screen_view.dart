import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const Color ink = Color(0xFF0A0A0F);
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
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _showExtras = false;

  // Trainer info passed via Get.arguments
  late final Map<String, dynamic> _trainer;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _trainer = args;
    } else {
      _trainer = {
        'name': 'Alex Carter',
        'specialty': 'Strength Coach',
        'portrait': 10,
        'online': true,
      };
    }
  }

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          "Hi! Ready for today's workout? Let me know if you have any questions!",
      'isMe': false,
      'time': '9:00 AM',
      'status': null,
    },
    {
      'text': "Hi Coach! Should I eat before or after my morning workout?",
      'isMe': true,
      'time': '9:02 AM',
      'status': 'read',
    },
    {
      'text':
          "A light snack before can help with energy — depends on your goals. Let's discuss!",
      'isMe': false,
      'time': '9:04 AM',
      'status': null,
    },
    {
      'text': "That makes sense. What do you recommend for a 6am session?",
      'isMe': true,
      'time': '9:05 AM',
      'status': 'read',
    },
    {
      'text': "Banana + peanut butter 30min before. Simple, effective 💪",
      'isMe': false,
      'time': '9:07 AM',
      'status': null,
    },
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': 'Now',
        'status': 'sent',
      });
      _controller.clear();
      _showExtras = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients)
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSessionBanner(),
            Expanded(child: _buildList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final trainerName = _trainer['name'] as String? ?? 'Alex Carter';
    final portrait = _trainer['portrait'] as int? ?? 10;
    final isOnline = _trainer['online'] as bool? ?? true;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: raised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white70,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: neon, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://randomuser.me/api/portraits/men/$portrait.jpg',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: raised,
                          child: const Icon(
                            CupertinoIcons.sportscourt,
                            color: neon,
                            size: 20,
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: isOnline ? neon : muted,
                    shape: BoxShape.circle,
                    border: Border.all(color: ink, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trainerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? neon : muted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOnline ? 'Active now' : 'Offline',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _hBtn(CupertinoIcons.phone),
          const SizedBox(width: 8),
          _hBtn(CupertinoIcons.video_camera),
        ],
      ),
    );
  }

  Widget _hBtn(IconData icon) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: raised,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: Colors.white70, size: 19),
  );

  Widget _buildSessionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: neon.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: neon.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: neon.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              CupertinoIcons.sportscourt,
              color: neon,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Next session: Today at 6:00 AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Strength & HIIT · 60 min',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: neon,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'View',
              style: TextStyle(
                color: ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final msg = _messages[i];
        final isMe = msg['isMe'] as bool;
        final showAvatar =
            !isMe && (i == 0 || (_messages[i - 1]['isMe'] as bool));
        final isLast =
            i == _messages.length - 1 ||
            (_messages[i + 1]['isMe'] as bool) != isMe;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 14 : 3),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child:
                      showAvatar
                          ? Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: stroke),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                'https://randomuser.me/api/portraits/men/32.jpg',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: raised,
                                      child: const Icon(
                                        CupertinoIcons.person_fill,
                                        color: muted,
                                        size: 14,
                                      ),
                                    ),
                              ),
                            ),
                          )
                          : const SizedBox(width: 38),
                ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.68,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? neon : card,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(
                            isMe ? 18 : (isLast ? 4 : 18),
                          ),
                          bottomRight: Radius.circular(
                            isMe ? (isLast ? 4 : 18) : 18,
                          ),
                        ),
                        border: isMe ? null : Border.all(color: stroke),
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: TextStyle(
                          color: isMe ? ink : Colors.white,
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isLast) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            msg['time'] as String,
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                          if (isMe && msg['status'] != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              msg['status'] == 'read'
                                  ? CupertinoIcons.checkmark_alt
                                  : CupertinoIcons.checkmark,
                              color: msg['status'] == 'read' ? neon : muted,
                              size: 12,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showExtras)
            Container(
              height: 44,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    [
                          '👍 Sounds good!',
                          '⏰ What time?',
                          '💪 Ready!',
                          '🔥 Let\'s go!',
                        ]
                        .map(
                          (q) => GestureDetector(
                            onTap: () {
                              _controller.text = q.substring(3);
                              setState(() => _showExtras = false);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: stroke),
                              ),
                              child: Center(
                                child: Text(
                                  q,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: ink,
              border: Border(top: BorderSide(color: stroke)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showExtras = !_showExtras),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _showExtras ? neon.withOpacity(0.15) : raised,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            _showExtras
                                ? neon.withOpacity(0.4)
                                : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      _showExtras ? CupertinoIcons.xmark : CupertinoIcons.add,
                      color: _showExtras ? neon : Colors.white70,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      maxHeight: 110,
                    ),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: stroke),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message ${_trainer['name'] ?? 'trainer'}...',
                        hintStyle: TextStyle(color: muted, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: neon,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      color: ink,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
