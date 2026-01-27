import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:gym_trainer/presentation/home/home.screen.dart';
import 'package:gym_trainer/presentation/profile/profile.screen.dart';
import 'package:gym_trainer/presentation/favorite/favorite_screen.dart';
import 'package:gym_trainer/presentation/wallet/wallet.screen.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // App Colors
  static const Color primaryPurple = Color(0xFF896CFE);
  static const Color darkBg = Color(0xFF121217);
  static const Color cardBg = Color(0xFF1E1C26);
  static const Color accentYellow = Color(0xFFE2F163);

  @override
  Widget build(BuildContext context) {
    final iconList = [
      Icons.home_rounded,
      Icons.bar_chart_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.person_rounded,
    ];

    final pages = [
      const HomeScreen(),
      const FavoriteScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: darkBg,
        body: SafeArea(child: pages[controller.currentIndex.value]),
        floatingActionButton: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentYellow, Color(0xFFD4E157)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentYellow.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () {
              // Quick book action
            },
            child: const Icon(Icons.add_rounded, color: darkBg, size: 28),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          backgroundColor: cardBg,
          itemCount: iconList.length,
          tabBuilder: (int index, bool isActive) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconList[index],
                  size: 24,
                  color:
                      isActive ? accentYellow : Colors.white.withOpacity(0.4),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 6 : 0,
                  height: isActive ? 6 : 0,
                  decoration: const BoxDecoration(
                    color: accentYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            );
          },
          activeIndex: controller.currentIndex.value,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          leftCornerRadius: 24,
          rightCornerRadius: 24,
          height: 70,
          splashColor: primaryPurple.withOpacity(0.1),
          splashSpeedInMilliseconds: 300,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
