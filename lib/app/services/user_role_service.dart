import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRoleService {
  UserRoleService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _roleCachePrefix = 'user_role_';

  Future<String> ensureAndGetRole(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRaw = prefs.getString('$_roleCachePrefix${user.uid}') ?? 'user';
    final cachedRole = _normalizeRole(cachedRaw);

    final ref = _firestore.collection('users').doc(user.uid);
    try {
      final snap = await ref
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 4));

      if (!snap.exists) {
        try {
          await ref
              .set({
                'name': user.displayName ?? 'User',
                'email': user.email ?? '',
                'role': 'user',
                'isActive': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              })
              .timeout(const Duration(seconds: 4));
        } catch (_) {
          // Ignore write failures when offline; default user role still works.
        }
        await prefs.setString('$_roleCachePrefix${user.uid}', 'user');
        return 'user';
      }

      final data = snap.data() ?? <String, dynamic>{};
      final rawRole = (data['role'] ?? 'user').toString().toLowerCase();
      final role = _normalizeRole(rawRole);
      await prefs.setString('$_roleCachePrefix${user.uid}', role);

      return role;
    } catch (_) {
      // If Firestore is unreachable, use last known role for smooth routing.
      return cachedRole;
    }
  }

  String _normalizeRole(String role) {
    switch (role) {
      case 'trainer':
      case 'admin':
      case 'user':
        return role;
      default:
        return 'user';
    }
  }
}
