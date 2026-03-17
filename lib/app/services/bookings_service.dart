import 'package:get/get.dart';

/// Singleton service that holds the user's bookings as reactive lists.
/// Both [HomeController] and [MyBookingsController] read from here so
/// any mutation (cancel, add) is instantly reflected on every screen.
class BookingsService extends GetxService {
  // ─── Upcoming bookings ────────────────────────────────────────────────────
  final upcomingBookings =
      <Map<String, dynamic>>[
        {
          'trainer': 'Alex Carter',
          'specialty': 'Strength & HIIT',
          'date': 'Mon, Mar 10, 2026',
          'time': '07:00 AM',
          'type': '1-on-1',
          'status': 'confirmed',
          'portrait': 10,
          'price': 65,
          'paid': false,
        },
        {
          'trainer': 'Jordan Miles',
          'specialty': 'Yoga & Mobility',
          'date': 'Wed, Mar 12, 2026',
          'time': '06:00 PM',
          'type': 'Online',
          'status': 'pending',
          'portrait': 11,
          'price': 55,
          'paid': false,
        },
        {
          'trainer': 'Priya Shah',
          'specialty': 'Pilates & Core',
          'date': 'Fri, Mar 14, 2026',
          'time': '08:00 AM',
          'type': 'Group',
          'status': 'confirmed',
          'portrait': 47,
          'price': 40,
          'paid': false,
        },
      ].obs;

  // ─── Past bookings ────────────────────────────────────────────────────────
  final pastBookings =
      <Map<String, dynamic>>[
        {
          'trainer': 'Sam Rivera',
          'specialty': 'Cardio & Boxing',
          'date': 'Mon, Feb 24, 2026',
          'time': '06:00 PM',
          'type': '1-on-1',
          'status': 'completed',
          'portrait': 12,
        },
        {
          'trainer': 'Chris Lee',
          'specialty': 'Powerlifting',
          'date': 'Thu, Feb 20, 2026',
          'time': '07:00 AM',
          'type': '1-on-1',
          'status': 'cancelled',
          'portrait': 13,
        },
      ].obs;

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Cancels an upcoming booking by index: moves it to [pastBookings]
  /// with status 'cancelled'. Both screens update immediately.
  void cancelBooking(int index) {
    if (index < 0 || index >= upcomingBookings.length) return;
    final cancelled = Map<String, dynamic>.from(upcomingBookings[index])
      ..['status'] = 'cancelled';
    upcomingBookings.removeAt(index);
    pastBookings.insert(0, cancelled);
  }

  /// Marks an upcoming booking as paid by index.
  void markPaid(int index) {
    if (index < 0 || index >= upcomingBookings.length) return;
    final updated = Map<String, dynamic>.from(upcomingBookings[index])
      ..['paid'] = true;
    upcomingBookings[index] = updated;
  }

  /// Adds a new upcoming booking (e.g. after booking flow completes).
  /// New entries are inserted at top so users instantly see latest booking.
  void addBooking(Map<String, dynamic> booking) {
    upcomingBookings.insert(0, booking);
  }

  /// Returns true when another upcoming booking already exists for the
  /// same trainer/date/time slot.
  bool hasUpcomingConflict({
    required String trainer,
    required String date,
    required String time,
  }) {
    return upcomingBookings.any(
      (b) => b['trainer'] == trainer && b['date'] == date && b['time'] == time,
    );
  }
}
