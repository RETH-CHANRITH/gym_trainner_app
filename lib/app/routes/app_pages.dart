import 'package:get/get.dart';
import 'package:gym_trainer/app/modules/home/views/home_view.dart';
import 'package:gym_trainer/app/modules/home/bindings/home_binding.dart';
import 'package:gym_trainer/presentation/favorite/favorite_screen.dart';
import 'package:gym_trainer/presentation/wallet/wallet.screen.dart';
import 'package:gym_trainer/presentation/profile/profile.screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.FAVORITE,
      page: () => const FavoriteScreen(),
    ),
    GetPage(
      name: Routes.WALLET,
      page: () => WalletScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
    ),
  ];
}
