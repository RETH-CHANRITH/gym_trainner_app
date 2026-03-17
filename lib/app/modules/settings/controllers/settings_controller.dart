import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';
import '../../../services/user_profile_service.dart';
import '../../../services/user_support_service.dart';

class SettingsController extends GetxController {
  var notificationsEnabled = true.obs;
  var emailUpdatesEnabled = false.obs;
  var biometricsEnabled = false.obs;
  var isSavingProfile = false.obs;
  var isSavingEmail = false.obs;
  var isSavingPassword = false.obs;
  var isSubmittingSupport = false.obs;
  var isSubmittingDeletion = false.obs;

  final UserProfileService profile = Get.find<UserProfileService>();
  final UserSupportService support = Get.find<UserSupportService>();

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value =
        prefs.getBool('settings.notifications') ?? true;
    emailUpdatesEnabled.value =
        prefs.getBool('settings.email_updates') ?? false;
    biometricsEnabled.value = prefs.getBool('settings.biometrics') ?? false;
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> toggleNotifications(bool val) async {
    notificationsEnabled.value = val;
    await _savePreference('settings.notifications', val);
    Get.snackbar(
      'Preferences',
      'Push notifications ${val ? 'enabled' : 'disabled'}.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> toggleEmailUpdates(bool val) async {
    emailUpdatesEnabled.value = val;
    await _savePreference('settings.email_updates', val);
    Get.snackbar(
      'Preferences',
      'Email updates ${val ? 'enabled' : 'disabled'}.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> toggleBiometrics(bool val) async {
    biometricsEnabled.value = val;
    await _savePreference('settings.biometrics', val);
    Get.snackbar(
      'Preferences',
      'Biometric login ${val ? 'enabled' : 'disabled'}.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void openAppVersion() {
    Get.snackbar(
      'App Version',
      'Gym Trainer v1.0.0',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<bool> saveAccountIdentity({
    required String fullName,
    required String email,
    required String currentPassword,
  }) async {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) {
      Get.snackbar('Not logged in', 'Please log in and try again.');
      return false;
    }

    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty || !GetUtils.isEmail(trimmedEmail)) {
      Get.snackbar('Invalid input', 'Please enter valid name and email.');
      return false;
    }

    isSavingProfile.value = true;
    isSavingEmail.value = true;
    try {
      final currentName = current.displayName?.trim() ?? '';
      final currentEmail = current.email?.trim() ?? '';

      if (trimmedName != currentName) {
        await current.updateDisplayName(trimmedName);
        profile.name.value = trimmedName;
      }

      if (trimmedEmail != currentEmail) {
        final providers = current.providerData.map((p) => p.providerId).toSet();
        final hasPasswordProvider = providers.contains('password');
        if (!hasPasswordProvider) {
          Get.snackbar(
            'Google account',
            'Gmail for Google Sign-In accounts must be changed in your Google account settings.',
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }

        if (currentPassword.trim().isEmpty) {
          Get.snackbar(
            'Password required',
            'Enter your current password to change Gmail instantly.',
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }

        final credential = EmailAuthProvider.credential(
          email: currentEmail,
          password: currentPassword,
        );
        await current.reauthenticateWithCredential(credential);
        await current.updateEmail(trimmedEmail);
        profile.email.value = trimmedEmail;
        Get.snackbar('Saved', 'Gmail changed successfully.');
      } else {
        Get.snackbar('Saved', 'Profile updated successfully.');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Failed to update profile.';
      if (e.code == 'requires-recent-login') {
        message = 'Please login again before changing your email.';
      } else if (e.code == 'email-already-in-use') {
        message = 'That email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }
      Get.snackbar('Update failed', message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      isSavingProfile.value = false;
      isSavingEmail.value = false;
    }
  }

  Future<void> changeProfileImage() async {
    await profile.pickAndUploadProfilePhoto();
  }

  Future<bool> updatePasswordRealtime({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim() ?? '';

    if (user == null) {
      Get.snackbar('Not logged in', 'Please login and try again.');
      return false;
    }

    final providers = user.providerData.map((p) => p.providerId).toSet();
    final hasPasswordProvider = providers.contains('password');
    final isGoogleOnly =
        providers.contains('google.com') && !hasPasswordProvider;

    if (isGoogleOnly) {
      Get.snackbar(
        'Google account',
        'This account uses Google Sign-In. Change your password from Google account settings.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    if (email.isEmpty) {
      Get.snackbar('No email', 'No email is linked to this account.');
      return false;
    }

    if (currentPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      Get.snackbar('Invalid input', 'Please fill all password fields.');
      return false;
    }

    if (newPassword.trim().length < 6) {
      Get.snackbar(
        'Weak password',
        'New password must be at least 6 characters.',
      );
      return false;
    }

    if (newPassword.trim() != confirmPassword.trim()) {
      Get.snackbar(
        'Mismatch',
        'New password and confirm password do not match.',
      );
      return false;
    }

    isSavingPassword.value = true;
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword.trim());
      Get.snackbar('Success', 'Password changed successfully.');
      return true;
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Could not change password.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please login again and then change password.';
      }
      Get.snackbar('Failed', message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      isSavingPassword.value = false;
    }
  }

  Future<void> changePassword() async {
    // UI handled in Settings view bottom sheet; keep this for backward compatibility.
    Get.snackbar(
      'Open Change Password',
      'Use the Change Password form to update instantly.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openPaymentMethods() {
    Get.toNamed(Routes.WALLET);
  }

  Future<void> openPrivacyPolicy() async {
    await _launchUrl(
      'https://www.termsfeed.com/live/17f6a095-6f8b-45b6-bdcf-9f9f6146cfa2',
    );
  }

  Future<void> openTermsOfService() async {
    await _launchUrl(
      'https://www.termsfeed.com/live/e188f17e-179f-478f-ae79-331dd882f84f',
    );
  }

  Future<void> _launchUrl(String rawUrl) async {
    final uri = Uri.parse(rawUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Error', 'Could not open link.');
    }
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1A0330),
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF8484A0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8484A0)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Color(0xFFFF4F4F)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  Future<void> openSupportCenter() async {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    final submitted = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1A0330),
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Subject',
                hintStyle: TextStyle(color: Color(0xFF8484A0)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Describe your issue',
                hintStyle: TextStyle(color: Color(0xFF8484A0)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8484A0)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Submit',
              style: TextStyle(color: Color(0xFFCBFF47)),
            ),
          ),
        ],
      ),
    );

    if (submitted != true) return;

    isSubmittingSupport.value = true;
    try {
      final ok = await support.createSupportTicket(
        subject: subjectCtrl.text,
        message: messageCtrl.text,
        category: 'in_app_support',
      );
      if (ok) {
        Get.snackbar(
          'Ticket submitted',
          'Our support team will respond as soon as possible.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSubmittingSupport.value = false;
    }
  }

  Future<void> deleteAccount() async {
    final reasonCtrl = TextEditingController();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1A0330),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your request will be reviewed by support before permanent deletion.',
              style: TextStyle(color: Color(0xFF8484A0)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Reason for deletion',
                hintStyle: TextStyle(color: Color(0xFF8484A0)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8484A0)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Submit Request',
              style: TextStyle(color: Color(0xFFFF4F4F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isSubmittingDeletion.value = true;
    try {
      final ok = await support.requestAccountDeletion(reason: reasonCtrl.text);
      if (!ok) return;

      Get.snackbar(
        'Request submitted',
        'Your account deletion request has been recorded.',
        snackPosition: SnackPosition.BOTTOM,
      );

      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isSubmittingDeletion.value = false;
    }
  }
}
