part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const FAVORITE = _Paths.FAVORITE;
  static const WALLET = _Paths.WALLET;
  static const PROFILE = _Paths.PROFILE;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const FAVORITE = '/favorite';
  static const WALLET = '/wallet';
  static const PROFILE = '/profile';
}
