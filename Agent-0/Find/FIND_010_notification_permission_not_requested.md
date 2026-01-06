# Izin Notifikasi Tidak Diminta Saat Fresh Install

**ID:** FIND_010 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-06 | **Resolved:** 2026-01-06 | **Plan:** [PLAN_038](../Plan/PLAN_038_fix_notification_permission.md)

## 📝 Deskripsi Masalah

Saat user pertama kali install Ripple dan login, **dialog izin notifikasi tidak muncul**. Akibatnya:
1. FCM token tidak tersimpan ke database
2. Scheduled notification tidak akan pernah terkirim
3. System notification permission tetap `denied` secara default di Android 13+

### Dampak Sistem
- **Critical**: Tanpa izin notifikasi, seluruh fitur reminder Todo tidak berfungsi
- User tidak awareness bahwa notifikasi diblokir
- Edge function `send-notification` akan selalu gagal karena tidak ada FCM token

## 🕵️ Analisis & Root Cause

### Investigasi Code
Lokasi: `lib/core/services/notification_service.dart`

```dart
// Lines 44-50 - Current Implementation
var status = await getAuthorizationStatus();

if (status == AuthorizationStatus.notDetermined) {
  final settings = await requestPermission();
  status = settings.authorizationStatus;
}
```

### Root Cause: `FirebaseMessaging.requestPermission()` Behavior on Android

Berdasarkan deep research via **Context7 (FlutterFire docs)** dan **Exa MCP**:

| Platform | `getNotificationSettings()` Default | `requestPermission()` Behavior |
|----------|-------------------------------------|-------------------------------|
| iOS | `notDetermined` (correct) | Shows native dialog ✅ |
| Android <13 | `authorized` (implicit) | No-op, always granted ⚠️ |
| **Android 13+** | `authorized` (WRONG!) | **No-op, DOES NOT request runtime permission** ❌ |

**Masalah Kritis:**
> On Android 13+ (API 33), `FirebaseMessaging.instance.getNotificationSettings()` returns `authorized` even when the runtime `POST_NOTIFICATIONS` permission has NOT been granted!

Ini adalah **known behavior** dari `firebase_messaging` plugin:
- Plugin menganggap permission sudah "authorized" karena `POST_NOTIFICATIONS` ada di manifest
- Tapi actual runtime permission dialog TIDAK pernah ditampilkan
- Akibatnya `_firebaseMessaging.getToken()` bisa return token, tapi notifikasi tetap di-block oleh OS

### Evidence dari FlutterFire Changelog
> **firebase_messaging v13.0.0**: includes `Manifest.permission.POST_NOTIFICATIONS` in AndroidManifest.xml which requires updating `android/app/build.gradle` to target API level 33.

Manifest permission sudah ada (verified di `AndroidManifest.xml` line 3), tapi **runtime permission request belum diimplementasikan**.

## 💡 Solusi yang Direkomendasikan

### Opsi A: Gunakan `permission_handler` Package (Recommended ✅)

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestNotificationPermission() async {
  // Check if Android 13+
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    
    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Guide user to settings
      await openAppSettings();
      return false;
    }
    
    return status.isGranted;
  }
  
  // iOS: Use FirebaseMessaging (works correctly)
  final settings = await FirebaseMessaging.instance.requestPermission();
  return settings.authorizationStatus == AuthorizationStatus.authorized;
}
```

**Pros:**
- Cross-platform compatible
- Handles `permanentlyDenied` state properly
- Well-maintained package (87.2 benchmark score)

**Cons:**
- Additional dependency

### Opsi B: Native Android Kotlin Implementation

Modifikasi `MainActivity.kt` untuk request permission secara native. Lebih kompleks tapi tanpa dependency tambahan.

## 🔧 Implementation Checklist

- [ ] Add `permission_handler` to `pubspec.yaml`
- [ ] Update `NotificationService.initialize()` logic
- [ ] Add platform check (`Platform.isAndroid && SDK >= 33`)
- [ ] Handle `permanentlyDenied` → redirect to app settings
- [ ] Add user-friendly dialog before requesting permission
- [ ] Test on Android 13+ device (fresh install)
- [ ] Test on Android 12 and below (regression)

## 📚 Research References

| Source | URL | Key Insight |
|--------|-----|-------------|
| FlutterFire Docs | [receive.md](https://github.com/firebase/flutterfire/blob/main/docs/cloud-messaging/receive.md) | `requestPermission()` usage, iOS/macOS/web/Android 13+ |
| FlutterFire Discussion | [#9130](https://github.com/firebase/flutterfire/discussions/9130) | Android 13 support discussion |
| permission_handler | [README.md](https://github.com/baseflow/flutter-permission-handler) | Best practice for notification permission |
| Android Official | [Notification Runtime Permission](https://developer.android.com/develop/ui/views/notifications/notification-permission) | POST_NOTIFICATIONS requirement |

## 🔗 Terkait

- **Topic:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp.md) - Push Notifications
- **Finding:** [FIND_009](FIND_009_fcm_delivery_failure.md) - FCM Delivery Failure (related symptom)
