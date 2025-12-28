/// Auth local data source for caching user data
/// TODO: Implement local caching with shared_preferences or hive
abstract class AuthLocalDataSource {
  /// Cache user data locally
  Future<void> cacheUser(Map<String, dynamic> userData);

  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUser();

  /// Clear cached user data
  Future<void> clearCache();
}

/// Implementation placeholder for local data source
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheUser(Map<String, dynamic> userData) async {
    // TODO: Implement with shared_preferences
    throw UnimplementedError('Local caching not implemented yet');
  }

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    // TODO: Implement with shared_preferences
    throw UnimplementedError('Local caching not implemented yet');
  }

  @override
  Future<void> clearCache() async {
    // TODO: Implement with shared_preferences
    throw UnimplementedError('Local caching not implemented yet');
  }
}
