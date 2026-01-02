import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../utils/logger.dart';

/// Service for managing timezone detection, storage, and conversion.
/// 
/// Responsibilities:
/// 1. Initialize timezone database on app start
/// 2. Detect device timezone
/// 3. Sync timezone preference with Supabase profiles table
/// 4. Provide utility methods for timezone-aware DateTime operations
class TimezoneService {
  final SupabaseClient _supabase;
  
  /// The user's current timezone location, defaults to UTC
  tz.Location _userLocation = tz.UTC;
  
  /// The IANA timezone name (e.g., "Asia/Jakarta")
  String _timezoneName = 'UTC';

  TimezoneService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Initialize timezone database and detect device timezone.
  /// Call this early in app lifecycle (main.dart).
  Future<void> initialize() async {
    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();
      AppLogger.d('Timezone database initialized');

      // Detect device timezone (returns TimezoneInfo with .identifier)
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      _timezoneName = tzInfo.identifier;
      
      // Set local location
      _userLocation = tz.getLocation(_timezoneName);
      tz.setLocalLocation(_userLocation);
      
      AppLogger.i('Device timezone detected: $_timezoneName');
    } catch (e, s) {
      AppLogger.e('Failed to initialize timezone', e, s);
      // Fallback to UTC
      _timezoneName = 'UTC';
      _userLocation = tz.UTC;
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Sync the detected timezone to user's profile in Supabase.
  /// Call after user is authenticated.
  Future<void> syncToProfile(String userId) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'timezone': _timezoneName,
      });
      AppLogger.i('Timezone synced to profile: $_timezoneName');
    } catch (e, s) {
      AppLogger.e('Failed to sync timezone to profile', e, s);
    }
  }

  /// Load timezone from user's profile (for cases where device TZ differs from preference).
  Future<void> loadFromProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('timezone')
          .eq('id', userId)
          .maybeSingle();
      
      if (data != null && data['timezone'] != null) {
        final savedTz = data['timezone'] as String;
        if (savedTz.isNotEmpty && savedTz != 'UTC') {
          _timezoneName = savedTz;
          _userLocation = tz.getLocation(_timezoneName);
          tz.setLocalLocation(_userLocation);
          AppLogger.i('Loaded timezone from profile: $_timezoneName');
        }
      }
    } catch (e, s) {
      AppLogger.e('Failed to load timezone from profile', e, s);
    }
  }

  // ============== Getters ==============

  /// Get the current timezone name (IANA format)
  String get timezoneName => _timezoneName;

  /// Get the current timezone location
  tz.Location get location => _userLocation;

  /// Get the current timezone offset from UTC
  Duration get offset => Duration(milliseconds: _userLocation.currentTimeZone.offset);

  // ============== Conversion Utilities ==============

  /// Convert a UTC DateTime to the user's local timezone.
  tz.TZDateTime toLocal(DateTime utcDateTime) {
    return tz.TZDateTime.from(utcDateTime.toUtc(), _userLocation);
  }

  /// Convert a local DateTime to UTC for storage.
  DateTime toUtc(DateTime localDateTime) {
    final tzLocal = tz.TZDateTime(
      _userLocation,
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
      localDateTime.hour,
      localDateTime.minute,
      localDateTime.second,
      localDateTime.millisecond,
    );
    return tzLocal.toUtc();
  }

  /// Create a TZDateTime in the user's timezone.
  tz.TZDateTime createLocal(int year, int month, int day, [int hour = 0, int minute = 0]) {
    return tz.TZDateTime(_userLocation, year, month, day, hour, minute);
  }

  /// Get current time in user's timezone.
  tz.TZDateTime now() {
    return tz.TZDateTime.now(_userLocation);
  }

  /// Parse an ISO8601 string from DB (UTC) and convert to local.
  tz.TZDateTime? parseFromDb(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      final utc = DateTime.parse(isoString).toUtc();
      return tz.TZDateTime.from(utc, _userLocation);
    } catch (e) {
      AppLogger.w('Failed to parse datetime: $isoString');
      return null;
    }
  }

  /// Format a DateTime for DB storage (UTC ISO8601).
  String? formatForDb(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toUtc().toIso8601String();
  }
}
