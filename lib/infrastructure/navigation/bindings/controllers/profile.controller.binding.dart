import 'package:get/get.dart';

import 'package:gym_trainer/app/modules/profile/controllers/profile_controller.dart';

class ProfileControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
