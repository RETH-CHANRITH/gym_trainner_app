import 'package:get/get.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/favorite/bindings/favorite_binding.dart';
import '../modules/favorite/views/favorite_view.dart';
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
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_screen.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/get_started/bindings/get_started_binding.dart';
import '../modules/get_started/views/get_started_view.dart';
import '../modules/gender_selection/bindings/gender_selection_binding.dart';
import '../modules/gender_selection/views/gender_selection_view.dart';
import '../modules/age_input/bindings/age_input_binding.dart';
import '../modules/age_input/views/age_input_view.dart';
import '../modules/weight_input/bindings/weight_input_binding.dart';
import '../modules/weight_input/views/weight_input_view.dart';
import '../modules/height_input/bindings/height_input_binding.dart';
import '../modules/height_input/views/height_input_view.dart';
import '../modules/fitness_goal/bindings/fitness_goal_binding.dart';
import '../modules/fitness_goal/views/fitness_goal_view.dart';
import '../modules/activity_level/bindings/activity_level_binding.dart';
import '../modules/activity_level/views/activity_level_view.dart';
import '../modules/fitness_level/bindings/fitness_level_binding.dart';
import '../modules/fitness_level/views/fitness_level_view.dart';
import '../modules/notification_permission/bindings/notification_permission_binding.dart';
import '../modules/notification_permission/views/notification_permission_view.dart';
import '../modules/profile_summary/bindings/profile_summary_binding.dart';
import '../modules/profile_summary/views/profile_summary_view.dart';
import '../modules/book_session/bindings/book_session_binding.dart';
import '../modules/book_session/views/book_session_view.dart';
import '../modules/my_bookings/bindings/my_bookings_binding.dart';
import '../modules/my_bookings/views/my_bookings_view.dart';
import '../modules/home/views/all_sessions_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/wallet/views/transaction_history_screen.dart';
import '../modules/trainer_dashboard/bindings/trainer_dashboard_binding.dart';
import '../modules/trainer_dashboard/views/trainer_dashboard_view.dart';
import '../modules/admin_dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin_dashboard/views/admin_dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.FAVORITE,
      page: () => const FavouriteView(),
      binding: FavoriteBinding(),
    ),
    GetPage(
      name: Routes.WALLET,
      page: () => WalletScreen(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.FAVOURITE,
      page: () => const FavouriteView(),
      binding: FavoriteBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGE_SCREEN,
      page: () => const MessagingScreen(),
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
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.GET_STARTED,
      page: () => const GetStartedView(),
      binding: GetStartedBinding(),
    ),
    GetPage(
      name: _Paths.GENDER_SELECTION,
      page: () => const GenderSelectionView(),
      binding: GenderSelectionBinding(),
    ),
    GetPage(
      name: _Paths.AGE_INPUT,
      page: () => const AgeInputView(),
      binding: AgeInputBinding(),
    ),
    GetPage(
      name: _Paths.WEIGHT_INPUT,
      page: () => const WeightInputView(),
      binding: WeightInputBinding(),
    ),
    GetPage(
      name: _Paths.HEIGHT_INPUT,
      page: () => const HeightInputView(),
      binding: HeightInputBinding(),
    ),
    GetPage(
      name: _Paths.FITNESS_GOAL,
      page: () => const FitnessGoalView(),
      binding: FitnessGoalBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVITY_LEVEL,
      page: () => const ActivityLevelView(),
      binding: ActivityLevelBinding(),
    ),
    GetPage(
      name: _Paths.FITNESS_LEVEL,
      page: () => const FitnessLevelView(),
      binding: FitnessLevelBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION_PERMISSION,
      page: () => const NotificationPermissionView(),
      binding: NotificationPermissionBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_SUMMARY,
      page: () => const ProfileSummaryView(),
      binding: ProfileSummaryBinding(),
    ),
    GetPage(
      name: _Paths.BOOK_SESSION,
      page: () => const BookSessionView(),
      binding: BookSessionBinding(),
    ),
    GetPage(
      name: _Paths.MY_BOOKINGS,
      page: () => const MyBookingsView(),
      binding: MyBookingsBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.TRAINER_DASHBOARD,
      page: () => const TrainerDashboardView(),
      binding: TrainerDashboardBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: _Paths.TX_HISTORY,
      page: () => const TransactionHistoryScreen(),
      binding: WalletBinding(),
    ),
    GetPage(name: _Paths.ALL_SESSIONS, page: () => const AllSessionsView()),
  ];
}
