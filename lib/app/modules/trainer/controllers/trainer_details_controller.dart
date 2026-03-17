import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TrainerDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var trainerName = 'Trainer'.obs;
  var specialty = ''.obs;
  var rating = 0.0.obs;
  var reviewCount = 0.obs;
  var pricePerHour = 0.obs;
  var sessions = 0.obs;
  var portrait = 10.obs;
  var imageUrl = ''.obs;
  var isAvailable = false.obs;
  var trainerId = ''.obs;
  var bio = ''.obs;
  var specializations = <String>[].obs;
  var languages = <String>[].obs;
  var sessionLocations = <String>[].obs;
  var availability = <String, Map<String, dynamic>>{}.obs;
  var recentPosts = <Map<String, dynamic>>[].obs;

  final _subs = <StreamSubscription<dynamic>>[];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      trainerName.value = args['name'] as String? ?? 'Trainer';
      specialty.value = args['specialty'] as String? ?? '';
      rating.value = (args['rating'] as num?)?.toDouble() ?? 0.0;
      // search screen uses 'sessions', home screen uses 'reviews'
      reviewCount.value =
          (args['sessions'] as int?) ?? (args['reviews'] as int?) ?? 0;
      pricePerHour.value =
          (args['pricePerHour'] as int?) ?? (args['price'] as int?) ?? 0;
      sessions.value = (args['sessions'] as int?) ?? 0;
      portrait.value = (args['portrait'] as int?) ?? 32;
      imageUrl.value = args['image'] as String? ?? '';
      isAvailable.value = args['isAvailable'] as bool? ?? false;
      trainerId.value = (args['trainerId'] ?? args['id'] ?? '').toString();
      bio.value = (args['bio'] ?? '').toString();

      final rawSpecs = args['specializations'];
      if (rawSpecs is List) {
        specializations.assignAll(rawSpecs.map((e) => e.toString()));
      }
      final rawLanguages = args['languages'];
      if (rawLanguages is List) {
        languages.assignAll(rawLanguages.map((e) => e.toString()));
      }
      final rawLocations = args['sessionLocations'];
      if (rawLocations is List) {
        sessionLocations.assignAll(rawLocations.map((e) => e.toString()));
      }

      final rawAvailability = args['availability'];
      if (rawAvailability is Map) {
        availability.assignAll(
          rawAvailability.map((k, v) {
            final value =
                v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
            return MapEntry(k.toString(), value);
          }),
        );
      }
    }

    _listenRealtimeDetails();
  }

  @override
  void onClose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.onClose();
  }

  void _listenRealtimeDetails() {
    final uid = trainerId.value.trim();
    if (uid.isNotEmpty) {
      _subs.add(
        _firestore.collection('trainerProfiles').doc(uid).snapshots().listen((
          doc,
        ) {
          if (!doc.exists) return;
          final data = doc.data() ?? const <String, dynamic>{};
          _applyProfileData(data);
        }, onError: (_) {}),
      );

      _subs.add(
        _firestore.collection('users').doc(uid).snapshots().listen((doc) {
          if (!doc.exists) return;
          final data = doc.data() ?? const <String, dynamic>{};
          final name =
              (data['name'] ?? data['fullName'] ?? data['displayName'] ?? '')
                  .toString()
                  .trim();
          if (name.isNotEmpty) trainerName.value = name;
          final photo = (data['photoUrl'] ?? '').toString().trim();
          if (photo.isNotEmpty) imageUrl.value = photo;
          final ratingValue = data['rating'];
          if (ratingValue is num) rating.value = ratingValue.toDouble();
          final reviewsValue = data['reviewsCount'];
          if (reviewsValue is num) reviewCount.value = reviewsValue.toInt();
        }, onError: (_) {}),
      );

      _subs.add(
        _firestore
            .collection('trainerPosts')
            .where('trainerId', isEqualTo: uid)
            .where('isActive', isEqualTo: true)
            .limit(30)
            .snapshots()
            .listen((snap) {
              final mapped = snap.docs
                .map((d) => {'id': d.id, ...d.data()})
                .toList(growable: false)..sort(
                (a, b) => _toEpochMs(
                  b['createdAt'] ?? b['createdAtClient'],
                ).compareTo(_toEpochMs(a['createdAt'] ?? a['createdAtClient'])),
              );
              recentPosts.assignAll(mapped.take(6));
            }, onError: (_) {}),
      );
      return;
    }

    final name = trainerName.value.trim();
    if (name.isEmpty) return;
    _subs.add(
      _firestore
          .collection('trainerPosts')
          .where('trainerName', isEqualTo: name)
          .where('isActive', isEqualTo: true)
          .limit(30)
          .snapshots()
          .listen((snap) {
            final mapped = snap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList(growable: false)..sort(
              (a, b) => _toEpochMs(
                b['createdAt'] ?? b['createdAtClient'],
              ).compareTo(_toEpochMs(a['createdAt'] ?? a['createdAtClient'])),
            );
            recentPosts.assignAll(mapped.take(6));
          }, onError: (_) {}),
    );
  }

  void _applyProfileData(Map<String, dynamic> data) {
    final rawBio = (data['bio'] ?? '').toString().trim();
    if (rawBio.isNotEmpty) bio.value = rawBio;

    final rawPrice = data['sessionPrice'];
    if (rawPrice is num && rawPrice > 0) {
      pricePerHour.value = rawPrice.toInt();
    }

    final photo = (data['photoUrl'] ?? '').toString().trim();
    if (photo.isNotEmpty) imageUrl.value = photo;

    final rawSpecs = data['specializations'];
    if (rawSpecs is List) {
      specializations.assignAll(rawSpecs.map((e) => e.toString()));
      if (specializations.isNotEmpty) {
        specialty.value = specializations.first;
      }
    }

    final rawLanguages = data['languages'];
    if (rawLanguages is List) {
      languages.assignAll(rawLanguages.map((e) => e.toString()));
    }

    final rawLocations = data['sessionLocations'];
    if (rawLocations is List) {
      sessionLocations.assignAll(rawLocations.map((e) => e.toString()));
    }

    final rawAvailability = data['availability'];
    if (rawAvailability is Map) {
      final mapped = rawAvailability.map((key, value) {
        final dayValue =
            value is Map
                ? Map<String, dynamic>.from(value)
                : <String, dynamic>{};
        return MapEntry(key.toString(), dayValue);
      });
      availability.assignAll(mapped);
      isAvailable.value = mapped.values.any((day) => day['enabled'] == true);
    }
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
