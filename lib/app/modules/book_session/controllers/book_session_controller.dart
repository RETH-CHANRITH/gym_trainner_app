import 'package:get/get.dart';
import '../../../services/bookings_service.dart';

class BookSessionController extends GetxController {
  var selectedDate = Rx<DateTime?>(null);
  var selectedSlot = RxString('');
  var selectedType = RxString('1-on-1');
  var trainerName = 'Alex Carter'.obs;
  var specialty = 'Strength & HIIT'.obs;
  var portrait = RxnInt();
  var price = 65.obs;
  var isSubmitting = false.obs;

  final List<String> sessionTypes = ['1-on-1', 'Group', 'Online'];

  BookingsService get _bookings => Get.find<BookingsService>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      trainerName.value = args['name'] as String? ?? trainerName.value;
      specialty.value = args['specialty'] as String? ?? specialty.value;
      portrait.value = args['portrait'] as int?;
      price.value = (args['price'] as int?) ?? price.value;
      final initialType = args['type'] as String?;
      if (initialType != null && sessionTypes.contains(initialType)) {
        selectedType.value = initialType;
      }
      final initialTime = args['time'] as String?;
      if (initialTime != null) {
        selectedSlot.value = initialTime;
      }
    }
  }

  final List<Map<String, dynamic>> morningSlots = [
    {'time': '06:00 AM', 'available': true},
    {'time': '07:00 AM', 'available': true},
    {'time': '08:00 AM', 'available': false},
    {'time': '09:00 AM', 'available': true},
  ];

  final List<Map<String, dynamic>> afternoonSlots = [
    {'time': '12:00 PM', 'available': true},
    {'time': '01:00 PM', 'available': false},
    {'time': '02:00 PM', 'available': true},
    {'time': '03:00 PM', 'available': true},
  ];

  final List<Map<String, dynamic>> eveningSlots = [
    {'time': '05:00 PM', 'available': true},
    {'time': '06:00 PM', 'available': true},
    {'time': '07:00 PM', 'available': false},
    {'time': '08:00 PM', 'available': true},
  ];

  void pickDate(DateTime date) => selectedDate.value = date;
  void pickQuickDate(int daysFromNow) =>
      selectedDate.value = DateTime.now().add(Duration(days: daysFromNow));
  void pickSlot(String slot) => selectedSlot.value = slot;
  void pickType(String type) => selectedType.value = type;

  bool get canConfirm =>
      selectedDate.value != null && selectedSlot.value.isNotEmpty;

  String _formatBookingDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  void confirmBooking() {
    if (isSubmitting.value) return;
    if (selectedDate.value == null || selectedSlot.value.isEmpty) {
      Get.snackbar(
        'Incomplete',
        'Please select a date and time slot',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final formattedDate = _formatBookingDate(selectedDate.value!);
    final hasConflict = _bookings.hasUpcomingConflict(
      trainer: trainerName.value,
      date: formattedDate,
      time: selectedSlot.value,
    );
    if (hasConflict) {
      Get.snackbar(
        'Already Booked',
        'You already have this session in upcoming bookings.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;

    _bookings.addBooking({
      'trainer': trainerName.value,
      'specialty': specialty.value,
      'date': formattedDate,
      'time': selectedSlot.value,
      'type': selectedType.value,
      'status': 'pending',
      'portrait': portrait.value,
      'price': price.value,
      'paid': false,
    });

    Get.snackbar(
      'Booking Confirmed',
      '${trainerName.value} has been added to your upcoming bookings.',
      snackPosition: SnackPosition.BOTTOM,
    );
    isSubmitting.value = false;
    Get.offNamed('/my-bookings', arguments: {'tab': 0});
  }
}
