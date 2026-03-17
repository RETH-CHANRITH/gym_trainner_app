import 'package:get/get.dart';
import 'package:gym_trainer/app/modules/favorite/controllers/favorite_controller.dart';

class FavoriteControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteController>(() => FavoriteController());
  }
}
