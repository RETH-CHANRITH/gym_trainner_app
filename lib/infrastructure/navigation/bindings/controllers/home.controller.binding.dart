import 'package:get/get.dart';

import 'package:gym_trainer/app/modules/home/controllers/home_controller.dart';

class HomeControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
