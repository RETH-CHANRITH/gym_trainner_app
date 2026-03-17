import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final notifications =
      <Map<String, dynamic>>[
        {
          'title': 'Booking Reminder',
          'body': 'Tomorrow: John Smith at 10:00 AM — Strength & HIIT session.',
          'time': '1 day ago',
          'icon': 'calendar',
          'read': false,
          'color': 'lilac',
          'route': '/my-bookings',
          'routeArgs': null,
        },
        {
          'title': 'Session Alert',
          'body': 'Your session with Alex Carter starts in 30 minutes!',
          'time': '30 min ago',
          'icon': 'alarm',
          'read': false,
          'color': 'coral',
          'route': '/my-bookings',
          'routeArgs': null,
        },
        {
          'title': 'Payment Confirmed',
          'body': '\$30.00 payment confirmed for your session with Priya Shah.',
          'time': '2 hrs ago',
          'icon': 'payment',
          'read': false,
          'color': 'neon',
          'route': '/wallet',
          'routeArgs': null,
        },
        {
          'title': 'New Message',
          'body': 'John Smith sent you a message.',
          'time': '3 hrs ago',
          'icon': 'chat',
          'read': true,
          'color': 'sky',
          'route': '/message-screen',
          'routeArgs': {
            'name': 'John Smith',
            'specialty': 'Strength Training',
            'portrait': 11,
            'online': true,
          },
        },
        {
          'title': 'Review Request',
          'body':
              'How was your session? Rate your experience with Jordan Miles.',
          'time': '5 hrs ago',
          'icon': 'review',
          'read': true,
          'color': 'gold',
          'route': '/my-bookings',
          'routeArgs': null,
        },
        {
          'title': 'Promotion',
          'body': 'Limited time! Get 20% OFF your next session. Claim now.',
          'time': '1 day ago',
          'icon': 'promo',
          'read': true,
          'color': 'neon',
          'route': '/search',
          'routeArgs': null,
        },
      ].obs;

  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _refreshUnread();
  }

  void _refreshUnread() {
    unreadCount.value = notifications.where((n) => n['read'] == false).length;
  }

  void markAllRead() {
    for (final n in notifications) {
      n['read'] = true;
    }
    notifications.refresh();
    _refreshUnread();
  }

  void tappedNotification(Map<String, dynamic> n) {
    n['read'] = true;
    notifications.refresh();
    _refreshUnread();
    final route = n['route'] as String?;
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route, arguments: n['routeArgs']);
    }
  }

  void addNotification(Map<String, dynamic> notif) {
    notifications.insert(0, notif);
    _refreshUnread();
  }
}
