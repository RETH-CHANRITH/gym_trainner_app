import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/user_profile_service.dart';

class ProfileSummaryController extends GetxController {
  UserProfileService get profile => Get.find<UserProfileService>();
  Worker? _profileWorker;

  @override
  void onInit() {
    super.onInit();
    _profileWorker = everAll(
      [
        profile.name,
        profile.email,
        profile.photoUrl,
        profile.gender,
        profile.age,
        profile.weight,
        profile.height,
        profile.fitnessGoal,
        profile.activityLevel,
        profile.fitnessLevel,
        profile.isUploadingPhoto,
      ],
      (_) {
        update();
      },
    );
  }

  Future<void> changeProfileImage() async {
    await profile.pickAndUploadProfilePhoto();
  }

  Future<bool> saveProfile({
    required String fullName,
    required String selectedGender,
    required String ageText,
    required String weightText,
    required String heightText,
    required String selectedGoal,
    required String selectedActivity,
    required String selectedFitness,
  }) async {
    final age = int.tryParse(ageText.trim());
    final weight = int.tryParse(weightText.trim());
    final height = int.tryParse(heightText.trim());

    if (fullName.trim().isEmpty ||
        age == null ||
        weight == null ||
        height == null) {
      Get.snackbar('Invalid Input', 'Please fill all fields correctly.');
      return false;
    }

    await profile.updateProfile(
      fullName: fullName.trim(),
      selectedGender: selectedGender,
      selectedAge: age,
      selectedWeight: weight,
      selectedHeight: height,
      selectedGoal: selectedGoal,
      selectedActivity: selectedActivity,
      selectedFitness: selectedFitness,
    );

    Get.snackbar('Saved', 'Your profile has been updated.');
    return true;
  }

  void completeProfile() {
    // Navigate to profile screen and clear previous routes
    Get.offAllNamed(Routes.PROFILE);
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    super.onClose();
  }
}
