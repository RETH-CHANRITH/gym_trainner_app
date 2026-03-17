import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  SearchController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  final query = RxString('');
  final selectedSpecialty = RxString('All');
  final minRating = RxDouble(0.0);
  final maxPrice = RxDouble(200.0);
  final isLoading = true.obs;

  final List<String> specialties = [
    'All',
    'Strength',
    'Yoga',
    'Cardio',
    'Boxing',
    'Pilates',
    'Powerlifting',
  ];

  final allTrainers = <Map<String, dynamic>>[].obs;
  final allPosts = <Map<String, dynamic>>[].obs;

  final _trainerUsersByUid = <String, Map<String, dynamic>>{};
  final _trainerProfilesByUid = <String, Map<String, dynamic>>{};
  final _subs = <StreamSubscription<dynamic>>[];

  final filtered = <Map<String, dynamic>>[].obs;
  final filteredPosts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenTrainersRealtime();
    _listenPostsRealtime();
    _recompute();
    ever(query, (_) => _recompute());
    ever(selectedSpecialty, (_) => _recompute());
    ever(minRating, (_) => _recompute());
    ever(maxPrice, (_) => _recompute());
  }

  @override
  void onClose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.onClose();
  }

  void _listenTrainersRealtime() {
    _subs.add(
      _firestore
          .collection('users')
          .where('role', isEqualTo: 'trainer')
          .limit(250)
          .snapshots()
          .listen(
            (snap) {
              _trainerUsersByUid
                ..clear()
                ..addEntries(snap.docs.map((d) => MapEntry(d.id, d.data())));
              _rebuildTrainerCatalog();
            },
            onError: (_) {
              isLoading.value = false;
            },
          ),
    );

    _subs.add(
      _firestore
          .collection('trainerProfiles')
          .limit(250)
          .snapshots()
          .listen(
            (snap) {
              _trainerProfilesByUid
                ..clear()
                ..addEntries(snap.docs.map((d) => MapEntry(d.id, d.data())));
              _rebuildTrainerCatalog();
            },
            onError: (_) {
              isLoading.value = false;
            },
          ),
    );
  }

  void _listenPostsRealtime() {
    _subs.add(
      _firestore
          .collection('trainerPosts')
          .where('isActive', isEqualTo: true)
          .limit(160)
          .snapshots()
          .listen(
            (snap) {
              final mapped = snap.docs
                  .map((d) => {'id': d.id, ...d.data()})
                  .toList(growable: false);
              mapped.sort(
                (a, b) => _toEpochMs(
                  b['createdAt'] ?? b['createdAtClient'],
                ).compareTo(_toEpochMs(a['createdAt'] ?? a['createdAtClient'])),
              );
              allPosts.assignAll(mapped);
              _recompute();
              isLoading.value = false;
            },
            onError: (_) {
              isLoading.value = false;
            },
          ),
    );
  }

  void _rebuildTrainerCatalog() {
    final merged = <Map<String, dynamic>>[];

    for (final entry in _trainerUsersByUid.entries) {
      final uid = entry.key;
      final user = entry.value;
      final profile = _trainerProfilesByUid[uid] ?? const <String, dynamic>{};

      final name =
          (user['name'] ?? user['fullName'] ?? user['displayName'] ?? '')
              .toString()
              .trim();
      if (name.isEmpty) continue;

      final specs =
          (profile['specializations'] is List)
              ? (profile['specializations'] as List)
                  .map((e) => e.toString())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : <String>[];

      final sessionPrice = _toInt(profile['sessionPrice']);

      merged.add({
        'id': uid,
        'trainerId': uid,
        'name': name,
        'specialty': specs.isNotEmpty ? specs.first : 'Personal Training',
        'specializations': specs,
        'rating':
            _toDouble(user['rating']) > 0 ? _toDouble(user['rating']) : 4.7,
        'reviews': _toInt(user['reviewsCount']),
        'sessions': _toInt(user['sessionsCount']),
        'price': sessionPrice > 0 ? sessionPrice : 40,
        'pricePerHour': sessionPrice > 0 ? sessionPrice : 40,
        'isAvailable': _isProfileAvailable(profile, user['isActive']),
        'bio': (profile['bio'] ?? '').toString(),
        'image': (profile['photoUrl'] ?? user['photoUrl'] ?? '').toString(),
      });
    }

    allTrainers.assignAll(merged);
    _recompute();
    isLoading.value = false;
  }

  void _recompute() {
    final rawQuery = query.value.trim().toLowerCase();
    final spec = selectedSpecialty.value.toLowerCase();

    filtered.value =
        allTrainers.where((t) {
          final name = (t['name'] ?? '').toString().toLowerCase();
          final specialty = (t['specialty'] ?? '').toString().toLowerCase();
          final extraSpecs =
              (t['specializations'] is List)
                  ? (t['specializations'] as List)
                      .map((e) => e.toString().toLowerCase())
                      .join(' ')
                  : '';
          final searchBlob = '$name $specialty $extraSpecs';

          final matchQuery = rawQuery.isEmpty || searchBlob.contains(rawQuery);
          final matchSpecialty =
              spec == 'all' ||
              specialty.contains(spec) ||
              extraSpecs.contains(spec);
          final matchRating = _toDouble(t['rating']) >= minRating.value;
          final matchPrice =
              _toDouble(t['pricePerHour'] ?? t['price']) <= maxPrice.value;
          return matchQuery && matchSpecialty && matchRating && matchPrice;
        }).toList();

    filteredPosts.value =
        allPosts.where((post) {
          final trainer = findTrainerForPost(post);
          final trainerSpec =
              (trainer?['specialty'] ?? post['category'] ?? '').toString();
          final trainerRating = _toDouble(trainer?['rating']);
          final trainerPrice = _toDouble(
            trainer?['pricePerHour'] ?? trainer?['price'],
          );

          final tags =
              (post['tags'] is List)
                  ? (post['tags'] as List).map((e) => e.toString()).join(' ')
                  : '';
          final postBlob =
              [
                (post['title'] ?? '').toString(),
                (post['caption'] ?? '').toString(),
                (post['category'] ?? '').toString(),
                tags,
                (post['trainerName'] ?? '').toString(),
                trainerSpec,
              ].join(' ').toLowerCase();

          final matchQuery = rawQuery.isEmpty || postBlob.contains(rawQuery);
          final matchSpecialty =
              spec == 'all' || trainerSpec.toLowerCase().contains(spec);
          final matchRating =
              trainer == null || trainerRating >= minRating.value;
          final matchPrice = trainer == null || trainerPrice <= maxPrice.value;

          return matchQuery && matchSpecialty && matchRating && matchPrice;
        }).toList();
  }

  Map<String, dynamic>? findTrainerForPost(Map<String, dynamic> post) {
    final trainerId = (post['trainerId'] ?? '').toString().trim();
    final trainerName = (post['trainerName'] ?? '').toString().trim();

    if (trainerId.isNotEmpty) {
      final byId = allTrainers.firstWhereOrNull(
        (t) => (t['trainerId'] ?? t['id']).toString() == trainerId,
      );
      if (byId != null) return byId;
    }

    if (trainerName.isNotEmpty) {
      return allTrainers.firstWhereOrNull(
        (t) =>
            (t['name'] ?? '').toString().trim().toLowerCase() ==
            trainerName.toLowerCase(),
      );
    }

    return null;
  }

  void openTrainerFromPost(Map<String, dynamic> post) {
    final trainer = findTrainerForPost(post);
    if (trainer != null) {
      Get.toNamed('/trainer-details', arguments: trainer);
      return;
    }

    final trainerId = (post['trainerId'] ?? '').toString().trim();
    final trainerName = (post['trainerName'] ?? 'Trainer').toString().trim();

    Get.toNamed(
      '/trainer-details',
      arguments: {
        'id': trainerId,
        'trainerId': trainerId,
        'name': trainerName,
        'specialty': (post['category'] ?? 'Personal Training').toString(),
        'image': (post['trainerPhotoUrl'] ?? post['imageUrl'] ?? '').toString(),
        'isAvailable': true,
      },
    );
  }

  void setQuery(String q) => query.value = q;
  void setSpecialty(String s) => selectedSpecialty.value = s;

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
}
