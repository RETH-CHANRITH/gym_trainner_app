import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var streak = 0.obs;
  var streakHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToStreakData();
  }

  void _listenToStreakData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (!doc.exists) return;
      final data = doc.data() ?? const <String, dynamic>{};

      streak.value = (data['streak'] as num?)?.toInt() ?? 0;

      // Generate sample history for display
      _generateStreakHistory();
    });
  }

  void _generateStreakHistory() {
    final history = <Map<String, dynamic>>[];
    for (int i = 0; i < streak.value; i++) {
      final daysAgo = streak.value - 1 - i;
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      history.add({
        'date': date,
        'day': date.toString().split(' ')[0],
        'dayOfWeek':
            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
        'completed': true,
      });
    }
    streakHistory.assignAll(history);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
