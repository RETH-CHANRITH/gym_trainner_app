import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/favourites_service.dart';

// ─── Design Tokens ──────────────────────────────────────────────────────────
const Color _ink = Color(0xFF0A0A0F);
const Color _surface = Color(0xFF111118);
const Color _card = Color(0xFF17171F);
const Color _raised = Color(0xFF1E1E28);
const Color _stroke = Color(0xFF2A2A36);
const Color _neon = Color(0xFFCBFF47);
const Color _coral = Color(0xFFFF5C5C);
const Color _muted = Color(0xFF6B6B7E);

// ─── Studio sessions (in-person) ─────────────────────────────────────────────
final List<Map<String, dynamic>> _studioSessions = [
  {
    'trainer': 'Alex Carter',
    'specialty': 'Strength & HIIT',
    'date': 'Mon, Mar 16, 2026',
    'time': '07:00 AM',
    'type': '1-on-1',
    'status': 'open',
    'portrait': 10,
    'price': 65,
    'spots': 1,
    'rating': 4.9,
    'sessions': 120,
    'isAvailable': true,
  },
  {
    'trainer': 'Jordan Miles',
    'specialty': 'Yoga & Mobility',
    'date': 'Tue, Mar 17, 2026',
    'time': '09:00 AM',
    'type': 'Group',
    'status': 'open',
    'portrait': 11,
    'price': 35,
    'spots': 8,
    'rating': 4.7,
    'sessions': 89,
    'isAvailable': true,
  },
  {
    'trainer': 'Priya Shah',
    'specialty': 'Pilates & Core',
    'date': 'Wed, Mar 18, 2026',
    'time': '08:00 AM',
    'type': 'Group',
    'status': 'open',
    'portrait': 47,
    'price': 40,
    'spots': 5,
    'rating': 4.8,
    'sessions': 74,
    'isAvailable': true,
  },
  {
    'trainer': 'Marcus Bell',
    'specialty': 'Powerlifting',
    'date': 'Thu, Mar 19, 2026',
    'time': '06:00 PM',
    'type': '1-on-1',
    'status': 'open',
    'portrait': 15,
    'price': 55,
    'spots': 1,
    'rating': 4.8,
    'sessions': 89,
    'isAvailable': true,
  },
  {
    'trainer': 'Chris Lee',
    'specialty': 'CrossFit',
    'date': 'Sat, Mar 21, 2026',
    'time': '07:30 AM',
    'type': 'Group',
    'status': 'full',
    'portrait': 13,
    'price': 50,
    'spots': 0,
    'rating': 4.7,
    'sessions': 63,
    'isAvailable': false,
  },
  {
    'trainer': 'Ryan Torres',
    'specialty': 'Functional Training',
    'date': 'Tue, Mar 24, 2026',
    'time': '08:00 AM',
    'type': '1-on-4',
    'status': 'open',
    'portrait': 63,
    'price': 70,
    'spots': 2,
    'rating': 4.6,
    'sessions': 51,
    'isAvailable': true,
  },
  {
    'trainer': 'Dana Kim',
    'specialty': 'Mobility & Stretch',
    'date': 'Wed, Mar 25, 2026',
    'time': '10:00 AM',
    'type': '1-on-4',
    'status': 'open',
    'portrait': 55,
    'price': 45,
    'spots': 3,
    'rating': 4.5,
    'sessions': 38,
    'isAvailable': true,
  },
];

// ─── Online sessions ──────────────────────────────────────────────────────────
final List<Map<String, dynamic>> _onlineSessions = [
  {
    'trainer': 'Sam Rivera',
    'specialty': 'Cardio & Boxing',
    'date': 'Fri, Mar 20, 2026',
    'time': '05:30 PM',
    'type': 'Video',
    'status': 'open',
    'portrait': 12,
    'price': 45,
    'spots': 10,
    'rating': 4.6,
    'sessions': 58,
    'isAvailable': true,
    'youtubeId': 'UItWltVZZmE',
    'youtubeChannel': 'https://www.youtube.com/@SamRiveraFitness',
  },
  {
    'trainer': 'Maya Patel',
    'specialty': 'Nutrition & Wellness',
    'date': 'Mon, Mar 23, 2026',
    'time': '11:00 AM',
    'type': 'Video',
    'status': 'open',
    'portrait': 44,
    'price': 30,
    'spots': 12,
    'rating': 4.9,
    'sessions': 103,
    'isAvailable': true,
    'youtubeId': 'sTANio_2E0Q',
    'youtubeChannel': 'https://www.youtube.com/@MayaPatelWellness',
  },
  {
    'trainer': 'Alex Carter',
    'specialty': 'Strength & HIIT',
    'date': 'Fri, Mar 27, 2026',
    'time': '06:00 AM',
    'type': '1-on-1',
    'status': 'open',
    'portrait': 10,
    'price': 55,
    'spots': 1,
    'rating': 4.9,
    'sessions': 120,
    'isAvailable': true,
  },
  {
    'trainer': 'Jordan Miles',
    'specialty': 'Yoga & Mobility',
    'date': 'Sat, Mar 28, 2026',
    'time': '08:00 AM',
    'type': '1-on-2',
    'status': 'open',
    'portrait': 11,
    'price': 40,
    'spots': 1,
    'rating': 4.7,
    'sessions': 89,
    'isAvailable': true,
  },
  {
    'trainer': 'Priya Shah',
    'specialty': 'Pilates & Core',
    'date': 'Sun, Mar 29, 2026',
    'time': '09:00 AM',
    'type': '1-on-4',
    'status': 'open',
    'portrait': 47,
    'price': 25,
    'spots': 3,
    'rating': 4.8,
    'sessions': 74,
    'isAvailable': true,
  },
  {
    'trainer': 'Marcus Bell',
    'specialty': 'Powerlifting',
    'date': 'Mon, Mar 30, 2026',
    'time': '07:00 PM',
    'type': '1-on-2',
    'status': 'full',
    'portrait': 15,
    'price': 50,
    'spots': 0,
    'rating': 4.8,
    'sessions': 89,
    'isAvailable': false,
  },
];

class AllSessionsView extends StatefulWidget {
  const AllSessionsView({super.key});

  @override
  State<AllSessionsView> createState() => _AllSessionsViewState();
}

class _AllSessionsViewState extends State<AllSessionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Studio filter chips
  final List<String> _studioTypes = ['All', '1-on-1', '1-on-4', 'Group'];
  int _selectedStudioType = 0;

  // Online filter chips
  final List<String> _onlineTypes = [
    'All',
    'Video',
    '1-on-1',
    '1-on-2',
    '1-on-4',
  ];
  int _selectedOnlineType = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'All Sessions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _stroke, width: 1.2),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _neon,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: _neon.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: _ink,
              unselectedLabelColor: _muted,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(height: 42, text: 'Studio'),
                Tab(height: 42, text: 'Online'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: _ink,
        child: TabBarView(
          controller: _tabController,
          children: [_buildStudioTab(), _buildOnlineTab()],
        ),
      ),
    );
  }

  // ─── Studio Tab ────────────────────────────────────────────────────────────
  Widget _buildStudioTab() {
    return Container(
      color: _ink,
      child: Column(
        children: [
          _buildFilterChips(
            chips: _studioTypes,
            selected: _selectedStudioType,
            onSelect: (i) => setState(() => _selectedStudioType = i),
          ),
          Expanded(
            child: _buildSessionList(
              _studioSessions,
              _studioTypes,
              _selectedStudioType,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Online Tab ────────────────────────────────────────────────────────────
  Widget _buildOnlineTab() {
    return Container(
      color: _ink,
      child: Column(
        children: [
          _buildFilterChips(
            chips: _onlineTypes,
            selected: _selectedOnlineType,
            onSelect: (i) => setState(() => _selectedOnlineType = i),
          ),
          Expanded(
            child: _buildSessionList(
              _onlineSessions,
              _onlineTypes,
              _selectedOnlineType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips({
    required List<String> chips,
    required int selected,
    required ValueChanged<int> onSelect,
  }) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        itemBuilder: (_, i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: active ? _neon : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _neon : _stroke),
              ),
              child: Center(
                child: Text(
                  chips[i],
                  style: TextStyle(
                    color: active ? _ink : _muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionList(
    List<Map<String, dynamic>> sessions,
    List<String> types,
    int selectedIndex,
  ) {
    final filtered =
        selectedIndex == 0
            ? sessions
            : sessions.where((s) => s['type'] == types[selectedIndex]).toList();

    if (filtered.isEmpty) {
      return Container(
        color: _ink,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.calendar_badge_minus,
                color: _muted,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                'No sessions available',
                style: TextStyle(color: _muted, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildAvailableCard(filtered[i]),
    );
  }

  Widget _buildAvailableCard(Map<String, dynamic> s) {
    final isOpen = s['status'] == 'open';
    final spots = s['spots'] as int;
    final statusColor = isOpen ? _neon : _coral;

    return GestureDetector(
      onTap: () {
        if (s['type'] == 'Video') {
          _showVideoDetail(s);
        } else {
          Get.toNamed(
            '/trainer-details',
            arguments: {
              'name': s['trainer'],
              'specialty': s['specialty'],
              'rating': s['rating'] ?? 4.5,
              'sessions': s['sessions'] ?? 0,
              'portrait': s['portrait'],
              'price': s['price'],
              'isAvailable': s['isAvailable'] ?? (s['status'] == 'open'),
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Portrait
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _neon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _neon.withValues(alpha: 0.25)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://randomuser.me/api/portraits/men/${s['portrait']}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            CupertinoIcons.person_fill,
                            color: _neon,
                            size: 22,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + specialty
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['trainer'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        s['specialty'] as String,
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    isOpen ? 'Open' : 'Full',
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
            Container(height: 1, color: _stroke),
            const SizedBox(height: 12),
            // Info chips row
            Row(
              children: [
                _infoChip(CupertinoIcons.calendar, s['date'] as String),
                const SizedBox(width: 14),
                _infoChip(CupertinoIcons.clock, s['time'] as String),
                const SizedBox(width: 14),
                _infoChip(CupertinoIcons.person_2, s['type'] as String),
              ],
            ),
            const SizedBox(height: 14),
            // Price + spots row + Book button
            Row(
              children: [
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${s['price']}/session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      isOpen
                          ? (spots == 1 ? '1 spot left' : '$spots spots left')
                          : 'No spots left',
                      style: TextStyle(
                        color: isOpen ? _neon : _coral,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Book button
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed:
                        isOpen
                            ? () => Get.toNamed(
                              '/book-session',
                              arguments: {
                                'name': s['trainer'],
                                'specialty': s['specialty'],
                                'portrait': s['portrait'],
                                'price': s['price'],
                              },
                            )
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOpen ? _neon : _raised,
                      disabledBackgroundColor: _raised,
                      foregroundColor: _ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      elevation: 0,
                    ),
                    child: Text(
                      isOpen ? 'Book Session' : 'Full',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isOpen ? _ink : _muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoDetail(Map<String, dynamic> s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _VideoDetailPage(session: s)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _muted, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video Session Detail — full-screen page matching trainer_details_view style
// ─────────────────────────────────────────────────────────────────────────────
class _VideoDetailPage extends StatefulWidget {
  const _VideoDetailPage({required this.session});
  final Map<String, dynamic> session;

  @override
  State<_VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<_VideoDetailPage> {
  Map<String, dynamic> get session => widget.session;

  // design tokens (mirrors trainer_details_view)
  static const Color _ink = Color(0xFF0A0A0F);
  static const Color _card = Color(0xFF17171F);
  static const Color _raised = Color(0xFF1E1E28);
  static const Color _stroke = Color(0xFF2A2A36);
  static const Color _neon = Color(0xFFCBFF47);
  static const Color _coral = Color(0xFFFF5C5C);
  static const Color _sky = Color(0xFF5CE8FF);
  static const Color _lilac = Color(0xFFA78BFA);
  static const Color _muted = Color(0xFF6B6B7E);

  Future<void> _openYouTube(String url, String fallback) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(Uri.parse(fallback), mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = session;
    final isOpen = s['status'] == 'open';
    final spots = s['spots'] as int;
    final portrait = s['portrait'] as int;
    final name = s['trainer'] as String;
    final spec = s['specialty'] as String;
    final rat = (s['rating'] ?? 4.5) as num;
    final sessions = (s['sessions'] ?? 0) as int;
    final price = s['price'] as int;
    final youtubeId = s['youtubeId'] as String? ?? '';
    final youtubeChannel =
        s['youtubeChannel'] as String? ??
        'https://www.youtube.com/watch?v=$youtubeId';
    final thumbUrl = 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
    final ytVideoUrl = 'https://www.youtube.com/watch?v=$youtubeId';
    final description =
        '$name is a certified trainer with 10+ years of experience helping '
        'clients achieve their fitness goals. Passionate about '
        '${spec.toLowerCase()}, nutrition, and holistic health.';

    return Scaffold(
      backgroundColor: _ink,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero ──────────────────────────────────────────────────────
              _buildHero(context, name, spec, rat, sessions, portrait, isOpen),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // ── Stats ──────────────────────────────────────────────
                    _buildStatsRow(rat, sessions),
                    const SizedBox(height: 24),

                    // ── Session info chips ─────────────────────────────────
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _chip(CupertinoIcons.calendar, s['date'] as String),
                        _chip(CupertinoIcons.clock, s['time'] as String),
                        _chip(CupertinoIcons.play_rectangle, 'Video Session'),
                        _chip(
                          CupertinoIcons.money_dollar_circle,
                          '\$$price / session',
                        ),
                        _chip(
                          CupertinoIcons.person_2,
                          isOpen ? 'Open · $spots spots' : 'Session Full',
                          accent: isOpen ? _neon : _coral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── About ──────────────────────────────────────────────
                    _sectionTitle('About'),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── YouTube Video ──────────────────────────────────────
                    _sectionTitle('Trainer Video'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _openYouTube(ytVideoUrl, ytVideoUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Image.network(
                              thumbUrl,
                              height: 210,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 210,
                                    color: _raised,
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.play_circle,
                                        color: Colors.white38,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                            ),
                            // gradient
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.55),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // play button
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: _neon,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _neon.withValues(alpha: 0.55),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.play_fill,
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            // YouTube badge
                            Positioned(
                              left: 14,
                              bottom: 12,
                              child: Row(
                                children: [
                                  _YouTubeLogo(size: 20),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Trainer Video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Watch on YouTube — professional button
                    GestureDetector(
                      onTap: () => _openYouTube(youtubeChannel, ytVideoUrl),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0000),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF0000).withValues(alpha: 0.35),
                              blurRadius: 14,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _YouTubeLogo(size: 22),
                            const SizedBox(width: 10),
                            const Text(
                              'Watch on YouTube',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Certifications ────────────────────────────────────
                    _buildCertifications(),
                    const SizedBox(height: 24),

                    // ── Reviews ───────────────────────────────────────────
                    _buildReviews(name),
                    const SizedBox(height: 24),

                    // ── Schedule ──────────────────────────────────────────
                    _buildSchedule(),
                    const SizedBox(height: 28),

                    // ── Book + Message buttons ─────────────────────────────
                    GestureDetector(
                      onTap: isOpen ? () => Navigator.pop(context) : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        decoration: BoxDecoration(
                          color: isOpen ? _neon : _stroke,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow:
                              isOpen
                                  ? [
                                    BoxShadow(
                                      color: _neon.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                  : [],
                        ),
                        child: Center(
                          child: Text(
                            isOpen ? 'Book a Session' : 'Session Full',
                            style: TextStyle(
                              color: isOpen ? _ink : _muted,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Message button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _stroke),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    CupertinoIcons.chat_bubble,
                                    color: Colors.white70,
                                    size: 17,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Message',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Review button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _stroke),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    CupertinoIcons.star,
                                    color: Colors.white70,
                                    size: 17,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Review',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero(
    BuildContext context,
    String name,
    String spec,
    num rat,
    int sessions,
    int portrait,
    bool isOpen,
  ) {
    return Stack(
      children: [
        SizedBox(
          height: 320,
          width: double.infinity,
          child: Image.network(
            'https://randomuser.me/api/portraits/men/$portrait.jpg',
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  color: _raised,
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.person_fill,
                      color: _muted,
                      size: 80,
                    ),
                  ),
                ),
          ),
        ),
        // gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _ink.withValues(alpha: 0.5), _ink],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
        // back button
        Positioned(
          top: 12,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _ink.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _stroke),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        // favourite button
        Positioned(
          top: 12,
          right: 16,
          child: Builder(
            builder: (_) {
              final favSvc = Get.find<FavouritesService>();
              final trainerMap = {
                'name': session['trainer'],
                'specialty': session['specialty'],
                'rating': session['rating'] ?? 4.5,
                'price': session['price'],
                'sessions': session['sessions'] ?? 0,
                'portrait': session['portrait'],
                'available': session['status'] == 'open',
                'isAvailable': session['status'] == 'open',
                'image': '',
              };
              final isFav = favSvc.isFavourite(session['trainer'] as String);
              return GestureDetector(
                onTap: () {
                  favSvc.toggle(trainerMap);
                  setState(() {});
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _ink.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isFav ? _coral : _stroke),
                  ),
                  child: Icon(
                    isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: isFav ? _coral : Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ),
        // name block
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen ? _neon : _raised,
                        borderRadius: BorderRadius.circular(7),
                        border: isOpen ? null : Border.all(color: _stroke),
                      ),
                      child: Text(
                        isOpen ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: isOpen ? _ink : _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spec,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // rating pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _stroke),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.star_fill,
                      color: _neon,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rat.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($sessions)',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow(num rating, int sessions) {
    return Row(
      children: [
        _statCard(CupertinoIcons.gift, '29 yrs', 'Age', _coral),
        const SizedBox(width: 12),
        _statCard(CupertinoIcons.resize_v, '1.82m', 'Height', _sky),
        const SizedBox(width: 12),
        _statCard(CupertinoIcons.person_3, '$sessions+', 'Sessions', _lilac),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _stroke),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── Certifications ─────────────────────────────────────────────────────────
  Widget _buildCertifications() {
    final certs = [
      {
        'icon': CupertinoIcons.checkmark_seal,
        'label': 'Certified Personal Trainer (CPT)',
        'color': _neon,
      },
      {
        'icon': CupertinoIcons.timer,
        'label': '10+ years experience',
        'color': _sky,
      },
      {
        'icon': CupertinoIcons.cart,
        'label': 'Nutrition Specialist',
        'color': _coral,
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Certifications'),
        const SizedBox(height: 12),
        ...certs.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _stroke),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: (c['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      c['icon'] as IconData,
                      color: c['color'] as Color,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    c['label'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Schedule ───────────────────────────────────────────────────────────────
  Widget _buildSchedule() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const avail = [true, true, false, true, true, false, true];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Schedule'),
            Text('This week', style: TextStyle(color: _muted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (i) {
            final ok = avail[i];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  days[i],
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ok ? _neon.withValues(alpha: 0.1) : _raised,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ok ? _neon.withValues(alpha: 0.4) : _stroke,
                    ),
                  ),
                  child: Icon(
                    ok ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
                    color: ok ? _neon : _muted,
                    size: 16,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // ── Reviews ────────────────────────────────────────────────────────────────
  Widget _buildReviews(String trainerName) {
    final reviews = [
      {
        'name': 'Jessica L.',
        'portrait': 20,
        'rating': 5,
        'time': '2 days ago',
        'comment':
            'Amazing session! ${trainerName.split(' ')[0]} explains every move clearly and keeps the energy high. Highly recommend!',
      },
      {
        'name': 'Carlos M.',
        'portrait': 32,
        'rating': 4,
        'time': '1 week ago',
        'comment':
            'Great trainer, very motivating. The video quality is excellent and the workout was challenging but fun.',
      },
      {
        'name': 'Sophie K.',
        'portrait': 44,
        'rating': 5,
        'time': '2 weeks ago',
        'comment':
            'Best online session I\'ve had. Very professional and always on time. Will book again!',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Reviews'),
            Row(
              children: [
                const Icon(CupertinoIcons.star_fill, color: _neon, size: 14),
                const SizedBox(width: 4),
                Text(
                  '4.8  ·  ${reviews.length * 34} reviews',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...reviews.map(
          (r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/${r['portrait']}.jpg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < (r['rating'] as int)
                                    ? CupertinoIcons.star_fill
                                    : CupertinoIcons.star,
                                color:
                                    i < (r['rating'] as int) ? _neon : _stroke,
                                size: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      r['time'] as String,
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  r['comment'] as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
    ),
  );

  Widget _chip(
    IconData icon,
    String label, {
    Color accent = const Color(0xFFCBFF47),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _raised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Professional YouTube Logo Widget ─────────────────────────────────────────
class _YouTubeLogo extends StatelessWidget {
  const _YouTubeLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.42, size),
      painter: _YouTubeLogoPainter(),
    );
  }
}

class _YouTubeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bgPaint = Paint()..color = const Color(0xFFFF0000);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(h * 0.22),
    );
    canvas.drawRRect(rrect, bgPaint);

    final triPaint = Paint()..color = Colors.white;
    final triPath =
        Path()
          ..moveTo(w * 0.38, h * 0.23)
          ..lineTo(w * 0.38, h * 0.77)
          ..lineTo(w * 0.74, h * 0.50)
          ..close();
    canvas.drawPath(triPath, triPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
