import 'package:get/get.dart';

class MessageScreenController extends GetxController {
  final messages =
      <Map<String, dynamic>>[
        {
          'text':
              "Hi! Ready for today's workout? Let me know if you have any questions!",
          'isMe': false,
          'time': '9:00 AM',
          'status': null,
        },
        {
          'text': 'Hi Coach! Should I eat before or after my morning workout?',
          'isMe': true,
          'time': '9:02 AM',
          'status': 'read',
        },
        {
          'text':
              "A light snack before can help with energy - depends on your goals. Let's discuss!",
          'isMe': false,
          'time': '9:04 AM',
          'status': null,
        },
        {
          'text': 'That makes sense. What do you recommend for a 6am session?',
          'isMe': true,
          'time': '9:05 AM',
          'status': 'read',
        },
        {
          'text': 'Banana + peanut butter 30min before. Simple, effective.',
          'isMe': false,
          'time': '9:07 AM',
          'status': null,
        },
      ].obs;

  final quickReplies = <String>[
    'Sounds good!',
    'What time?',
    'Ready!',
    'Let\'s go!',
  ];

  final showExtras = false.obs;

  void toggleExtras() => showExtras.value = !showExtras.value;

  void hideExtras() => showExtras.value = false;

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    messages.add({
      'text': trimmed,
      'isMe': true,
      'time': 'Now',
      'status': 'sent',
    });
    hideExtras();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
