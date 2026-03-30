import 'package:get/get.dart';

import '../controllers/goals_details_controller.dart';

class GoalsDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GoalsDetailsController>(() => GoalsDetailsController());
  }
}
