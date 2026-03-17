import 'package:get/get.dart';

import '../controllers/trainer_dashboard_controller.dart';

class TrainerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrainerDashboardController>(() => TrainerDashboardController());
  }
}
