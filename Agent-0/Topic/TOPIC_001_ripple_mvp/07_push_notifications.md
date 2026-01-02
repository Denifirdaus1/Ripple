# Push Notifications (FCM) - Client Setup

**Parent:** [← Kembali ke Main](_main.md)
**Status:** ✅ Done
**Updated:** 2026-01-01

> [!NOTE]
> Topic ini hanya berisi **client-side setup** (Flutter & Firebase Console).
> Untuk **backend** (Edge Functions, Cron Jobs, Database), lihat: [06_database_schema.md](06_database_schema.md)

---

## 📊 Implementation Progress

| Component | Status | Notes |
|-----------|--------|-------|
| Firebase Project | ✅ Done | Project ID: `ripple-66854` |
| Android App Registration | ✅ Done | Package: `com.ripple.ripple` |
| `google-services.json` | ✅ Done | Placed in `android/app/` |
| Gradle Setup | ✅ Done | Google Services plugin added |
| Flutter Packages | ✅ Done | `firebase_core`, `firebase_messaging` |
| Firebase Init in `main.dart` | ✅ Done | Background handler configured |
| Service Account Key | ✅ Done | Downloaded from Firebase Console |
| iOS Setup | ⏸️ Skipped | Not needed for MVP (Android only) |
| NotificationService | ✅ Created | `lib/core/services/notification_service.dart` |

---

## Overview

Push notifications menggunakan **Firebase Cloud Messaging (FCM)** untuk mengirim reminder ke device user saat jadwal todo tiba.

### Architecture Flow

```
┌─────────────┐     ┌───────────────────┐     ┌────────────────┐
│ Flutter App │────▶│ Firebase Console  │     │ Supabase       │
│ (Client)    │     │ google-services   │     │ user_devices   │
└─────────────┘     └───────────────────┘     └────────────────┘
                                                      │
                                                      ▼
┌─────────────┐     ┌───────────────────┐     ┌────────────────┐
│ User Device │◀────│ FCM Cloud         │◀────│ Edge Function  │
│ (Receive)   │     │ (Push Delivery)   │     │ (Send via API) │
└─────────────┘     └───────────────────┘     └────────────────┘
```

---

## Firebase Console Setup ✅

| Step | Action | Status |
|------|--------|--------|
| 1 | Create Firebase Project | ✅ Done (`ripple-66854`) |
| 2 | Add Android App | ✅ Done (`com.ripple.ripple`) |
| 3 | Download `google-services.json` | ✅ Done |
| 4 | Enable Cloud Messaging | ✅ Done |
| 5 | Generate Service Account Key | ✅ Done (untuk Edge Function) |

**Firebase Project Info:**
- **Project ID:** `ripple-66854`
- **Project Number:** `1072699555742`
- **Storage Bucket:** `ripple-66854.firebasestorage.app`

---

## Android Configuration ✅

### 1. Root-level `android/build.gradle.kts`

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}
```

### 2. App-level `android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // ← Added
    id("dev.flutter.flutter-gradle-plugin")
}
```

### 3. Android Permission (Android 13+)

File: `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Flutter Setup ✅

### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  firebase_core: ^3.13.0
  firebase_messaging: ^15.2.5
```

### Firebase Initialization (`lib/main.dart`)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // ... rest of initialization
}
```

---

## NotificationService (`lib/core/services/notification_service.dart`)

Service class yang sudah dibuat untuk mengelola FCM:

### Available Methods

| Method | Purpose |
|--------|---------|
| `requestPermission()` | Request notification permission dari user |
| `registerFcmToken()` | Get FCM token & save ke Supabase |
| `unregisterFcmToken()` | Remove token saat logout |
| `setupForegroundHandler()` | Handle notifikasi saat app di foreground |
| `setupNotificationTapHandler()` | Handle tap notification |
| `initialize()` | One-call setup semua handlers |

### Usage Example

```dart
// After user login
class HomePage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    // Request permission
    final granted = await NotificationService.requestPermission();
    
    if (granted) {
      // Initialize FCM
      await NotificationService.initialize(
        onForegroundMessage: (title, body, data) {
          // Show in-app notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title: $body')),
          );
        },
        onNotificationTap: (data) {
          // Navigate based on action
          final todoId = data['todo_id'];
          if (todoId != null) {
            Navigator.pushNamed(context, '/focus-mode', arguments: todoId);
          }
        },
      );
    }
  }
}

// On logout
await NotificationService.unregisterFcmToken();
```

---

## User Flow

### 1. Permission Request Flow

```
User logs in
    ↓
Show explanation dialog ("Get reminded before focus sessions!")
    ↓
User taps "Enable"
    ↓
NotificationService.requestPermission()
    ↓
OS shows permission dialog → User grants
    ↓
NotificationService.registerFcmToken()
    ↓
Token saved to Supabase user_devices table
```

### 2. Notification Receive Flow

```
Supabase cron job triggers Edge Function
    ↓
Edge Function calls FCM API with user's token
    ↓
FCM delivers to device
    ↓
If app foreground: setupForegroundHandler callback
If app background: System notification shown
If app terminated: System notification shown
    ↓
User taps notification
    ↓
setupNotificationTapHandler callback → Navigate to Focus Mode
```

---

## Notification Types

| Trigger | Title | Body | Data |
|---------|-------|------|------|
| Todo Reminder | ⏰ {title} | Starting in 5 minutes! | `{todo_id, action: 'open_focus_mode'}` |
| Todo Start | 🎯 Time to focus! | {title} | `{todo_id, action: 'open_focus_mode'}` |
| Milestone Due | 📅 Milestone due tomorrow | {title} | `{milestone_id, action: 'open_milestone'}` |

---

## Confirmed Decisions

- ✅ **FCM for MVP** - Not local notifications
- ✅ **Android only for MVP** - iOS skipped
- ✅ **Multi-device support** - Via `user_devices` table
- ✅ **5-minute advance reminder** - Notify before todo starts
- ✅ **Tap to open Focus Mode** - Direct navigation

---

## Related Docs

- **Backend (Database, Cron, Edge Functions):** [06_database_schema.md](06_database_schema.md)
- **Research:** [R_001 Push Notifications](../../Research/R_001_push_notifications.md)
- **Flutter Service:** `lib/core/services/notification_service.dart`
