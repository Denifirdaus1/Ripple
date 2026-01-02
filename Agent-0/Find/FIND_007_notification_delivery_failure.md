# Notification Timing & Delivery Failure

**ID:** FIND_007 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-01 | **Update:** 2026-01-01

## 📝 Deskripsi Masalah
User membuat Todo "tes notifikasi" pada 09:12 WIB dengan `start_time` 09:14 WIB (selisih 2 menit). Notifikasi tidak terkirim meskipun sistem cron berjalan dengan baik.

**Log Error:**
1. **Edge Function Log:** `POST | 404 | send-notification` - Fungsi menemukan todo tapi mengembalikan 404 karena tidak ada perangkat yang cocok.
2. **Flutter Log:** `RealtimeSubscribeException: InvalidJWTToken: Token has expired 43637 seconds ago` - Token Supabase Realtime sudah tidak valid.

## 🕵️ Analisis & Root Cause

### Issue 1: Timing Window Mismatch
- **Current Logic (in `send_upcoming_reminders`):**
  ```sql
  t.start_time BETWEEN 
    (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' + INTERVAL '4 minutes') 
    AND 
    (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' + INTERVAL '6 minutes')
  ```
- **Problem:** Cron mencari todo yang dimulai dalam **4-6 menit ke depan**. Jika user membuat todo yang dimulai dalam 3 menit atau kurang, todo tersebut tidak akan pernah masuk window.
- **Timeline:**
  - 09:08 (Cron): Window = 09:12-09:14.
  - 09:09 (Cron): Window = 09:13-09:15.
  - 09:12 (User creates todo, start 09:14): **No matching cron cycle**. At 09:10, window was 09:14-09:16 (match!), but todo didn't exist yet.

### Issue 2: 404 Response from Edge Function
- The `send-notification` function returns 404 when `devices.length === 0`.
- This could happen if the user_id passed from the database function doesn't match any active device token.
- Need to verify that `user_id` in `todos` matches the one in `user_devices`.

### Issue 3: JWT Token Expiration (Realtime)
- **Error:** `InvalidJWTToken: Token has expired 43637 seconds ago` (~12 hours).
- **Impact:** Realtime streams (Goals, Notes, Todos) fail silently.
- **Cause:** Session token not refreshing correctly when app is in background for a long time.

## 💡 Ide Solusi

### Solusi 1: Immediate Notification Mode
Untuk todo yang dijadwalkan kurang dari 5 menit dari waktu pembuatan, langsung kirim notifikasi saat todo disimpan (via client-side call atau database trigger).

### Solusi 2: Expand Timing Window
Ubah window dari `4-6 minutes` menjadi `0-6 minutes` agar mencakup semua kemungkinan:
```sql
t.start_time BETWEEN NOW() AND (NOW() + INTERVAL '6 minutes')
```
Kombinasi dengan flag `notification_sent` akan mencegah pengiriman duplikat.

### Solusi 3: Session Refresh on App Resume
Panggil `supabase.auth.refreshSession()` saat app kembali ke foreground untuk memperbaiki masalah JWT token.

## 🔗 Terkait
- Topic: [07_push_notifications.md](../Topic/TOPIC_001_ripple_mvp/07_push_notifications.md)
- Plan: [PLAN_017](../Plan/PLAN_017_notification_optimization.md), [PLAN_018](../Plan/PLAN_018_todo_notification_integration.md)
