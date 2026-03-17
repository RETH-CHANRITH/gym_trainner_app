import 'package:get/get.dart';

import 'package:gym_trainer/app/modules/wallet/controllers/wallet_controller.dart';

class WalletControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletController>(() => WalletController());
  }
}
