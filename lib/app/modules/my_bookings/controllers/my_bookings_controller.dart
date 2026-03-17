import 'package:get/get.dart';
import '../../../services/bookings_service.dart';
import '../../wallet/controllers/wallet_controller.dart';

class MyBookingsController extends GetxController {
  var tabIndex = 0.obs;

  BookingsService get _bookings => Get.find<BookingsService>();

  @override
  void onInit() {
    super.onInit();
    // Allow the caller to pre-select the Past tab via Get.arguments.
    final args = Get.arguments;
    if (args is Map && args['tab'] == 1) tabIndex.value = 1;
  }

  /// Live reference — reacts instantly to any change made elsewhere.
  RxList<Map<String, dynamic>> get upcomingBookings =>
      _bookings.upcomingBookings;

  /// Live reference — reacts instantly to any change made elsewhere.
  RxList<Map<String, dynamic>> get pastBookings => _bookings.pastBookings;

  void setTab(int index) => tabIndex.value = index;

  void cancelBooking(int index) {
    _bookings.cancelBooking(index);
    Get.snackbar(
      'Booking Cancelled',
      'Your session has been cancelled.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void payForSession(int index) {
    final booking = upcomingBookings[index];
    final trainerName = booking['trainer'] as String;
    final price = booking['price'] as int;
    final portrait = booking['portrait'] as int?;
    final wallet = Get.find<WalletController>();
    final success = wallet.payForSession(
      trainerName,
      price,
      portrait: portrait,
    );
    if (success) {
      _bookings.markPaid(index);
      Get.snackbar(
        'Payment Successful',
        '\$$price paid for your session with $trainerName.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
