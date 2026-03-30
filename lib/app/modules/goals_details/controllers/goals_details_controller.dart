import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalsDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var goalsCount = 0.obs;
  var goals = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToGoalsData();
  }

  void _listenToGoalsData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (!doc.exists) return;
      final data = doc.data() ?? const <String, dynamic>{};

      goalsCount.value = (data['goalsCount'] as num?)?.toInt() ?? 0;

      // Generate sample goals for display
      _generateSampleGoals();
    });
  }

  void _generateSampleGoals() {
    final sampleGoals = <Map<String, dynamic>>[
      {
        'title': 'Build Upper Body Strength',
        'description': 'Focus on chest, shoulders, and arms',
        'progress': 65,
        'completed': false,
        'icon': '💪',
      },
      {
        'title': 'Improve Flexibility',
        'description': 'Daily yoga and stretching sessions',
        'progress': 40,
        'completed': false,
        'icon': '🧘',
      },
      {
        'title': 'Run 5K in 25 mins',
        'description': 'Cardio endurance goal',
        'progress': 75,
        'completed': false,
        'icon': '🏃',
      },
      {
        'title': 'Lose 5 lbs',
        'description': 'Achieve fitness milestone',
        'progress': 50,
        'completed': false,
        'icon': '⚖️',
      },
      {
        'title': 'Perfect Your Form',
        'description': 'Master proper lifting technique',
        'progress': 85,
        'completed': false,
        'icon': '✨',
      },
    ];

    // Only show first goalsCount items or all if count is greater
    if (goalsCount.value > 0) {
      goals.assignAll(sampleGoals.take(goalsCount.value).toList());
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
