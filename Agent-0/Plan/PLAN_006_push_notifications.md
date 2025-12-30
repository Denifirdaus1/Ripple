# PLAN_006: Implement Push Notifications (FCM + Edge Functions)

**ID:** PLAN_006 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Terkait:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)
**Constraint:** Firebase Cloud Messaging, Supabase Edge Functions, pg_cron

---

# Goal Description
Implement a reliable Push Notification system to remind users of upcoming tasks and milestones.

The system consists of:
1.  **Client (Flutter)**: Handles permissions, retrieves FCM token, and displays notifications (Foreground/Background).
2.  **Database (Supabase)**: Stores device tokens in `user_devices` and tracks notification status in `todos`.
3.  **Scheduler (Edge Function)**: A server-side job that checks for due tasks and triggers FCM messages.

## User Review Required
> [!IMPORTANT]
> **Scheduling Strategy**:
> - We will use `pg_cron` to invoke a Supabase Edge Function (`process-notifications`) every **1 or 5 minutes**.
> - The Edge Function will:
>   1. Call Supabase RPC or Query to find `todos` where `due_date` is within next 10 mins AND `notification_sent` is false.
>   2. Fetch `fcm_token` from `user_devices` for the related user.
>   3. Call Firebase HTTP v1 API to send the message.
>   4. Update `todos` set `notification_sent = true`.

---

## Proposed Changes

### 1. Domain Layer
#### [NEW] [lib/features/notification/domain]
- `repositories/notification_repository.dart`: `saveDeviceToken(String token)`, `deleteDeviceToken()`.
- `usecases/sync_device_token.dart`: Called on App Start.

### 2. Data Layer
#### [NEW] [lib/features/notification/data]
- `models/user_device_model.dart`: Maps to `user_devices` schema.
- `repositories/notification_repository_impl.dart`: Upsert logic for `user_devices`.

#### [MODIFY] [lib/core/services/notification_service.dart](file:///c:/Project/ripple/lib/core/services/notification_service.dart)
- Integrate with `NotificationRepository` to sync token refresh.

### 3. Backend (Supabase Edge Functions)
#### [NEW] [supabase/functions/process-notifications/index.ts]
- Typescript function to handle the logic.
- Requires `FIREBASE_SERVICE_ACCOUNT` JSON in Supabase Vault/Secrets.

### 4. Database (SQL)
#### [NEW] [supabase/migrations/20251230_setup_cron.sql]
- Enable `pg_cron` extension.
- Create cron job schedule.
```sql
SELECT cron.schedule(
  'process-notifications-every-5min',
  '*/5 * * * *',
  $$
  select
    net.http_post(
      url:='https://<project-ref>.supabase.co/functions/v1/process-notifications',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer <service-key>"}'::jsonb
    ) as request_id;
  $$
);
```

---

## Verification Plan

### Automated Tests
- Unit test `SyncDeviceToken` usecase.

### Manual Verification
1.  **Token Sync**: Run app. Check `user_devices` table. Verify new row with correct FCM token.
2.  **Edge Function**:
    - Create a task due in 2 minutes.
    - Manually invoke Edge Function via curl (or wait for cron).
    - Check `todos` table: `notification_sent` should become `true`.
    - Check Mobile Device: Notification should appear.
3.  **Cleanup**: Logout. Check `user_devices`. Token should be removed or marked inactive.
