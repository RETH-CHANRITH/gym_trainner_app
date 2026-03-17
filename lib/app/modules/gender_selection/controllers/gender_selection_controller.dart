import 'package:get/get.dart';
import '../../../services/user_profile_service.dart';

class GenderSelectionController extends GetxController {
  var selectedGender = Rx<String?>(null);

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void nextStep() {
    if (selectedGender.value != null) {
      Get.find<UserProfileService>().gender.value = selectedGender.value!;
      Get.toNamed('/age-input');
    } else {
      Get.snackbar('Error', 'Please select your gender');
    }
  }

  void goBack() {
    Get.back();
  }
}
