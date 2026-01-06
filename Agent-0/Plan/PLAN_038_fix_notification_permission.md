# PLAN_038: Fix Notification Permission Request

**ID:** PLAN_038 | **Status:** ✅ Completed | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-06 | **Selesai:** 2026-01-06 | **Finding:** [FIND_010](../Find/FIND_010_notification_permission_not_requested.md)

## 🎯 Objective

Memperbaiki sistem request izin notifikasi agar berfungsi di semua versi Android, terutama Android 13+ yang memerlukan runtime permission `POST_NOTIFICATIONS`.

## ⚠️ Constraint

> [!CAUTION]
> Implementasi ini **TIDAK BOLEH** mengganggu fitur yang sudah berjalan:
> - FCM token sync yang sudah ada
> - Notification listener (onMessage, onMessageOpenedApp)
> - iOS compatibility (tetap menggunakan FirebaseMessaging)

---

## 📋 Proposed Changes

### Phase 1: Add Dependency

#### [MODIFY] [pubspec.yaml](file:///c:/Project/ripple/pubspec.yaml)

Tambah `permission_handler` package:
```yaml
# Runtime Permissions (Android 13+)
permission_handler: ^12.0.0+1
```

---

### Phase 2: Create Platform-Aware Permission Helper

#### [NEW] [notification_permission_helper.dart](file:///c:/Project/ripple/lib/core/services/notification_permission_helper.dart)

Helper class untuk handle permission request cross-platform:

```dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionHelper {
  /// Request notification permission with platform-specific handling.
  /// Returns true if permission granted, false otherwise.
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      return await _requestAndroidPermission();
    } else {
      // iOS: Use FirebaseMessaging (works correctly)
      return await _requestIosPermission();
    }
  }

  static Future<bool> _requestAndroidPermission() async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // User needs to enable from settings
      return false;
    }
    
    return false;
  }

  static Future<bool> _requestIosPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Check if permission is permanently denied (requires settings redirect)
  static Future<bool> isPermanentlyDenied() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isPermanentlyDenied;
    }
    return false;
  }

  /// Open app settings for user to manually enable notifications
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
```

---

### Phase 3: Update NotificationService

#### [MODIFY] [notification_service.dart](file:///c:/Project/ripple/lib/core/services/notification_service.dart)

Update `initialize()` method untuk menggunakan helper baru:

**Before (line 44-50):**
```dart
var status = await getAuthorizationStatus();

if (status == AuthorizationStatus.notDetermined) {
  final settings = await requestPermission();
  status = settings.authorizationStatus;
}
```

**After:**
```dart
// Use platform-aware permission helper
final hasPermission = await NotificationPermissionHelper.requestPermission();

if (!hasPermission) {
  if (kDebugMode) {
    debugPrint('Notification permission denied');
  }
  return; // Exit early, don't setup listeners
}
```

---

### Phase 4: Configure Android Build

#### [MODIFY] [build.gradle.kts](file:///c:/Project/ripple/android/app/build.gradle.kts)

Ensure `compileSdkVersion` is at least 33:
```kotlin
compileSdk = 35 // or flutter.compileSdkVersion if already >= 33
```

---

## ✅ Verification Plan

### 1. Static Analysis
```powershell
cd c:\Project\ripple
flutter analyze
```
**Expected:** No new errors

### 2. Existing Tests
```powershell
cd c:\Project\ripple
flutter test
```
**Expected:** All existing tests pass (auth_bloc_test, todos_overview_bloc_test)

### 3. Manual Testing (Requires User)

> [!IMPORTANT]
> Untuk verifikasi penuh, user perlu melakukan fresh install di device Android 13+.

**Test Steps:**
1. Uninstall Ripple dari device
2. Install fresh via `flutter run`
3. Login ke aplikasi
4. **Expected:** Dialog izin notifikasi muncul
5. Grant permission → FCM token harus tersimpan di Supabase `user_devices` table
6. Deny permission → App tetap berfungsi, hanya reminder yang tidak akan terkirim

---

## 🔗 Terkait

- **Finding:** [FIND_010](../Find/FIND_010_notification_permission_not_requested.md)
- **Topic:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp.md) - Push Notifications
