import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as sc;
import '../../../services/favourites_service.dart';

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

class SearchView extends GetView<sc.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildSpecialtyChips(),
            const SizedBox(height: 16),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 24, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stroke),
              ),
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Trainers',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                Obx(() {
                  final trainerCount = controller.filtered.length;
                  final postCount = controller.filteredPosts.length;
                  return Text(
                    '$trainerCount trainers • $postCount posts',
                    style: TextStyle(color: muted, fontSize: 13),
                  );
                }),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: stroke),
              ),
              child: const Icon(
                CupertinoIcons.slider_horizontal_3,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: controller.setQuery,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by name or specialty…',
          hintStyle: TextStyle(color: muted),
          prefixIcon: Icon(CupertinoIcons.search, color: muted, size: 20),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: stroke),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: stroke),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: neon, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyChips() {
    return SizedBox(
      height: 38,
      child: Obx(() {
        // Capture value synchronously inside Obx so dependency is registered
        final activeSpec = controller.selectedSpecialty.value;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: controller.specialties.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final spec = controller.specialties[i];
            final active = activeSpec == spec;
            return GestureDetector(
              onTap: () => controller.setSpecialty(spec),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? neon : card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? neon : stroke,
                    width: active ? 2 : 1,
                  ),
                ),
                child: Text(
                  spec,
                  style: TextStyle(
                    color: active ? ink : muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildResults() {
    return Obx(() {
      final trainers = controller.filtered;
      final posts = controller.filteredPosts;

      if (controller.isLoading.value && trainers.isEmpty && posts.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: neon));
      }

      if (trainers.isEmpty && posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.search, color: muted, size: 52),
              const SizedBox(height: 14),
              Text(
                'No trainers or posts match your search',
                style: TextStyle(color: muted, fontSize: 15),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: trainers.length + posts.length + 2,
        itemBuilder: (_, i) {
          if (i == 0) {
            return _buildSectionTitle('Trainers', trainers.length);
          }

          final trainerEnd = 1 + trainers.length;
          if (i < trainerEnd) {
            return _buildTrainerCard(trainers[i - 1]);
          }

          if (i == trainerEnd) {
            return _buildSectionTitle('Trainer Posts', posts.length);
          }

          return _buildPostCard(posts[i - trainerEnd - 1]);
        },
      );
    });
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text('($count)', style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTrainerCard(Map<String, dynamic> t) {
    final isAvailable = t['isAvailable'] == true;
    final trainerImage = (t['image'] ?? '').toString();
    final favSvc = Get.find<FavouritesService>();
    final trainerName = (t['name'] ?? 'Trainer').toString();
    return GestureDetector(
      onTap: () => Get.toNamed('/trainer-details', arguments: t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAvailable ? stroke : stroke),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child:
                        trainerImage.isNotEmpty
                            ? Image.network(
                              trainerImage,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: raised,
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      color: neon,
                                      size: 28,
                                    ),
                                  ),
                            )
                            : Container(
                              color: raised,
                              child: const Icon(
                                CupertinoIcons.person_fill,
                                color: neon,
                                size: 28,
                              ),
                            ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (t['specialty'] ?? 'Personal Training').toString(),
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: neon,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${t['rating'] ?? 0}',
                        style: const TextStyle(
                          color: neon,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: sky,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${t['sessions'] ?? 0} sessions',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '\$${t['price'] ?? t['pricePerHour'] ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text('/session', style: TextStyle(color: muted, fontSize: 11)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: neon,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Book',
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final isFav = favSvc.isFavourite(trainerName);
                  return GestureDetector(
                    onTap: () => favSvc.toggle(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isFav ? coral.withValues(alpha: 0.15) : raised,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFav ? coral : stroke,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isFav
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isFav ? coral : muted,
                        size: 16,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final trainerName =
        (post['trainerName'] ?? post['authorName'] ?? 'Trainer').toString();
    final title = (post['title'] ?? '').toString().trim();
    final caption = (post['caption'] ?? '').toString().trim();
    final category = (post['category'] ?? 'Workout').toString();
    final imageUrl = (post['imageUrl'] ?? '').toString();
    final likes = post['likesCount'] ?? 0;
    final comments = post['commentsCount'] ?? 0;
    final tags =
        (post['tags'] is List)
            ? (post['tags'] as List)
                .map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];

    return GestureDetector(
      onTap: () => controller.openTrainerFromPost(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: sky.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: sky.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: sky,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  trainerName,
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (title.isNotEmpty)
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            if (title.isNotEmpty) const SizedBox(height: 6),
            Text(
              caption.isNotEmpty ? caption : 'Trainer update',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: raised,
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    tags
                        .take(4)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: lilac.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: lilac.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                color: lilac,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$likes likes',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(width: 14),
                Text(
                  '$comments comments',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const Spacer(),
                const Text(
                  'Open Trainer',
                  style: TextStyle(
                    color: neon,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.chevron_right, color: neon, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
