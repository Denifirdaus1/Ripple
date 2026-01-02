# FCM Notification System Optimization & Security Hardening

**ID:** PLAN_017 | **Status:** 📋 Backlog | **Prioritas:** 🟢 High
**Dibuat:** 2026-01-01 | **Update:** 2026-01-01

## 🎯 Tujuan
Mengoptimalkan sistem notifikasi agar "bulletproof" (tidak mudah gagal), efisien dalam penggunaan sumber daya, dan mematuhi standar keamanan Supabase (fix `search_path` warning).

## 🛠️ Strategi Implementasi

### Phase 1: Security & Database Hardening
1. [ ] **Fix Search Path:** Tambahkan `SET search_path = ''` pada fungsi `send_upcoming_reminders` untuk menghindari serangan shadowing.
2. [ ] **Optimasi Query:** Ubah filter `BETWEEN NOW() AND NOW() + INTERVAL '5 minutes'` menjadi window range yang lebih fleksibel untuk menangani variansi waktu eksekusi cron.
3. [ ] **Timestamp Auto-update:** Pastikan `last_used_at` di `user_devices` diperbarui secara otomatis saat ada aktivitas dari perangkat tersebut.

### Phase 2: Edge Function Refinement
1. [ ] **Enhanced Error Handling:** Tangani pesan error spesifik dari FCM v1 API (`UNREGISTERED`, `INVALID_ARGUMENT`).
2. [ ] **Token Lifecycle:** Jika token tidak valid, langsung nonaktifkan (`is_active = false`) di database dari dalam Edge Function.

### Phase 3: Verification
1. [ ] Verifikasi status kesehatan logs di Supabase Dashboard.
2. [ ] Pastikan tidak ada lagi warning keamanan di Postgres Linter.

## ✅ Kriteria Sukses
- Warning `search_path` hilang.
- Notifikasi terkirim tepat waktu secara konsisten.
- Token yang sudah tidak valid otomatis dinonaktifkan.

## 🔗 Terkait
Topic: [07_push_notifications.md](../Topic/TOPIC_001_ripple_mvp/07_push_notifications.md)
Find: [FAILURE_002](../Log/failures.md)
