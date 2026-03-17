import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service that stores the user's favourite trainers reactively.
/// Any screen can read/toggle favourites and the Favourites page updates live.
class FavouritesService extends GetxService {
  static const _kKey = 'favourites_list';

  /// Reactive list of favourite trainer maps.
  final favourites = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  bool isFavourite(String name) => favourites.any((t) => t['name'] == name);

  /// Toggle: add if not present, remove if already saved.
  void toggle(Map<String, dynamic> trainer) {
    final name = trainer['name'] as String;
    if (isFavourite(name)) {
      favourites.removeWhere((t) => t['name'] == name);
    } else {
      favourites.add(_normalise(trainer));
    }
    _save();
  }

  // ─── Normalise varying trainer map shapes into one canonical shape ────────

  Map<String, dynamic> _normalise(Map<String, dynamic> t) {
    // Extract portrait index from a randomuser URL if present
    int? portrait = t['portrait'] as int?;
    if (portrait == null) {
      final img = (t['image'] as String? ?? '');
      final match = RegExp(r'/men/(\d+)\.jpg').firstMatch(img);
      if (match != null) portrait = int.tryParse(match.group(1) ?? '');
    }

    return {
      'name': t['name'] ?? '',
      'specialty': t['specialty'] ?? '',
      'rating': (t['rating'] as num?)?.toDouble() ?? 0.0,
      'price': (t['price'] ?? t['pricePerHour'] ?? 0) as int,
      'sessions': (t['sessions'] ?? 0) as int,
      'portrait': portrait ?? 10,
      'available': t['available'] ?? t['isAvailable'] ?? false,
    };
  }

  // ─── Persistence ─────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      favourites.assignAll(decoded.cast<Map<String, dynamic>>());
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_kKey, jsonEncode(favourites.toList()));
  }
}
