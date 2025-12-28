/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Ripple';
  static const String appVersion = '1.0.0';

  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache Duration
  static const Duration cacheDuration = Duration(days: 7);

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}
