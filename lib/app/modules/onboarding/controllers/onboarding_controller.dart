import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/user_role_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final totalPages = 3;
  final _roleService = Get.find<UserRoleService>();

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void skip() => _finish();

  Future<void> _finish() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
