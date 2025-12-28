# Research: Push Notification System untuk Ripple

**Created:** 2025-12-28
**Topic:** TOPIC_001 - Ripple MVP
**Status:** ✅ Complete

---

## Executive Summary

Untuk mengirim notifikasi dari Supabase cron job ke device user, kita memerlukan **Push Notification Service** sebagai perantara. Ada beberapa opsi dengan trade-off masing-masing.

### Recommended Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Supabase       │     │  Supabase Edge   │     │  FCM / OneSignal │     │  User       │
│  pg_cron        │────▶│  Function        │────▶│  Push Service    │────▶│  Device     │
│  (scheduled)    │     │  (HTTP trigger)  │     │  (delivery)      │     │  (receive)  │
└─────────────────┘     └──────────────────┘     └──────────────────┘     └─────────────┘
```

---

## Option Comparison

| Feature | Firebase FCM | OneSignal | Expo Push | Local Only |
|---------|-------------|-----------|-----------|------------|
| **Price** | Free (unlimited) | Free tier + paid | Free (with Expo) | Free |
| **Setup Complexity** | Medium | Low | Low (Expo only) | Low |
| **Reliability** | Very High (Google) | High | High | N/A |
| **iOS + Android** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Web Support** | ✅ Yes (VAPID) | ✅ Yes | ❌ No | ❌ No |
| **Server-Side Trigger** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| **Scheduled Local** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Works Offline** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Analytics** | Basic | Advanced | Basic | None |

---

## 🔥 Final Decision: FCM for MVP

> **User Decision (2025-12-28):** Use FCM Push Notifications for MVP, not local notifications.

### Alasan Memilih FCM untuk MVP

| Benefit | Explanation |
|---------|-------------|
| ✅ **Full-Featured** | Server-triggered, works when app closed |
| ✅ **Industry Standard** | Widely used, well documented |
| ✅ **Future-Ready** | Already set up for AI features later |
| ✅ **Multi-Device** | Sync across all user devices |
| ✅ **Free & Unlimited** | No cost for sending |
| ✅ **Reliable** | Google infrastructure |

### Implementation Complete

Semua komponen sudah ditambahkan ke schema dan topic:
- ✅ `user_devices` table untuk FCM tokens
- ✅ `notification_sent` field di todos table
- ✅ `send_upcoming_reminders()` cron function
- ✅ Edge Function template untuk FCM API
- ✅ Sub-topic `07_push_notifications.md`

---

## Architecture untuk Ripple

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           NOTIFICATION FLOW                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                    LOCAL NOTIFICATIONS                            │  │
│  │  (flutter_local_notifications)                                    │  │
│  │                                                                   │  │
│  │  User creates Todo → Schedule local notification → Device alarm  │  │
│  │                                                                   │  │
│  │  ✅ Works offline                                                 │  │
│  │  ✅ No server needed                                              │  │
│  │  ✅ Precise timing                                                │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│                              OR (if needed)                             │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                    PUSH NOTIFICATIONS (FCM)                       │  │
│  │  (firebase_messaging)                                             │  │
│  │                                                                   │  │
│  │  pg_cron → Edge Function → FCM API → Device                      │  │
│  │                                                                   │  │
│  │  ✅ Server-triggered                                              │  │
│  │  ✅ Works when app closed                                         │  │
│  │  ⚠️  Requires internet                                            │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Setup Requirements (Outside Code)

### A. Local Notifications (flutter_local_notifications)

**Android:**
| Item | Location | Notes |
|------|----------|-------|
| Notification Permission | `AndroidManifest.xml` | `POST_NOTIFICATIONS` (Android 13+) |
| Exact Alarm Permission | `AndroidManifest.xml` | `SCHEDULE_EXACT_ALARM` |
| Boot Receiver | `AndroidManifest.xml` | Untuk reschedule setelah reboot |
| Notification Channel | Code | Buat channel di initialization |

**iOS:**
| Item | Location | Notes |
|------|----------|-------|
| Push Notification Entitlement | Xcode | Enable in Signing & Capabilities |
| Background Modes | `Info.plist` | `remote-notification`, `fetch` |
| Permission Request | Code | Request alert, badge, sound |

---

### B. Firebase Cloud Messaging (jika diperlukan)

**Firebase Console Setup:**

| Step | Action | Notes |
|------|--------|-------|
| 1 | Create Firebase Project | console.firebase.google.com |
| 2 | Add Android App | Download `google-services.json` |
| 3 | Add iOS App | Download `GoogleService-Info.plist` |
| 4 | Enable Cloud Messaging | Project Settings > Cloud Messaging |
| 5 | Generate Service Account Key | For server-side sending |
| 6 | Get VAPID Key (Web) | Cloud Messaging > Web configuration |

**Flutter Setup:**

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  firebase_messaging: ^latest
```

**Supabase Edge Function (FCM):**

```typescript
// supabase/functions/send-notification/index.ts
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../service-account.json' with { type: 'json' }

const getAccessToken = async (): Promise<string> => {
  const jwtClient = new JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  })
  const tokens = await jwtClient.authorize()
  return tokens.access_token!
}

Deno.serve(async (req) => {
  const { token, title, body, data } = await req.json()
  
  const accessToken = await getAccessToken()
  
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          android: {
            priority: 'high',
            notification: { sound: 'default' }
          },
          apns: {
            payload: {
              aps: { sound: 'default' }
            }
          }
        },
      }),
    }
  )
  
  return new Response(JSON.stringify(await res.json()))
})
```

**Database: Store FCM Tokens:**

```sql
-- Add fcm_token to profiles or create separate table
ALTER TABLE public.profiles ADD COLUMN fcm_token TEXT;

-- Or create dedicated table for multiple devices per user
CREATE TABLE public.user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_name TEXT,
  platform TEXT CHECK (platform IN ('android', 'ios', 'web')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, fcm_token)
);
```

---

## MVP Recommendation

### Phase 1: Local Notifications Only (MVP)

Untuk MVP, **gunakan Local Notifications saja**:

1. ✅ **Simpler setup** - No external service needed
2. ✅ **Works offline** - User bisa dapat notif tanpa internet
3. ✅ **More reliable** - No dependency on FCM/server
4. ✅ **No cost** - Zero external costs
5. ✅ **Privacy** - Notification data stays on device

**Flow MVP:**
```
User creates scheduled todo
        ↓
App schedules local notification (flutter_local_notifications)
        ↓
At scheduled time, device shows notification
        ↓
User taps → Opens Focus Mode
```

### Phase 2: Add FCM (Post-MVP)

Tambahkan FCM saat butuh:
- Server-triggered notifications
- Cross-device sync alerts
- AI-generated reminders
- Team/collaboration features

---

## Flutter Implementation: Local Notifications

```dart
// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }
  
  static void _onNotificationTap(NotificationResponse response) {
    // Navigate to Focus Mode with todo ID from payload
    final todoId = response.payload;
    // NavigationService.goToFocusMode(todoId);
  }
  
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription: 'Notifications for scheduled todos',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
```

---

## Required Packages

```yaml
# pubspec.yaml
dependencies:
  # Local Notifications (MVP)
  flutter_local_notifications: ^17.2.0
  timezone: ^0.9.2
  flutter_timezone: ^1.0.8
  permission_handler: ^11.3.0
  
  # FCM (Post-MVP)
  # firebase_core: ^2.27.0
  # firebase_messaging: ^14.7.0
```

---

## Kesimpulan

| Phase | Approach | Service | Cost |
|-------|----------|---------|------|
| MVP | Local Notifications | flutter_local_notifications | Free |
| Post-MVP | + Push Notifications | Firebase FCM | Free |

**Untuk MVP Ripple, Local Notifications sudah cukup!** 

FCM bisa ditambahkan nanti saat butuh server-triggered notifications atau fitur collaboration.

---

## References

1. Supabase Push Notifications Guide - https://supabase.com/docs/guides/functions/examples/push-notifications
2. Firebase FCM Flutter Setup - https://firebase.google.com/codelabs/firebase-fcm-flutter
3. flutter_local_notifications Package - https://pub.dev/packages/flutter_local_notifications
4. Firebase vs OneSignal Comparison - https://ably.com/compare/firebase-vs-onesignal
