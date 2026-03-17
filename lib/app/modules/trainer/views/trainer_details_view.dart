import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../controllers/trainer_details_controller.dart';
import '../../../services/favourites_service.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────
const Color ink = Color(0xFF0A0A0F);
const Color card = Color(0xFF17171F);
const Color raised = Color(0xFF1E1E28);
const Color stroke = Color(0xFF2A2A36);
const Color neon = Color(0xFFCBFF47);
const Color coral = Color(0xFFFF5C5C);
const Color sky = Color(0xFF5CE8FF);
const Color lilac = Color(0xFFA78BFA);
const Color muted = Color(0xFF6B6B7E);

class TrainerDetailsView extends GetView<TrainerDetailsController> {
  const TrainerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final name = controller.trainerName.value;
            final spec = controller.specialty.value;
            final rat = controller.rating.value;
            final reviews = controller.reviewCount.value;
            final description =
                controller.bio.value.trim().isNotEmpty
                    ? controller.bio.value.trim()
                    : '$name is a certified trainer with 10+ years of experience '
                        'helping clients achieve their fitness goals. Passionate about '
                        '${spec.isNotEmpty ? spec.toLowerCase() : 'fitness'}, nutrition, and holistic health.';
            const int age = 29;
            const double ht = 1.82;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(context, name, spec, rat, reviews),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildStatsRow(age, ht, rat, reviews),
                      const SizedBox(height: 24),
                      _buildAbout(description),
                      const SizedBox(height: 20),
                      _buildCertifications(),
                      const SizedBox(height: 20),
                      _buildScheduleSection(),
                      const SizedBox(height: 20),
                      _buildRecentPostsSection(),
                      const SizedBox(height: 24),
                      _buildActions(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero(
    BuildContext context,
    String name,
    String specialty,
    double rating,
    int reviewCount,
  ) {
    final heroUrl =
        controller.imageUrl.value.isNotEmpty
            ? controller.imageUrl.value
            : 'https://randomuser.me/api/portraits/men/${controller.portrait.value}.jpg';

    return Stack(
      children: [
        // Background photo
        SizedBox(
          height: 320,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: heroUrl,
            fit: BoxFit.cover,
            memCacheWidth: 1080,
            memCacheHeight: 640,
            fadeInDuration: const Duration(milliseconds: 140),
            errorWidget: (_, __, ___) => _heroFallback(),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, ink.withValues(alpha: 0.5), ink],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: 12,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ink.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stroke),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        // Favourite button
        Positioned(
          top: 12,
          right: 16,
          child: Obx(() {
            final favSvc = Get.find<FavouritesService>();
            final trainerMap = {
              'name': controller.trainerName.value,
              'specialty': controller.specialty.value,
              'rating': controller.rating.value,
              'price': controller.pricePerHour.value,
              'sessions': controller.sessions.value,
              'portrait': controller.portrait.value,
              'available': controller.isAvailable.value,
              'isAvailable': controller.isAvailable.value,
              'image': controller.imageUrl.value,
            };
            final isFav = favSvc.isFavourite(controller.trainerName.value);
            return GestureDetector(
              onTap: () => favSvc.toggle(trainerMap),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isFav ? coral : stroke),
                ),
                child: Icon(
                  isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: isFav ? coral : Colors.white,
                  size: 18,
                ),
              ),
            );
          }),
        ),
        // Name block at bottom
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
                        color: controller.isAvailable.value ? neon : raised,
                        borderRadius: BorderRadius.circular(7),
                        border:
                            controller.isAvailable.value
                                ? null
                                : Border.all(color: stroke),
                      ),
                      child: Text(
                        controller.isAvailable.value
                            ? 'Available'
                            : 'Unavailable',
                        style: TextStyle(
                          color: controller.isAvailable.value ? ink : muted,
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
                      specialty,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: stroke),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.star_fill, color: neon, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviewCount)',
                      style: TextStyle(color: muted, fontSize: 12),
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

  Widget _heroFallback() => Container(
    color: raised,
    child: const Center(
      child: Icon(CupertinoIcons.person_fill, color: muted, size: 80),
    ),
  );

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow(int age, double height, double rating, int reviews) {
    return Row(
      children: [
        _statChip(CupertinoIcons.gift, '$age yrs', 'Age', coral),
        const SizedBox(width: 12),
        _statChip(
          CupertinoIcons.resize_v,
          '${height.toStringAsFixed(2)}m',
          'Height',
          sky,
        ),
        const SizedBox(width: 12),
        _statChip(CupertinoIcons.person_3, '$reviews+', 'Clients', lilac),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: stroke),
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
            Text(label, style: TextStyle(color: muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────────────────────
  Widget _buildAbout(String description) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ── Certifications ────────────────────────────────────────────────────────
  Widget _buildCertifications() {
    final dynamicSpecializations = controller.specializations.toList();
    final dynamicLanguages = controller.languages.toList();

    final certs = [
      {
        'icon': CupertinoIcons.checkmark_seal,
        'label':
            dynamicSpecializations.isNotEmpty
                ? dynamicSpecializations.first
                : 'Certified Personal Trainer (CPT)',
        'color': neon,
      },
      {
        'icon': CupertinoIcons.timer,
        'label': '10+ years experience',
        'color': sky,
      },
      {
        'icon': CupertinoIcons.cart,
        'label':
            dynamicLanguages.isNotEmpty
                ? 'Speaks: ${dynamicLanguages.take(2).join(', ')}'
                : 'Nutrition Specialist',
        'color': coral,
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        ...certs.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: stroke),
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

  // ── Schedule ──────────────────────────────────────────────────────────────
  Widget _buildScheduleSection() {
    final dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dynamicMap = controller.availability;

    final schedule =
        dayOrder.map((day) {
          final item =
              dynamicMap[day] ??
              {'enabled': false, 'start': '09:00', 'end': '18:00'};
          return {
            'day': day,
            'enabled': item['enabled'] == true,
            'start': (item['start'] ?? '09:00').toString(),
            'end': (item['end'] ?? '18:00').toString(),
          };
        }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Schedule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            Text('This week', style: TextStyle(color: muted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              schedule.map((item) {
                final enabled = item['enabled'] == true;
                return Container(
                  width: 94,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: enabled ? neon.withValues(alpha: 0.08) : card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: enabled ? neon.withValues(alpha: 0.28) : stroke,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['day'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        enabled ? 'Open' : 'Off',
                        style: TextStyle(
                          color: enabled ? neon : muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (enabled) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${item['start']} - ${item['end']}',
                          style: TextStyle(color: muted, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentPostsSection() {
    return Obx(() {
      final posts = controller.recentPosts;
      if (posts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Posts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...posts.take(3).map((post) {
            final title = (post['title'] ?? '').toString();
            final caption = (post['caption'] ?? '').toString();
            final imageUrl = (post['imageUrl'] ?? '').toString();
            final category = (post['category'] ?? 'Workout').toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: sky.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: sky,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (title.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (caption.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (imageUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: 720,
                          memCacheHeight: 240,
                          fadeInDuration: const Duration(milliseconds: 120),
                          errorWidget:
                              (_, __, ___) => Container(
                                height: 120,
                                color: raised,
                                alignment: Alignment.center,
                                child: const Icon(
                                  CupertinoIcons.photo,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Book button
        GestureDetector(
          onTap:
              controller.isAvailable.value
                  ? () => Get.toNamed(
                    '/book-session',
                    arguments: {
                      'name': controller.trainerName.value,
                      'specialty': controller.specialty.value,
                      'portrait': controller.portrait.value,
                      'price': controller.pricePerHour.value,
                    },
                  )
                  : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: controller.isAvailable.value ? neon : raised,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                controller.isAvailable.value ? 'Book a Session' : 'Unavailable',
                style: TextStyle(
                  color: controller.isAvailable.value ? ink : muted,
                  fontSize: 15,
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
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: stroke),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.chat_bubble,
                        color: Colors.white70,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      const Text(
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Write Review coming soon!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: stroke),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.star,
                        color: Colors.white70,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      const Text(
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
      ],
    );
  }
}
