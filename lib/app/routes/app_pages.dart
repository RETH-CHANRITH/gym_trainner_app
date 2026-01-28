import 'package:get/get.dart';

import '../modules/favorite/views/favorite_view.dart';
import '../modules/favourite/bindings/favourite_binding.dart';
import '../modules/favourite/views/favourite_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/message_screen/bindings/message_screen_binding.dart';
import '../modules/message_screen/views/message_screen_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_screen.dart';
import '../modules/sign_up/bindings/sign_up_binding.dart';
import '../modules/sign_up/views/sign_up_view.dart';
import '../modules/trainer/bindings/trainer_details_binding.dart';
import '../modules/trainer/views/trainer_details_view.dart';
import '../modules/wallet/views/wallet_screen.dart';

// import '../modules/trainer/views/trainer_details_view.dart';
// TrainerDetails route temporarily removed for error fix

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.FAVORITE,
      page: () => const FavoriteView(),
    ),
    GetPage(
      name: Routes.WALLET,
      page: () => WalletScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.FAVOURITE,
      page: () => const FavouriteView(),
      binding: FavouriteBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGE_SCREEN,
      page: () => const MessageScreenView(),
      binding: MessageScreenBinding(),
    ),
    GetPage(
      name: _Paths.TRAINER_DETAILS,
      page: () => TrainerDetailsView(),
      binding: TrainerDetailsBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
  ];
}
