abstract class NotificationRepository {
  Future<void> saveDeviceToken(String token, String userId);
  Future<void> deleteDeviceToken(String token);
}
