import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> saveDeviceToken(String token, String userId) async {
    final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
    
    // Upsert token
    await _supabase.from('user_devices').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': platform,
      // 'device_name': ... (optional)
      'is_active': true,
      'last_used_at': DateTime.now().toIso8601String(),
    }, onConflict: 'fcm_token'); // Ensure we update if token exists or insert if new
  }

  @override
  Future<void> deleteDeviceToken(String token) async {
    await _supabase.from('user_devices').delete().eq('fcm_token', token);
  }
}
