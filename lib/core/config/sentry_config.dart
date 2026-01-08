import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized Sentry configuration following best practices.
///
/// Best practices applied:
/// - DSN from environment variable (not hardcoded)
/// - Dynamic sample rates based on environment
/// - beforeSend for filtering unwanted errors
/// - tracePropagationTargets for distributed tracing
/// - Privacy-first (sendDefaultPii: false)
class SentryConfig {
  /// Get DSN from environment variable
  static String? get dsn => dotenv.env['SENTRY_DSN'];

  /// Get environment (production, staging, development)
  static String get environment =>
      dotenv.env['SENTRY_ENVIRONMENT'] ??
      (kReleaseMode ? 'production' : 'development');

  /// Get release version (app-name@version+build)
  /// Format: package@version+buildNumber
  static String get release => 'ripple@1.0.0+1';

  /// Get distribution (build variant)
  static String get dist => kReleaseMode ? 'release' : 'debug';

  /// Whether Sentry should be enabled
  /// Disabled if no DSN or in debug mode (optional)
  static bool get isEnabled => dsn != null && dsn!.isNotEmpty;

  /// Traces sample rate (0.0 - 1.0)
  /// Production: 0.1 (10%), Development: 1.0 (100%)
  static double get tracesSampleRate => kReleaseMode ? 0.1 : 1.0;

  /// Profiles sample rate (relative to traces)
  /// Production: 0.1 (10%), Development: 1.0 (100%)
  static double get profilesSampleRate => kReleaseMode ? 0.1 : 1.0;

  /// Configure Sentry options with best practices
  static void configure(SentryFlutterOptions options) {
    options.dsn = dsn;
    options.environment = environment;
    options.release = release;
    options.dist = dist;

    // Sample rates - optimized for production
    options.tracesSampleRate = tracesSampleRate;
    options.profilesSampleRate = profilesSampleRate;

    // Privacy - don't send PII by default
    options.sendDefaultPii = false;

    // Performance monitoring
    options.enableAutoPerformanceTracing = true;

    // Distributed tracing to Supabase API
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    if (supabaseUrl != null && supabaseUrl.isNotEmpty) {
      options.tracePropagationTargets.add(supabaseUrl);
    }

    // Debug mode - auto-detected based on build mode
    options.debug = kDebugMode;
    options.diagnosticLevel = kDebugMode
        ? SentryLevel.debug
        : SentryLevel.error;

    // Session tracking
    options.enableAutoSessionTracking = true;

    // Filter unwanted errors before sending
    options.beforeSend = _beforeSend;
  }

  /// Filter errors before sending to Sentry.
  ///
  /// Returns null to skip the event, or the event to send it.
  static SentryEvent? _beforeSend(SentryEvent event, Hint hint) {
    final exception = event.throwable;
    if (exception == null) return event;

    final message = exception.toString().toLowerCase();

    // Skip common network errors (user is offline)
    if (_isNetworkError(message)) {
      return null;
    }

    // Skip Flutter framework errors that are not actionable
    if (_isFrameworkNoise(message)) {
      return null;
    }

    return event;
  }

  /// Check if error is a network-related error
  static bool _isNetworkError(String message) {
    return message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('network is unreachable') ||
        message.contains('no internet') ||
        message.contains('failed host lookup') ||
        message.contains('connection timed out');
  }

  /// Check if error is Flutter framework noise
  static bool _isFrameworkNoise(String message) {
    return message.contains('renderflex overflowed') ||
        message.contains('a renderflex overflowed');
  }
}
