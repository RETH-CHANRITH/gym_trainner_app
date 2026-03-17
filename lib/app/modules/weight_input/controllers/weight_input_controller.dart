import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/user_profile_service.dart';

class WeightInputController extends GetxController {
  var weight = Rx<int?>(null);
  final weightController = TextEditingController();

  void setWeight(int value) {
    weight.value = value;
    weightController.text = value.toString();
  }

  void nextStep() {
    if (weight.value != null && weight.value! > 0) {
      Get.find<UserProfileService>().weight.value = weight.value!;
      Get.toNamed('/height-input');
    } else {
      Get.snackbar('Error', 'Please enter a valid weight');
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    weightController.dispose();
    super.onClose();
  }
}
