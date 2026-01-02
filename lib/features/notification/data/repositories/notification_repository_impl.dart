import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/utils/logger.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> saveDeviceToken(String token, String userId) async {
    try {
      AppLogger.d('Saving device token for user: $userId');
      String platform;
      if (kIsWeb) {
        platform = 'web';
      } else if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      } else {
        // Fallback for Desktop (Windows/Mac/Linux) to 'web' 
        // because DB only allows: android, ios, web
        platform = 'web';
      }
      
      // Upsert token
      await _supabase.from('user_devices').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': platform,
        // 'device_name': ... (optional)
        'is_active': true,
        'last_used_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token'); // Ensure we update if token exists or insert if new
      AppLogger.i('Device token saved successfully');
    } catch (e, s) {
      AppLogger.e('Failed to save device token', e, s);
      // We often silence notification errors to avoid interrupting user flow, 
      // but rethrowing is cleaner for architecture. 
      // For now, let's catch only or rethrow? 
      // Given it's void return, rethrow allows caller to handle/ignore.
      // But commonly notification failure shouldn't block app usage.
      // I'll rethrow for now so we see it.
      rethrow;
    }
  }

  @override
  Future<void> deleteDeviceToken(String token) async {
    try {
      AppLogger.d('Deleting device token');
      await _supabase.from('user_devices').delete().eq('fcm_token', token);
      AppLogger.i('Device token deleted successfully');
    } catch (e, s) {
      AppLogger.e('Failed to delete device token', e, s);
      rethrow;
    }
  }
}
