import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/user_role_service.dart';

class SignUpController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;

  final _auth = FirebaseAuth.instance;
  final _roleService = Get.find<UserRoleService>();

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      if (credential.user != null) {
        await _roleService.ensureAndGetRole(credential.user!);
      }
      await _auth.signOut();
      Get.snackbar(
        'Account Created!',
        'Please sign in to continue',
        backgroundColor: const Color(0xFFCBFF47),
        colorText: const Color(0xFF0A0A0F),
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(Routes.LOGIN, arguments: {'email': email});
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again.';
      if (e.code == 'email-already-in-use')
        message = 'An account already exists with this email.';
      if (e.code == 'invalid-email') message = 'Invalid email address.';
      if (e.code == 'weak-password') message = 'Password is too weak.';
      Get.snackbar(
        'Error',
        message,
        backgroundColor: const Color(0xFFFF5C5C),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
