# Notification Enhancements: Click Navigation & Custom Reminder Time

**ID:** PLAN_019 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-01 | **Update:** 2026-01-01

## 🎯 Tujuan
Meningkatkan UX notifikasi dengan:
1. Navigasi otomatis ke halaman Todo Schedule saat notifikasi di-click
2. Memberikan opsi kepada user untuk mengatur waktu reminder (X menit sebelum)

## 🛠️ Strategi Implementasi

### Phase 1: Notification Click Navigation
1. [ ] Handle `onDidReceiveNotificationResponse` di `main.dart`
2. [ ] Parse `payload` untuk mendapatkan `todo_id`
3. [ ] Gunakan `go_router` untuk navigate ke `/schedule` atau `/todo/{id}`
4. [ ] Handle kasus app terminated (via `getInitialMessage`)

### Phase 2: Custom Reminder Time Setting
1. [ ] Tambahkan field `reminder_minutes` di `TodoModel` dan database
2. [ ] Update UI `TodoEditSheet` dengan dropdown/selector:
   - 5 menit sebelum
   - 10 menit sebelum
   - 15 menit sebelum
   - 30 menit sebelum
   - 1 jam sebelum
3. [ ] Update SQL function `send_upcoming_reminders` untuk menggunakan `reminder_minutes` per todo
4. [ ] Update body notifikasi untuk reflect reminder time

### Phase 3: Testing & Polish
1. [ ] Test click navigation dari berbagai state (foreground, background, terminated)
2. [ ] Test various reminder times
3. [ ] Update dokumentasi

## ✅ Kriteria Sukses
- Click notifikasi → app langsung ke halaman schedule/todo
- User bisa pilih waktu reminder per todo
- Notifikasi body sesuai dengan waktu reminder yang dipilih

## 🔗 Terkait
- Topic: [07_push_notifications.md](../Topic/TOPIC_001_ripple_mvp/07_push_notifications.md)
- Plan: [PLAN_018](PLAN_018_todo_notification_integration.md), [PLAN_017](PLAN_017_notification_optimization.md)
- Find: [FIND_007](../Find/FIND_007_notification_delivery_failure.md) (Resolved)
