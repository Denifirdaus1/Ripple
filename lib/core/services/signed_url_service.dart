import 'package:supabase_flutter/supabase_flutter.dart';

/// A cached URL entry with expiration time
class _CachedUrl {
  final String url;
  final DateTime expiresAt;

  _CachedUrl(this.url, this.expiresAt);
}

/// Service for generating and caching signed URLs for private storage buckets.
///
/// This service handles:
/// - Generating signed URLs for private bucket files
/// - Caching URLs to minimize API calls
/// - Automatic cache invalidation before expiry
class SignedUrlService {
  final SupabaseClient _client;
  final Map<String, _CachedUrl> _cache = {};

  /// How long the signed URL remains valid
  static const Duration _urlExpiryDuration = Duration(hours: 1);

  /// Buffer time before expiry to regenerate URL
  static const Duration _cacheBuffer = Duration(minutes: 5);

  SignedUrlService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Generates a signed URL for a private storage file.
  ///
  /// [storagePath] should be in format: "bucket-name/path/to/file"
  /// Example: "note-images/user-id/filename.jpg"
  ///
  /// Returns a signed URL that expires after [_urlExpiryDuration].
  Future<String> getSignedUrl(String storagePath) async {
    // Check cache first
    if (_cache.containsKey(storagePath)) {
      final cached = _cache[storagePath]!;
      // Return cached URL if it's still valid (with buffer time)
      if (cached.expiresAt.isAfter(DateTime.now().add(_cacheBuffer))) {
        return cached.url;
      }
    }

    // Parse storage path to extract bucket and file path
    final parts = storagePath.split('/');
    if (parts.length < 2) {
      throw ArgumentError('Invalid storage path format: $storagePath');
    }

    final bucket = parts.first;
    final path = parts.sublist(1).join('/');

    // Generate new signed URL
    final signedUrl = await _client.storage
        .from(bucket)
        .createSignedUrl(path, _urlExpiryDuration.inSeconds);

    // Cache the URL
    _cache[storagePath] = _CachedUrl(
      signedUrl,
      DateTime.now().add(_urlExpiryDuration),
    );

    return signedUrl;
  }

  /// Checks if a URL is a storage path (needs signed URL) or already a full URL.
  ///
  /// Storage paths start with bucket names like "note-images/"
  /// Full URLs start with "http"
  bool isStoragePath(String urlOrPath) {
    if (urlOrPath.startsWith('http')) return false;
    return urlOrPath.startsWith('note-images/') ||
        urlOrPath.startsWith('milestone-banners/');
  }

  /// Resolves a URL or storage path to a usable URL.
  ///
  /// - If [urlOrPath] is already a full URL, returns it as-is (backward compatibility)
  /// - If [urlOrPath] is a storage path, generates a signed URL
  Future<String> resolveUrl(String urlOrPath) async {
    if (!isStoragePath(urlOrPath)) {
      return urlOrPath; // Already a URL, return as-is
    }
    return getSignedUrl(urlOrPath);
  }

  /// Clears the URL cache. Useful when user logs out or for testing.
  void clearCache() {
    _cache.clear();
  }
}
