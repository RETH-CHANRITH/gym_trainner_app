import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../routes/app_pages.dart';
import '../../../services/user_role_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  int _wrongPasswordCount = 0;

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  // Get UserRoleService lazily when needed, not at init time
  UserRoleService get _roleService => Get.find<UserRoleService>();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill email if passed from sign-up screen
    final args = Get.arguments;
    if (args != null && args['email'] != null) {
      emailController.text = args['email'];
    }
  }

  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar(
          'Cancelled',
          'Google sign-in was cancelled.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        Get.snackbar(
          'Google sign-in failed',
          'Missing Google ID token. This is usually a Firebase/Google config issue (Google provider not enabled, SHA fingerprints, or device Google Play Services).',
          backgroundColor: const Color(0xFFFF5C5C),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      if (result.user == null) {
        Get.snackbar(
          'Sign-in failed',
          'Google authentication returned no user. Please try again.',
          backgroundColor: const Color(0xFFFF5C5C),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      await _redirectByRole(result.user);
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Google sign-in failed.';
      if (e.code == 'network-request-failed') {
        message =
            'Network error while contacting Firebase. On emulator this is often DNS/proxy/VPN related — try opening https://accounts.google.com in the emulator browser, disable any VPN/proxy, and restart the emulator.';
      } else if (e.code == 'operation-not-allowed') {
        message =
            'Google sign-in is disabled in Firebase Auth. Enable it in Firebase Console → Authentication → Sign-in method → Google.';
      } else if (e.code == 'account-exists-with-different-credential') {
        message =
            'This email is linked with another sign-in method. Use that method first.';
      } else if (e.code == 'invalid-credential') {
        message =
            'Invalid Google credential. Verify Firebase project config and SHA fingerprints.';
      }
      Get.snackbar(
        'Error',
        '$message (code: ${e.code})',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } on PlatformException catch (e) {
      final details = '${e.code}${e.message != null ? ': ${e.message}' : ''}';

      // Common GoogleSignIn plugin codes:
      // - sign_in_canceled
      // - sign_in_failed (often contains ApiException: 10 developer_error / SHA1 mismatch)
      // - network_error
      // - sign_in_required
      final hint = switch (e.code) {
        'network_error' =>
          'This is almost always a device/emulator network/DNS issue. If IP works but hosts fail ("unknown host"), fix DNS/proxy/VPN and restart the emulator. Also ensure the emulator image includes Google Play services.',
        'sign_in_canceled' => 'You cancelled the Google account chooser.',
        'sign_in_failed' =>
          'If you see ApiException: 10, this is a SHA-1/OAuth client mismatch or missing Google Play Services.',
        _ => null,
      };

      Get.snackbar(
        'Google Sign-In error',
        hint == null
            ? 'Platform error: $details'
            : 'Platform error: $details\n$hint',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 7),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google sign-in failed: $e',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _wrongPasswordCount = 0;
      await _redirectByRole(result.user);
    } on FirebaseAuthException catch (e) {
      _wrongPasswordCount++;

      if (_wrongPasswordCount >= 3) {
        _wrongPasswordCount = 0;
        Get.snackbar(
          'Too many failed attempts',
          'Redirecting you to create a new account...',
          backgroundColor: const Color(0xFFFF5C5C),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(Routes.SIGN_UP);
        return;
      }

      String message = 'Login failed. Please try again.';
      if (e.code == 'user-not-found')
        message = 'No account found with this email.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential')
        message = 'Incorrect password.';
      if (e.code == 'invalid-email') message = 'Invalid email address.';

      final remaining = 3 - _wrongPasswordCount;
      Get.snackbar(
        'Error',
        '$message $remaining attempt(s) left.',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Enter your email first',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Sent',
        'Password reset email sent',
        backgroundColor: const Color(0xFFCBFF47),
        colorText: const Color(0xFF0A0A0F),
        snackPosition: SnackPosition.TOP,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Failed to send reset email',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _redirectByRole(User? user) async {
    if (user == null) {
      Get.offAllNamed(Routes.HOME);
      return;
    }

    try {
      final role = await _roleService.ensureAndGetRole(user);
      switch (role) {
        case 'trainer':
          Get.offAllNamed(Routes.TRAINER_DASHBOARD);
          break;
        case 'admin':
          Get.offAllNamed(Routes.ADMIN_DASHBOARD);
          break;
        default:
          Get.offAllNamed(Routes.HOME);
      }
    } catch (_) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  @override
  void onClose() {
    // Avoid disposing text controllers here because this page can be replaced
    // during transition animations, causing TextField to read a disposed
    // controller for one frame.
    super.onClose();
  }
}
