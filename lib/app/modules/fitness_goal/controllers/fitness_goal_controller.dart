import 'package:get/get.dart';
import '../../../services/user_profile_service.dart';

class FitnessGoalController extends GetxController {
  var selectedGoal = Rx<String?>(null);

  final goals = [
    {'id': 'weight_loss', 'label': 'Weight Loss', 'icon': '⚖️'},
    {'id': 'muscle_gain', 'label': 'Muscle Gain', 'icon': '💪'},
    {'id': 'endurance', 'label': 'Build Endurance', 'icon': '🏃'},
    {'id': 'flexibility', 'label': 'Improve Flexibility', 'icon': '🧘'},
  ];

  void selectGoal(String goal) {
    selectedGoal.value = goal;
  }

  void nextStep() {
    if (selectedGoal.value != null) {
      final label =
          goals.firstWhere(
                (g) => g['id'] == selectedGoal.value,
                orElse: () => {'label': selectedGoal.value!},
              )['label']
              as String;
      Get.find<UserProfileService>().fitnessGoal.value = label;
      Get.toNamed('/activity-level');
    } else {
      Get.snackbar('Error', 'Please select your fitness goal');
    }
  }

  void goBack() {
    Get.back();
  }
}
