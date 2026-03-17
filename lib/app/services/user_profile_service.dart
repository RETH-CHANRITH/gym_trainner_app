import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService extends GetxService {
  final _auth = fa.FirebaseAuth.instance;
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;
  StreamSubscription<fa.User?>? _authSub;

  final name = 'User'.obs;
  final email = ''.obs;
  final photoUrl = ''.obs;
  final isUploadingPhoto = false.obs;

  final gender = 'Male'.obs;
  final age = 25.obs;
  final weight = 70.obs;
  final height = 170.obs;
  final fitnessGoal = 'Muscle Gain'.obs;
  final activityLevel = 'Moderately Active'.obs;
  final fitnessLevel = 'Intermediate'.obs;

  Future<UserProfileService> init() async {
    _applyAuthUser(_auth.currentUser);
    _authSub = _auth.authStateChanges().listen(_applyAuthUser);
    return this;
  }

  void _applyAuthUser(fa.User? user) {
    if (user == null) {
      email.value = '';
      photoUrl.value = '';
      if (name.value.trim().isEmpty) {
        name.value = 'User';
      }
      return;
    }

    final display = user.displayName?.trim() ?? '';
    final mail = user.email?.trim() ?? '';

    if (display.isNotEmpty) {
      name.value = display;
    } else if (mail.isNotEmpty) {
      name.value = mail.split('@').first;
    }

    email.value = mail;
    photoUrl.value = user.photoURL?.trim() ?? '';
  }

  Future<void> updateProfile({
    required String fullName,
    required String selectedGender,
    required int selectedAge,
    required int selectedWeight,
    required int selectedHeight,
    required String selectedGoal,
    required String selectedActivity,
    required String selectedFitness,
  }) async {
    name.value = fullName;
    gender.value = selectedGender;
    age.value = selectedAge;
    weight.value = selectedWeight;
    height.value = selectedHeight;
    fitnessGoal.value = selectedGoal;
    activityLevel.value = selectedActivity;
    fitnessLevel.value = selectedFitness;

    final current = _auth.currentUser;
    if (current != null &&
        fullName.trim().isNotEmpty &&
        current.displayName != fullName.trim()) {
      await current.updateDisplayName(fullName.trim());
    }
  }

  Future<bool> pickAndUploadProfilePhoto() async {
    final current = _auth.currentUser;
    if (current == null) {
      Get.snackbar('Login required', 'Please login first to update photo.');
      return false;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (picked == null) {
      return false;
    }

    isUploadingPhoto.value = true;
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.path.split('.').last.toLowerCase();
      final safeExt = ext.isEmpty ? 'jpg' : ext;
      final path =
          'profiles/${current.uid}_${DateTime.now().millisecondsSinceEpoch}.$safeExt';

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

      final publicUrl = _supabase.storage.from('images').getPublicUrl(path);
      await current.updatePhotoURL(publicUrl);
      photoUrl.value = publicUrl;
      Get.snackbar('Updated', 'Profile image updated successfully.');
      return true;
    } catch (_) {
      Get.snackbar('Upload failed', 'Could not upload profile image.');
      return false;
    } finally {
      isUploadingPhoto.value = false;
    }
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

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }
}
