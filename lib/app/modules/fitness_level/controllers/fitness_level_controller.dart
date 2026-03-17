import 'package:get/get.dart';
import '../../../services/user_profile_service.dart';

class FitnessLevelController extends GetxController {
  var selectedLevel = Rx<String?>(null);

  final levels = [
    {'id': 'beginner', 'label': 'Beginner', 'description': 'Just starting out'},
    {
      'id': 'intermediate',
      'label': 'Intermediate',
      'description': 'Some experience',
    },
    {'id': 'advanced', 'label': 'Advanced', 'description': 'Very experienced'},
  ];

  void selectLevel(String level) {
    selectedLevel.value = level;
  }

  void nextStep() {
    if (selectedLevel.value != null) {
      final label =
          levels.firstWhere(
                (l) => l['id'] == selectedLevel.value,
                orElse: () => {'label': selectedLevel.value!},
              )['label']
              as String;
      Get.find<UserProfileService>().fitnessLevel.value = label;
      Get.toNamed('/notification-permission');
    } else {
      Get.snackbar('Error', 'Please select your fitness level');
    }
  }

  void goBack() {
    Get.back();
  }
}
