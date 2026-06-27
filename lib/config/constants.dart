class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Bid Management';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String firstLaunchKey = 'first_launch';

  // Hive Box Names
  static const String bidBoxName = 'bids';
  static const String userBoxName = 'user';
  static const String syncQueueBoxName = 'sync_queue';
  static const String settingsBoxName = 'settings';

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;

  // Sync Interval
  static const int syncIntervalMinutes = 5;

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Currency
  static const String currencySymbol = '\RS';
  static const String currencyCode = 'PKR';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 1000;
}

class AppAssets {
  AppAssets._();

  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emptyBids = 'assets/images/empty_bids.png';
  static const String noInternet = 'assets/images/no_internet.png';
  static const String success = 'assets/images/success.png';

  // Icons
  static const String googleIcon = 'assets/icons/google.svg';
  static const String bidIcon = 'assets/icons/bid.svg';
  static const String syncIcon = 'assets/icons/sync.svg';

  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';
  static const String emptyAnimation = 'assets/animations/empty.json';
  static const String syncAnimation = 'assets/animations/sync.json';
  static const String offlineAnimation = 'assets/animations/offline.json';
}
