import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../services/bookings_service.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bottom nav current index
  var currentIndex = 0.obs;

  // Selected category tab index
  var selectedCategoryIndex = 0.obs;

  // Search query
  var searchQuery = ''.obs;

  // Upcoming sessions count — derived reactively from the service list.
  int get upcomingSessionsCount => _bookings.upcomingBookings.length;

  // Unread messages count (for badge)
  var unreadMessagesCount = 3.obs;

  // Unread notifications count
  var unreadNotificationsCount = 5.obs;

  // Authenticated user info (real-time from Firebase)
  var userPhotoUrl = ''.obs;
  var userName = 'User'.obs;
  var userInitial = 'U'.obs;

  // Promotional offer (swap from backend / CMS in production)
  var promoLabel = '🔥 LIMITED TIME'.obs;
  var promoTitle = '20% Off\nFirst Session'.obs;
  var promoDiscount = '20\n%'.obs;
  var promoActive = true.obs;

  StreamSubscription<User?>? _userSub;

  // Sample trainers data
  var featuredTrainers = <Map<String, dynamic>>[].obs;
  var latestTrainerPosts = <Map<String, dynamic>>[].obs;

  final _trainerCatalog = <Map<String, dynamic>>[].obs;
  final _trainerUsersByUid = <String, Map<String, dynamic>>{};
  final _trainerProfilesByUid = <String, Map<String, dynamic>>{};
  final _subs = <StreamSubscription<dynamic>>[];

  // Shared bookings service — registered permanently in main.dart.
  BookingsService get _bookings => Get.find<BookingsService>();

  // Upcoming bookings — live reference to the service's RxList.
  RxList<Map<String, dynamic>> get upcomingBookings =>
      _bookings.upcomingBookings;

  // Stats (reactive — wire to Firestore later)
  var streak = 12.obs;
  var sessionsCount = 48.obs;
  var goalsCount = 5.obs;

  // ─── Category labels (same order as the UI chips) ─────────────────────────
  static const _categoryLabels = [
    'Strength',
    'Yoga',
    'Cardio',
    'Boxing',
    'Swim',
  ];

  // ─── Full trainer dataset ─────────────────────────────────────────────────
  static final _allTrainers = <Map<String, dynamic>>[
    // ── Strength ──────────────────────────────────────────────────────────
    {
      'id': '1',
      'name': 'John Smith',
      'specialty': 'Strength Training',
      'category': 'Strength',
      'rating': 4.9,
      'reviews': 127,
      'pricePerHour': 45,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=400',
    },
    {
      'id': 's2',
      'name': 'Marcus Bell',
      'specialty': 'Powerlifting',
      'category': 'Strength',
      'rating': 4.8,
      'reviews': 89,
      'pricePerHour': 55,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
    },
    {
      'id': 's3',
      'name': 'Chris Lee',
      'specialty': 'CrossFit',
      'category': 'Strength',
      'rating': 4.7,
      'reviews': 203,
      'pricePerHour': 48,
      'isAvailable': false,
      'image':
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
    },
    // ── Yoga ──────────────────────────────────────────────────────────────
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'specialty': 'Yoga & Flexibility',
      'category': 'Yoga',
      'rating': 4.9,
      'reviews': 98,
      'pricePerHour': 40,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
    },
    {
      'id': 'y2',
      'name': 'Priya Shah',
      'specialty': 'Pilates & Yoga',
      'category': 'Yoga',
      'rating': 4.8,
      'reviews': 74,
      'pricePerHour': 38,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400',
    },
    {
      'id': 'y3',
      'name': 'Emma Torres',
      'specialty': 'Restorative Yoga',
      'category': 'Yoga',
      'rating': 4.6,
      'reviews': 61,
      'pricePerHour': 35,
      'isAvailable': false,
      'image':
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
    },
    // ── Cardio ────────────────────────────────────────────────────────────
    {
      'id': '3',
      'name': 'Mike Chen',
      'specialty': 'HIIT & Cardio',
      'category': 'Cardio',
      'rating': 4.7,
      'reviews': 156,
      'pricePerHour': 50,
      'isAvailable': false,
      'image':
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
    },
    {
      'id': 'c2',
      'name': 'Jordan Miles',
      'specialty': 'Running & Endurance',
      'category': 'Cardio',
      'rating': 4.8,
      'reviews': 112,
      'pricePerHour': 42,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400',
    },
    {
      'id': 'c3',
      'name': 'Alex Rivera',
      'specialty': 'Cycling Coach',
      'category': 'Cardio',
      'rating': 4.6,
      'reviews': 88,
      'pricePerHour': 38,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1520720614099-7d9e8c3b5cc9?w=400',
    },
    // ── Boxing ────────────────────────────────────────────────────────────
    {
      'id': 'b1',
      'name': 'Sam Rivera',
      'specialty': 'Boxing & MMA',
      'category': 'Boxing',
      'rating': 4.9,
      'reviews': 143,
      'pricePerHour': 60,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1555597673-b21d5c935865?w=400',
    },
    {
      'id': 'b2',
      'name': 'Dave King',
      'specialty': 'Kickboxing',
      'category': 'Boxing',
      'rating': 4.7,
      'reviews': 95,
      'pricePerHour': 52,
      'isAvailable': false,
      'image':
          'https://images.unsplash.com/photo-1517438322307-e67111335449?w=400',
    },
    {
      'id': 'b3',
      'name': 'Rajan Pham',
      'specialty': 'Muay Thai',
      'category': 'Boxing',
      'rating': 4.8,
      'reviews': 77,
      'pricePerHour': 55,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1546483875-ad9014c88eba?w=400',
    },
    // ── Swim ──────────────────────────────────────────────────────────────
    {
      'id': 'sw1',
      'name': 'Lisa Park',
      'specialty': 'Swim Coaching',
      'category': 'Swim',
      'rating': 4.7,
      'reviews': 52,
      'pricePerHour': 45,
      'isAvailable': true,
      'image':
          'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=400',
    },
    {
      'id': 'sw2',
      'name': 'Tom Wells',
      'specialty': 'Aqua Fitness',
      'category': 'Swim',
      'rating': 4.5,
      'reviews': 38,
      'pricePerHour': 40,
      'isAvailable': false,
      'image':
          'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=400',
    },
  ];

  /// Filtered by selected category AND search query — reactive inside Obx.
  List<Map<String, dynamic>> get filteredTrainers {
    final query = searchQuery.value.trim().toLowerCase();
    final category = _categoryLabels[selectedCategoryIndex.value];
    return _trainerCatalog.where((t) {
      final matchCat = (t['category'] as String) == category;
      final matchQuery =
          query.isEmpty ||
          (t['name'] as String).toLowerCase().contains(query) ||
          (t['specialty'] as String).toLowerCase().contains(query);
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _listenToUser();
    _rebuildTrainerCatalog();
    _listenTrainersRealtime();
    _listenTrainerPostsRealtime();
    _loadFeaturedTrainers();
  }

  void _listenToUser() {
    _userSub = FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        userPhotoUrl.value = user.photoURL ?? '';
        final name = user.displayName ?? user.email ?? 'User';
        userName.value = name;
        userInitial.value = name.isNotEmpty ? name[0].toUpperCase() : 'U';
      }
    });
  }

  @override
  void onClose() {
    _userSub?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.onClose();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void _loadFeaturedTrainers() {
    final candidates = _trainerCatalog.toList(growable: false)..sort((a, b) {
      final aScore = ((a['rating'] as num?) ?? 0).toDouble();
      final bScore = ((b['rating'] as num?) ?? 0).toDouble();
      return bScore.compareTo(aScore);
    });

    featuredTrainers.assignAll(candidates.take(3));
  }

  void _listenTrainersRealtime() {
    _subs.add(
      _firestore
          .collection('users')
          .where('role', isEqualTo: 'trainer')
          .limit(250)
          .snapshots()
          .listen((snap) {
            _trainerUsersByUid
              ..clear()
              ..addEntries(snap.docs.map((d) => MapEntry(d.id, d.data())));
            _rebuildTrainerCatalog();
          }, onError: (_) {}),
    );

    _subs.add(
      _firestore.collection('trainerProfiles').limit(250).snapshots().listen((
        snap,
      ) {
        _trainerProfilesByUid
          ..clear()
          ..addEntries(snap.docs.map((d) => MapEntry(d.id, d.data())));
        _rebuildTrainerCatalog();
      }, onError: (_) {}),
    );
  }

  void _listenTrainerPostsRealtime() {
    _subs.add(
      _firestore
          .collection('trainerPosts')
          .where('isActive', isEqualTo: true)
          .limit(60)
          .snapshots()
          .listen((snap) {
            final mapped = snap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList(growable: false)..sort(
              (a, b) => _toEpochMs(
                b['createdAt'] ?? b['createdAtClient'],
              ).compareTo(_toEpochMs(a['createdAt'] ?? a['createdAtClient'])),
            );
            latestTrainerPosts.assignAll(mapped.take(12));
          }, onError: (_) {}),
    );
  }

  void _rebuildTrainerCatalog() {
    final mergedByName = <String, Map<String, dynamic>>{
      for (final trainer in _allTrainers)
        _normalizeName(trainer['name']?.toString() ?? ''): {
          ...trainer,
          'trainerId': trainer['id'],
        },
    };

    for (final entry in _trainerUsersByUid.entries) {
      final uid = entry.key;
      final user = entry.value;
      final profile = _trainerProfilesByUid[uid] ?? const <String, dynamic>{};

      final rawName =
          (user['name'] ?? user['fullName'] ?? user['displayName'] ?? '')
              .toString()
              .trim();
      if (rawName.isEmpty) continue;

      final key = _normalizeName(rawName);
      final existing = mergedByName[key] ?? <String, dynamic>{};

      final specializations =
          (profile['specializations'] is List)
              ? (profile['specializations'] as List)
                  .map((e) => e.toString())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : <String>[];
      final sessionLocations =
          (profile['sessionLocations'] is List)
              ? (profile['sessionLocations'] as List)
                  .map((e) => e.toString())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : <String>[];

      final fallbackCategory = _inferCategory(specializations);
      final category = (existing['category'] ?? fallbackCategory).toString();
      final priceFromProfile = _toInt(profile['sessionPrice']);
      final reviewCount = _toInt(user['reviewsCount']);
      final rating = _toDouble(user['rating']);

      mergedByName[key] = {
        ...existing,
        'id': existing['id'] ?? uid,
        'trainerId': uid,
        'name': rawName,
        'specialty':
            specializations.isNotEmpty
                ? specializations.first
                : (existing['specialty'] ?? 'Personal Training'),
        'specializations': specializations,
        'languages': profile['languages'] ?? const <String>[],
        'sessionLocations': sessionLocations,
        'bio': (profile['bio'] ?? '').toString(),
        'category':
            _categoryLabels.contains(category) ? category : fallbackCategory,
        'rating': rating > 0 ? rating : (existing['rating'] ?? 4.7),
        'reviews': reviewCount > 0 ? reviewCount : (existing['reviews'] ?? 0),
        'pricePerHour':
            priceFromProfile > 0
                ? priceFromProfile
                : (existing['pricePerHour'] ?? 40),
        'isAvailable': _isProfileAvailable(profile, existing['isAvailable']),
        'availability': profile['availability'] ?? const <String, dynamic>{},
        'image':
            (profile['photoUrl'] ?? user['photoUrl'] ?? existing['image'] ?? '')
                .toString(),
      };
    }

    _trainerCatalog.assignAll(mergedByName.values);
    _loadFeaturedTrainers();
  }

  String _normalizeName(String raw) {
    return raw.trim().toLowerCase();
  }

  String _inferCategory(List<String> specializations) {
    final joined = specializations.join(' ').toLowerCase();
    if (joined.contains('yoga') || joined.contains('pilates')) return 'Yoga';
    if (joined.contains('box') ||
        joined.contains('mma') ||
        joined.contains('muay')) {
      return 'Boxing';
    }
    if (joined.contains('swim') || joined.contains('aqua')) return 'Swim';
    if (joined.contains('cardio') ||
        joined.contains('hiit') ||
        joined.contains('run')) {
      return 'Cardio';
    }
    return 'Strength';
  }

  bool _isProfileAvailable(Map<String, dynamic> profile, dynamic fallback) {
    final raw = profile['availability'];
    if (raw is Map) {
      for (final day in raw.values) {
        if (day is Map && day['enabled'] == true) {
          return true;
        }
      }
    }
    return fallback == true;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _toEpochMs(dynamic raw) {
    if (raw is Timestamp) return raw.millisecondsSinceEpoch;
    if (raw is DateTime) return raw.millisecondsSinceEpoch;
    if (raw is int) return raw;
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed.millisecondsSinceEpoch;
    }
    return 0;
  }

  void navigateToTrainerDetails(Map<String, dynamic> trainer) {
    Get.toNamed('/trainer-details', arguments: trainer);
  }

  void navigateToTrainerFromPost(Map<String, dynamic> post) {
    final trainerId = (post['trainerId'] ?? '').toString().trim();
    final trainerName =
        (post['trainerName'] ?? post['authorName'] ?? '').toString().trim();

    Map<String, dynamic>? trainer;
    if (trainerId.isNotEmpty) {
      trainer = _trainerCatalog.firstWhereOrNull(
        (item) => (item['trainerId'] ?? item['id']).toString() == trainerId,
      );
    }

    trainer ??= _trainerCatalog.firstWhereOrNull(
      (item) =>
          _normalizeName(item['name']?.toString() ?? '') ==
          _normalizeName(trainerName),
    );

    if (trainer != null) {
      navigateToTrainerDetails(trainer);
      return;
    }

    if (trainerName.isEmpty) {
      Get.snackbar(
        'Trainer unavailable',
        'Could not open this trainer profile.',
      );
      return;
    }

    navigateToTrainerDetails({
      'id': trainerId,
      'trainerId': trainerId,
      'name': trainerName,
      'specialty': (post['category'] ?? 'Personal Training').toString(),
      'image': (post['trainerPhotoUrl'] ?? post['imageUrl'] ?? '').toString(),
      'isAvailable': true,
    });
  }

  void navigateToBookingDetails(String bookingId) {
    // TODO: Navigate to booking details page
    Get.toNamed('/booking/$bookingId');
  }

  void navigateToMessages() {
    currentIndex.value = 2; // switch to Messages tab in bottom nav
  }

  void navigateToNotifications() {
    Get.toNamed('/notifications');
  }

  void navigateToSearch() {
    Get.toNamed('/search');
  }

  // ─── Quick Action navigation ────────────────────────────────────────────
  void navigateToBook() => Get.toNamed('/search');

  void navigateToHistory() =>
      Get.toNamed('/my-bookings', arguments: {'tab': 1});

  void navigateToPayment() => Get.toNamed('/wallet');

  void claimPromo() => Get.toNamed('/search');
}
