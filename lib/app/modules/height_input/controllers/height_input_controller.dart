import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/user_profile_service.dart';

class HeightInputController extends GetxController {
  var height = Rx<int?>(null);
  final heightController = TextEditingController();

  void setHeight(int value) {
    height.value = value;
    heightController.text = value.toString();
  }

  void nextStep() {
    if (height.value != null && height.value! > 0) {
      Get.find<UserProfileService>().height.value = height.value!;
      Get.toNamed('/fitness-goal');
    } else {
      Get.snackbar('Error', 'Please enter a valid height');
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    heightController.dispose();
    super.onClose();
  }
}
