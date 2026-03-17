import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';
import 'app/services/bookings_service.dart';
import 'app/services/favourites_service.dart';
import 'app/services/user_profile_service.dart';
import 'app/services/user_role_service.dart';
import 'app/services/user_support_service.dart';

const _authEmulatorPort = 9099;
const _firestoreEmulatorPort = 8080;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _configureFirebaseEmulators();
  await Supabase.initialize(
    url: 'https://wrnimhuovvyhysiufffd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndybmltaHVvdnZ5aHlzaXVmZmZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNjQ5MDAsImV4cCI6MjA4ODk0MDkwMH0.e475CUbWI2J6avGJWQsm2oG6QhRLXCRL5eHXbbQD_DU',
  );

  // Register global services before any screen loads.
  await Get.putAsync<BookingsService>(() async => BookingsService());
  await Get.putAsync<FavouritesService>(() async => FavouritesService());
  await Get.putAsync<UserProfileService>(
    () async => UserProfileService().init(),
  );
  Get.put<UserSupportService>(UserSupportService());
  Get.put<UserRoleService>(UserRoleService());

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E1C26),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    GetMaterialApp(
      title: 'Gym Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121217),
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF896CFE),
          secondary: Color(0xFFE2F163),
          surface: Color(0xFF1E1C26),
        ),
      ),
      defaultTransition: Transition.cupertino,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

Future<void> _configureFirebaseEmulators() async {
  if (!kDebugMode) return;

  final host = _localEmulatorHost();

  await FirebaseAuth.instance.useAuthEmulator(host, _authEmulatorPort);
  FirebaseFirestore.instance.useFirestoreEmulator(host, _firestoreEmulatorPort);

  debugPrint(
    'Using Firebase emulators on $host '
    '(auth: $_authEmulatorPort, firestore: $_firestoreEmulatorPort)',
  );
}

String _localEmulatorHost() {
  if (kIsWeb) return '127.0.0.1';
  if (Platform.isAndroid) return '10.0.2.2';
  return '127.0.0.1';
}
