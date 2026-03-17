import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_pages.dart';
import '../../../services/user_profile_service.dart';

class TrainerDashboardController extends GetxController {
  TrainerDashboardController({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  final displayName = 'Trainer'.obs;
  final profilePhotoUrl = ''.obs;
  final currentTabIndex = 0.obs;
  final isLoading = true.obs;
  final isSavingProfile = false.obs;
  final isActionLoading = false.obs;

  final profile = <String, dynamic>{}.obs;
  final bookings = <Map<String, dynamic>>[].obs;
  final reviews = <Map<String, dynamic>>[].obs;
  final payouts = <Map<String, dynamic>>[].obs;
  final posts = <Map<String, dynamic>>[].obs;

  final pendingBookingsCount = 0.obs;
  final todaySessionsCount = 0.obs;
  final monthlyIncome = 0.0.obs;
  final avgRating = 0.0.obs;
  final totalReviews = 0.obs;

  final sessionPriceController = TextEditingController();
  final bioController = TextEditingController();
  final specializationController = TextEditingController();
  final languagesController = TextEditingController();
  final sessionLocationController = TextEditingController();
  final payoutAmountController = TextEditingController();
  final postTitleController = TextEditingController();
  final postCaptionController = TextEditingController();
  final postTagsController = TextEditingController();

  final isUploadingPostImage = false.obs;
  final isCreatingPost = false.obs;
  final draftPostImageUrl = ''.obs;
  final selectedPostCategory = 'Workout'.obs;

  static const List<String> postCategories = [
    'Workout',
    'Nutrition',
    'Mindset',
    'Progress',
    'Announcement',
  ];

  final availability = <String, Map<String, dynamic>>{}.obs;
  final _subs = <StreamSubscription<dynamic>>[];
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      displayName.value = name;
    }
    profilePhotoUrl.value = user?.photoURL?.trim() ?? '';

    _listenTrainerData();
  }

  @override
  void onClose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    sessionPriceController.dispose();
    bioController.dispose();
    specializationController.dispose();
    languagesController.dispose();
    sessionLocationController.dispose();
    payoutAmountController.dispose();
    postTitleController.dispose();
    postCaptionController.dispose();
    postTagsController.dispose();
    super.onClose();
  }

  List<Map<String, dynamic>> get pendingBookings {
    return bookings.where((b) {
      final status = (b['status'] ?? '').toString().toLowerCase();
      return status == 'pending' || status == 'requested';
    }).toList();
  }

  List<Map<String, dynamic>> get upcomingBookings {
    final now = DateTime.now();
    return bookings.where((b) {
        final status = (b['status'] ?? '').toString().toLowerCase();
        if (status == 'cancelled' || status == 'rejected') return false;
        final scheduledAt = _toDateTime(
          b['scheduledAt'] ?? b['sessionAt'] ?? b['dateTime'],
        );
        return scheduledAt != null && scheduledAt.isAfter(now);
      }).toList()
      ..sort((a, b) {
        final aDate =
            _toDateTime(a['scheduledAt'] ?? a['sessionAt'] ?? a['dateTime']) ??
            DateTime.now();
        final bDate =
            _toDateTime(b['scheduledAt'] ?? b['sessionAt'] ?? b['dateTime']) ??
            DateTime.now();
        return aDate.compareTo(bDate);
      });
  }

  List<Map<String, dynamic>> get recentPosts {
    final sorted = posts.toList(growable: false);
    sorted.sort(
      (a, b) => _toEpochMs(
        b['createdAt'] ?? b['createdAtClient'],
      ).compareTo(_toEpochMs(a['createdAt'] ?? a['createdAtClient'])),
    );
    return sorted;
  }

  List<Map<String, dynamic>> get bookingRequests {
    return bookings.where((b) {
        final status = (b['status'] ?? '').toString().toLowerCase();
        return status == 'pending' || status == 'requested';
      }).toList()
      ..sort((a, b) {
        final aDate =
            _toDateTime(a['scheduledAt'] ?? a['sessionAt'] ?? a['dateTime']) ??
            DateTime.now();
        final bDate =
            _toDateTime(b['scheduledAt'] ?? b['sessionAt'] ?? b['dateTime']) ??
            DateTime.now();
        return aDate.compareTo(bDate);
      });
  }

  List<Map<String, dynamic>> get confirmedUpcomingBookings {
    final now = DateTime.now();
    return bookings.where((b) {
        final status = (b['status'] ?? '').toString().toLowerCase();
        if (status != 'confirmed' && status != 'accepted') return false;
        final scheduledAt = _toDateTime(
          b['scheduledAt'] ?? b['sessionAt'] ?? b['dateTime'],
        );
        return scheduledAt != null && scheduledAt.isAfter(now);
      }).toList()
      ..sort((a, b) {
        final aDate =
            _toDateTime(a['scheduledAt'] ?? a['sessionAt'] ?? a['dateTime']) ??
            DateTime.now();
        final bDate =
            _toDateTime(b['scheduledAt'] ?? b['sessionAt'] ?? b['dateTime']) ??
            DateTime.now();
        return aDate.compareTo(bDate);
      });
  }

  int get activeAvailabilityDays {
    return availability.values.where((day) => day['enabled'] == true).length;
  }

  int get activePostsCount {
    return posts.where((post) => post['isActive'] != false).length;
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (isSavingProfile.value) return;

    isSavingProfile.value = true;
    try {
      await _firestore.collection('trainerProfiles').doc(uid).set({
        'bio': bioController.text.trim(),
        'sessionPrice':
            double.tryParse(sessionPriceController.text.trim()) ?? 0,
        'specializations': _splitCsv(specializationController.text),
        'languages': _splitCsv(languagesController.text),
        'sessionLocations': _splitCsv(sessionLocationController.text),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(uid).set({
        'trainerProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Profile saved', 'Trainer profile updated successfully.');
    } catch (_) {
      Get.snackbar('Save failed', 'Could not update trainer profile.');
    } finally {
      isSavingProfile.value = false;
    }
  }

  Future<void> saveProfileDraft({
    required String sessionPrice,
    required String bio,
    required String specializations,
    required String languages,
    required String locations,
  }) async {
    sessionPriceController.text = sessionPrice;
    bioController.text = bio;
    specializationController.text = specializations;
    languagesController.text = languages;
    sessionLocationController.text = locations;
    await saveProfile();
  }

  Future<void> updateDayAvailability({
    required String day,
    required bool enabled,
    String? date,
    String? start,
    String? end,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final current = Map<String, dynamic>.from(availability[day] ?? {});
    current['enabled'] = enabled;
    current['date'] = date ?? (current['date'] ?? '');
    current['start'] = start ?? (current['start'] ?? '09:00');
    current['end'] = end ?? (current['end'] ?? '18:00');
    availability[day] = current;

    await _firestore.collection('trainerProfiles').doc(uid).set({
      'availability': availability,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> acceptBooking(Map<String, dynamic> booking) async {
    await _setBookingStatus(booking, 'confirmed');
  }

  Future<void> rejectBooking(Map<String, dynamic> booking) async {
    await _setBookingStatus(booking, 'rejected');
  }

  Future<void> cancelBooking(Map<String, dynamic> booking) async {
    await _setBookingStatus(
      booking,
      'cancelled',
      reason: 'Cancelled by trainer',
    );
  }

  Future<void> requestPayout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final amount = double.tryParse(payoutAmountController.text.trim()) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Invalid amount', 'Enter a valid payout amount.');
      return;
    }

    try {
      await _firestore.collection('payouts').add({
        'trainerId': uid,
        'amount': amount,
        'status': 'requested',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      payoutAmountController.clear();
      Get.snackbar(
        'Payout requested',
        'Your withdrawal request was submitted.',
      );
    } catch (_) {
      Get.snackbar('Request failed', 'Could not submit payout request.');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> pickAndUploadPostImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || isUploadingPostImage.value) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (picked == null) return;

    isUploadingPostImage.value = true;
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      final safeExt = ext.isEmpty ? 'jpg' : ext;
      final path =
          'trainer-posts/${uid}_${DateTime.now().millisecondsSinceEpoch}.$safeExt';

      await _supabase.storage
          .from('images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentTypeFor(safeExt),
            ),
          );

      draftPostImageUrl.value = _supabase.storage
          .from('images')
          .getPublicUrl(path);
      Get.snackbar('Image uploaded', 'Post image is ready.');
    } catch (_) {
      Get.snackbar('Upload failed', 'Could not upload the post image.');
    } finally {
      isUploadingPostImage.value = false;
    }
  }

  void clearPostDraft() {
    postTitleController.clear();
    postCaptionController.clear();
    postTagsController.clear();
    selectedPostCategory.value = postCategories.first;
    draftPostImageUrl.value = '';
  }

  Future<bool> createPostDraft({
    required String title,
    required String caption,
    required String tags,
    required String category,
    DateTime? selectedDate,
  }) async {
    postTitleController.text = title;
    postCaptionController.text = caption;
    postTagsController.text = tags;
    selectedPostCategory.value = category;
    return createPost(selectedDate: selectedDate);
  }

  Future<bool> createPost({DateTime? selectedDate}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || isCreatingPost.value) return false;

    final title = postTitleController.text.trim();
    final caption = postCaptionController.text.trim();
    if (title.isEmpty && caption.isEmpty) {
      Get.snackbar('Missing content', 'Add a title or caption for your post.');
      return false;
    }

    isCreatingPost.value = true;
    try {
      final date = selectedDate ?? DateTime.now();
      await _firestore.collection('trainerPosts').add({
        'trainerId': uid,
        'trainerName': displayName.value,
        'trainerPhotoUrl': profilePhotoUrl.value,
        'title': title,
        'caption': caption,
        'category': selectedPostCategory.value,
        'tags': _splitCsv(postTagsController.text),
        'imageUrl': draftPostImageUrl.value,
        'likesCount': 0,
        'commentsCount': 0,
        'isActive': true,
        'postDate': _formatDateIso(date),
        'postDay': date.day,
        'postMonth': date.month,
        'postYear': date.year,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtClient': Timestamp.now(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      clearPostDraft();
      Get.snackbar('Post published', 'Your trainer post is now live.');
      return true;
    } catch (_) {
      Get.snackbar('Post failed', 'Could not publish this post.');
      return false;
    } finally {
      isCreatingPost.value = false;
    }
  }

  Future<void> togglePostVisibility(Map<String, dynamic> post) async {
    if (isActionLoading.value) return;
    final postId = post['id']?.toString();
    if (postId == null || postId.isEmpty) return;

    isActionLoading.value = true;
    try {
      final isActive = post['isActive'] != false;
      await _firestore.collection('trainerPosts').doc(postId).set({
        'isActive': !isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      Get.snackbar(
        isActive ? 'Post archived' : 'Post activated',
        isActive
            ? 'This post is now hidden from your public feed.'
            : 'This post is visible again.',
      );
    } catch (_) {
      Get.snackbar('Update failed', 'Could not update post visibility.');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> deletePost(Map<String, dynamic> post) async {
    if (isActionLoading.value) return;
    final postId = post['id']?.toString();
    if (postId == null || postId.isEmpty) return;

    isActionLoading.value = true;
    try {
      await _firestore.collection('trainerPosts').doc(postId).delete();
      Get.snackbar('Post deleted', 'Trainer post removed successfully.');
    } catch (_) {
      Get.snackbar('Delete failed', 'Could not delete this post.');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> updateProfilePhoto() async {
    try {
      final profileService = Get.find<UserProfileService>();
      final ok = await profileService.pickAndUploadProfilePhoto();
      if (ok) {
        profilePhotoUrl.value = profileService.photoUrl.value;
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null && uid.isNotEmpty) {
          await _firestore.collection('trainerProfiles').doc(uid).set({
            'photoUrl': profilePhotoUrl.value,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (_) {
      Get.snackbar('Photo update failed', 'Could not update trainer photo.');
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<Map<String, dynamic>> loadReviewerProfile(
    Map<String, dynamic> review,
  ) async {
    final merged = Map<String, dynamic>.from(review);
    final reviewerId = _extractReviewerId(review);
    if (reviewerId.isEmpty) {
      return {
        ...merged,
        'reviewerId': '',
        'reviewerName': _extractReviewerName(review),
        'reviewerPhotoUrl': _extractReviewerPhoto(review),
      };
    }

    try {
      final doc = await _firestore.collection('users').doc(reviewerId).get();
      final data = doc.data() ?? const <String, dynamic>{};
      return {
        ...merged,
        ...data,
        'reviewerId': reviewerId,
        'reviewerName':
            (data['name'] ??
                    data['fullName'] ??
                    data['displayName'] ??
                    _extractReviewerName(review))
                .toString(),
        'reviewerPhotoUrl':
            (data['photoUrl'] ??
                    data['avatarUrl'] ??
                    data['profileImage'] ??
                    _extractReviewerPhoto(review))
                .toString(),
      };
    } catch (_) {
      return {
        ...merged,
        'reviewerId': reviewerId,
        'reviewerName': _extractReviewerName(review),
        'reviewerPhotoUrl': _extractReviewerPhoto(review),
      };
    }
  }

  String _extractReviewerId(Map<String, dynamic> review) {
    const keys = [
      'userId',
      'reviewerId',
      'clientId',
      'memberId',
      'fromUserId',
      'authorId',
    ];
    for (final key in keys) {
      final value = (review[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _extractReviewerName(Map<String, dynamic> review) {
    const keys = [
      'userName',
      'reviewerName',
      'clientName',
      'authorName',
      'name',
    ];
    for (final key in keys) {
      final value = (review[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return 'User';
  }

  String _extractReviewerPhoto(Map<String, dynamic> review) {
    const keys = [
      'userPhotoUrl',
      'reviewerPhotoUrl',
      'clientPhotoUrl',
      'authorPhotoUrl',
      'photoUrl',
      'avatarUrl',
    ];
    for (final key in keys) {
      final value = (review[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _listenTrainerData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    _subs.add(
      _firestore.collection('users').doc(uid).snapshots().listen((doc) {
        if (!doc.exists) return;
        final data = doc.data() ?? {};
        final name = (data['name'] ?? data['fullName'] ?? '').toString().trim();
        if (name.isNotEmpty) {
          displayName.value = name;
        }
        final docPhoto = (data['photoUrl'] ?? '').toString().trim();
        if (docPhoto.isNotEmpty) {
          profilePhotoUrl.value = docPhoto;
        }
      }),
    );

    _subs.add(
      _firestore.collection('trainerProfiles').doc(uid).snapshots().listen((
        doc,
      ) {
        final data = doc.data() ?? {};
        profile.assignAll(data);
        final profilePhoto = (data['photoUrl'] ?? '').toString().trim();
        if (profilePhoto.isNotEmpty) {
          profilePhotoUrl.value = profilePhoto;
        }
        bioController.text = (data['bio'] ?? '').toString();
        sessionPriceController.text = (data['sessionPrice'] ?? '').toString();
        specializationController.text = _joinCsv(data['specializations']);
        languagesController.text = _joinCsv(data['languages']);
        sessionLocationController.text = _joinCsv(data['sessionLocations']);

        final rawAvailability = data['availability'];
        if (rawAvailability is Map) {
          availability.assignAll(
            rawAvailability.map((key, value) {
              final dayKey = key.toString();
              final dayValue =
                  value is Map
                      ? Map<String, dynamic>.from(value)
                      : <String, dynamic>{};
              return MapEntry(dayKey, dayValue);
            }),
          );
        }
      }),
    );

    _subs.add(
      _firestore
          .collection('bookings')
          .where('trainerId', isEqualTo: uid)
          .limit(200)
          .snapshots()
          .listen((snap) {
            bookings.assignAll(snap.docs.map((d) => {'id': d.id, ...d.data()}));
            _recomputeBookingKpis();
          }, onError: (_) {}),
    );

    _subs.add(
      _firestore
          .collection('reviews')
          .where('trainerId', isEqualTo: uid)
          .limit(100)
          .snapshots()
          .listen((snap) {
            reviews.assignAll(snap.docs.map((d) => {'id': d.id, ...d.data()}));
            _recomputeRatings();
          }, onError: (_) {}),
    );

    _subs.add(
      _firestore
          .collection('payouts')
          .where('trainerId', isEqualTo: uid)
          .limit(100)
          .snapshots()
          .listen((snap) {
            payouts.assignAll(snap.docs.map((d) => {'id': d.id, ...d.data()}));
          }, onError: (_) {}),
    );

    _subs.add(
      _firestore
          .collection('trainerPosts')
          .where('trainerId', isEqualTo: uid)
          .limit(100)
          .snapshots()
          .listen((snap) {
            final mapped = snap.docs
                .map((d) => {'id': d.id, ...d.data()})
                .toList(growable: false);
            mapped.sort(
              (a, b) => _toEpochMs(
                b['createdAt'] ?? b['createdAtClient'],
              ).compareTo(_toEpochMs(a['createdAt'] ?? a['createdAtClient'])),
            );
            posts.assignAll(mapped);
          }, onError: (_) {}),
    );

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      isLoading.value = false;
    });
  }

  void _recomputeBookingKpis() {
    pendingBookingsCount.value =
        bookings.where((b) {
          final status = (b['status'] ?? '').toString().toLowerCase();
          return status == 'pending' || status == 'requested';
        }).length;

    final now = DateTime.now();
    todaySessionsCount.value =
        bookings.where((b) {
          final dt = _toDateTime(b['scheduledAt'] ?? b['sessionAt']);
          if (dt == null) return false;
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        }).length;

    final startOfMonth = DateTime(now.year, now.month, 1);
    monthlyIncome.value = bookings.fold(0.0, (runningTotal, booking) {
      final status = (booking['status'] ?? '').toString().toLowerCase();
      if (status != 'completed' && booking['paid'] != true) {
        return runningTotal;
      }

      final dt = _toDateTime(booking['scheduledAt'] ?? booking['sessionAt']);
      if (dt != null && dt.isBefore(startOfMonth)) return runningTotal;

      final amount = _toDouble(booking['amount'] ?? booking['price']);
      return runningTotal + amount;
    });
  }

  void _recomputeRatings() {
    totalReviews.value = reviews.length;
    if (reviews.isEmpty) {
      avgRating.value = 0;
      return;
    }

    final values =
        reviews.map((r) => _toDouble(r['rating'])).where((v) => v > 0).toList();
    if (values.isEmpty) {
      avgRating.value = 0;
      return;
    }

    avgRating.value = values.reduce((a, b) => a + b) / values.length;
  }

  Future<void> _setBookingStatus(
    Map<String, dynamic> booking,
    String status, {
    String? reason,
  }) async {
    if (isActionLoading.value) return;
    final bookingId = booking['id']?.toString();
    if (bookingId == null || bookingId.isEmpty) return;

    isActionLoading.value = true;
    try {
      await _firestore.collection('bookings').doc(bookingId).set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
        if (reason != null) 'statusReason': reason,
      }, SetOptions(merge: true));
      Get.snackbar('Booking updated', 'Status set to $status.');
    } catch (_) {
      Get.snackbar('Action failed', 'Could not update this booking.');
    } finally {
      isActionLoading.value = false;
    }
  }

  DateTime? _toDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _joinCsv(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).join(', ');
    }
    return '';
  }

  List<String> _splitCsv(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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

  String _formatDateIso(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
