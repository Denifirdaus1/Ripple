import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/promo_banner.dart';

/// Service for managing promotional banners
///
/// Handles fetching active banners from Supabase and tracking
/// which banners have been seen today to avoid repeated display.
class BannerService {
  static final BannerService instance = BannerService._();
  BannerService._();

  final SupabaseClient _client = Supabase.instance.client;
  static const String _seenBannersKey = 'seen_banners_';

  /// Get the active banner to display, if any.
  /// Returns null if no banner should be shown (either none active or already seen today).
  Future<PromoBanner?> getActiveBanner() async {
    try {
      // Fetch active banners ordered by priority (highest first)
      final response = await _client
          .from('promotional_banners')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: false)
          .limit(10);

      if (response.isEmpty) {
        debugPrint('[BannerService] No active banners found');
        return null;
      }

      final banners = (response as List)
          .map((json) => PromoBanner.fromJson(json))
          .where((banner) => banner.isValidForDisplay)
          .toList();

      if (banners.isEmpty) {
        debugPrint('[BannerService] No valid banners for display');
        return null;
      }

      // Check which banners haven't been seen today
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();

      for (final banner in banners) {
        final seenKey = '$_seenBannersKey${banner.id}_$today';
        final hasSeenToday = prefs.getBool(seenKey) ?? false;

        if (!hasSeenToday) {
          debugPrint('[BannerService] Returning banner: ${banner.title}');
          return banner;
        }
      }

      debugPrint('[BannerService] All banners already seen today');
      return null;
    } catch (e) {
      debugPrint('[BannerService] Error fetching banners: $e');
      return null;
    }
  }

  /// Mark a banner as seen today
  Future<void> markBannerSeen(String bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      final seenKey = '$_seenBannersKey${bannerId}_$today';

      await prefs.setBool(seenKey, true);
      debugPrint('[BannerService] Marked banner $bannerId as seen');
    } catch (e) {
      debugPrint('[BannerService] Error marking banner as seen: $e');
    }
  }

  /// Get today's date as a key string (YYYY-MM-DD)
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Clear all seen banner records (for testing/debugging)
  Future<void> clearSeenBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
      (key) => key.startsWith(_seenBannersKey),
    );
    for (final key in keys) {
      await prefs.remove(key);
    }
    debugPrint('[BannerService] Cleared all seen banner records');
  }
}
