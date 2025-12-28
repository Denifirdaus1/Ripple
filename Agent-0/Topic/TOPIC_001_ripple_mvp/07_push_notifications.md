# Fitur Push Notifications (FCM)

**Parent:** [← Kembali ke Main](_main.md)
**Status:** ✅ Confirmed for MVP

---

## Overview

Push notifications menggunakan **Firebase Cloud Messaging (FCM)** untuk mengirim reminder ke device user saat jadwal todo tiba.

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Supabase       │     │  Supabase Edge   │     │  Firebase FCM    │     │  User       │
│  pg_cron/       │────▶│  Function        │────▶│  (delivery)      │────▶│  Device     │
│  DB Webhook     │     │  (HTTP trigger)  │     │                  │     │  (receive)  │
└─────────────────┘     └──────────────────┘     └──────────────────┘     └─────────────┘
```

---

## User Flow

### 1. Registration Flow
```
User signs in with Google
    ↓
App requests notification permission
    ↓
FirebaseMessaging.instance.getToken() → FCM Token
    ↓
Send token to Supabase → stored in user_devices table
```

### 2. Notification Trigger Flow
```
Option A: Database Webhook (Real-time)
─────────────────────────────────────
Todo created with start_time
    ↓
pg_cron checks upcoming todos every minute
    ↓
Triggers Edge Function via pg_net
    ↓
Edge Function calls FCM API
    ↓
User receives push notification

Option B: Scheduled Check (Batch)
─────────────────────────────────
pg_cron runs every minute: "0/1 * * * *"
    ↓
Query: SELECT todos WHERE start_time BETWEEN NOW() AND NOW() + 5 minutes
    ↓
For each todo, send notification via Edge Function
```

### 3. Notification Tap Flow
```
User receives notification
    ↓
User taps notification
    ↓
App opens (foreground/background/terminated)
    ↓
Navigate to Focus Mode for that todo
```

---

## Notification Types

| Trigger | Title | Body | Action |
|---------|-------|------|--------|
| Todo Reminder | "⏰ {todo.title}" | "Starting in 5 minutes" | Open Focus Mode |
| Todo Start | "🎯 Time to focus!" | "{todo.title}" | Open Focus Mode |
| Milestone Due | "📅 Milestone due tomorrow" | "{milestone.title}" | Open Milestone |
| Focus Complete | "🎉 Great job!" | "Session completed" | Mark todo done |

---

## Technical Specs

### FCM Token Management

**Token Refresh:**
- FCM tokens can expire/change
- Listen to `FirebaseMessaging.instance.onTokenRefresh`
- Update token in database when changed

**Multi-Device Support:**
- User dapat login di multiple devices
- Store multiple tokens per user di `user_devices` table
- Send notification ke semua devices user

### Edge Function: send-notification

```typescript
// supabase/functions/send-notification/index.ts

import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../service-account.json' with { type: 'json' }

interface NotificationPayload {
  user_id: string
  title: string
  body: string
  data?: Record<string, string>
}

const getAccessToken = async (): Promise<string> => {
  const jwtClient = new JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  })
  const tokens = await jwtClient.authorize()
  return tokens.access_token!
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  const payload: NotificationPayload = await req.json()
  
  // Get all FCM tokens for this user
  const { data: devices } = await supabase
    .from('user_devices')
    .select('fcm_token')
    .eq('user_id', payload.user_id)
  
  if (!devices || devices.length === 0) {
    return new Response(JSON.stringify({ error: 'No devices found' }), { status: 404 })
  }
  
  const accessToken = await getAccessToken()
  
  // Send to all user devices
  const results = await Promise.all(
    devices.map(device => 
      fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token: device.fcm_token,
              notification: {
                title: payload.title,
                body: payload.body,
              },
              data: payload.data || {},
              android: {
                priority: 'high',
                notification: {
                  sound: 'default',
                  click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                    badge: 1,
                  },
                },
              },
            },
          }),
        }
      ).then(res => res.json())
    )
  )
  
  return new Response(JSON.stringify({ results }))
})
```

### Cron Job: Check Upcoming Todos

```sql
-- Function to send reminder for upcoming todos
CREATE OR REPLACE FUNCTION public.send_upcoming_reminders()
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    todo_record RECORD;
BEGIN
    -- Find todos starting in 5 minutes that haven't been notified
    FOR todo_record IN 
        SELECT t.id, t.user_id, t.title, t.start_time
        FROM public.todos t
        WHERE t.is_scheduled = TRUE
        AND t.is_completed = FALSE
        AND t.notification_sent = FALSE
        AND t.start_time BETWEEN NOW() AND NOW() + INTERVAL '5 minutes'
    LOOP
        -- Call Edge Function to send notification
        PERFORM net.http_post(
            url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'project_url') 
                   || '/functions/v1/send-notification',
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || 
                    (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'service_role_key')
            ),
            body := jsonb_build_object(
                'user_id', todo_record.user_id,
                'title', '⏰ ' || todo_record.title,
                'body', 'Starting in 5 minutes',
                'data', jsonb_build_object('todo_id', todo_record.id::TEXT, 'action', 'focus_mode')
            )
        );
        
        -- Mark as notified
        UPDATE public.todos 
        SET notification_sent = TRUE 
        WHERE id = todo_record.id;
    END LOOP;
END;
$$;

-- Schedule every minute
SELECT cron.schedule(
    'send-upcoming-reminders',
    '* * * * *',  -- Every minute
    'SELECT public.send_upcoming_reminders()'
);
```

---

## Firebase Console Setup

| Step | Action | Notes |
|------|--------|-------|
| 1 | Create Firebase Project | [console.firebase.google.com](https://console.firebase.google.com) |
| 2 | Add Android App | Package: `com.ripple.app` |
| 3 | Download `google-services.json` | Place in `android/app/` |
| 4 | Add iOS App | Bundle ID: `com.ripple.app` |
| 5 | Download `GoogleService-Info.plist` | Place in `ios/Runner/` |
| 6 | Enable Cloud Messaging | Project Settings > Cloud Messaging |
| 7 | Generate Service Account Key | For Edge Function (FCM v1 API) |

---

## Flutter Packages

```yaml
dependencies:
  firebase_core: ^2.27.0
  firebase_messaging: ^14.7.0
```

---

## Confirmed Decisions

- ✅ **FCM for MVP** - Not local notifications
- ✅ **Multi-device support** - User can receive on all logged-in devices
- ✅ **5-minute advance reminder** - Notify before todo starts
- ✅ **Tap to open Focus Mode** - Direct navigation from notification
- ✅ **pg_cron + Edge Function** - Server-side notification trigger
