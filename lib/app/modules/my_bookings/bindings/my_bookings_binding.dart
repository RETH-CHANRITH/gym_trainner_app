import 'package:get/get.dart';
import '../controllers/my_bookings_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBookingsController>(() => MyBookingsController());
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
  }
}
