import 'package:get/get.dart';

import '../controllers/streak_details_controller.dart';

class StreakDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StreakDetailsController>(() => StreakDetailsController());
  }
}
