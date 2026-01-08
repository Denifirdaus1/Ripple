import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching and caching remote configuration from Supabase.
///
/// Usage:
/// ```dart
/// await RemoteConfigService.instance.fetchConfigs();
/// bool showNotes = RemoteConfigService.instance.isEnabled('show_notes_tab');
/// ```
class RemoteConfigService {
  // Singleton
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  final SupabaseClient _client = Supabase.instance.client;

  // In-memory cache
  final Map<String, dynamic> _cache = {};
  DateTime? _lastFetch;
  bool _isInitialized = false;

  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Fetch all configs from Supabase (with cache)
  Future<void> fetchConfigs({bool force = false}) async {
    // Skip if cache is still valid
    if (!force && _lastFetch != null) {
      final elapsed = DateTime.now().difference(_lastFetch!);
      if (elapsed < _cacheDuration && _cache.isNotEmpty) {
        debugPrint(
          '[RemoteConfig] Using cached configs (${elapsed.inSeconds}s old)',
        );
        return;
      }
    }

    try {
      debugPrint('[RemoteConfig] Fetching configs from Supabase...');
      final response = await _client.from('app_configs').select('key, value');

      _cache.clear();
      for (final row in response as List) {
        _cache[row['key'] as String] = row['value'];
      }

      _lastFetch = DateTime.now();
      _isInitialized = true;
      debugPrint('[RemoteConfig] Loaded ${_cache.length} configs');
    } catch (e) {
      debugPrint('[RemoteConfig] Error fetching configs: $e');
      // Keep existing cache on error
      if (_cache.isEmpty) {
        _isInitialized =
            true; // Mark as initialized even on error, use defaults
      }
    }
  }

  /// Get a config value with type casting
  /// Returns [defaultValue] if key not found or type mismatch
  T getValue<T>(String key, T defaultValue) {
    if (!_cache.containsKey(key)) {
      return defaultValue;
    }

    final value = _cache[key];

    // Handle JSONB boolean stored as string
    if (T == bool) {
      if (value is bool) return value as T;
      if (value is String) {
        return (value.toLowerCase() == 'true') as T;
      }
    }

    // Handle JSONB string (may be quoted)
    if (T == String && value is String) {
      // Remove surrounding quotes if present
      if (value.startsWith('"') && value.endsWith('"')) {
        return value.substring(1, value.length - 1) as T;
      }
      return value as T;
    }

    // Direct type match
    if (value is T) {
      return value;
    }

    return defaultValue;
  }

  /// Convenience method for boolean configs
  bool isEnabled(String key, {bool defaultValue = true}) {
    return getValue<bool>(key, defaultValue);
  }

  /// Check if maintenance mode is active
  bool get isMaintenanceMode => getValue<bool>('is_maintenance_mode', false);

  /// Get maintenance message
  String get maintenanceMessage => getValue<String>(
    'maintenance_message',
    'Aplikasi sedang dalam pemeliharaan.',
  );

  /// Force refresh cache
  Future<void> refresh() async {
    await fetchConfigs(force: true);
  }

  /// Clear cache (useful for logout)
  void clearCache() {
    _cache.clear();
    _lastFetch = null;
    _isInitialized = false;
  }
}
