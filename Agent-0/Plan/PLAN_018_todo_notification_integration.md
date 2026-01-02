# Todo Notification Integration (PLAN_018)

**ID:** PLAN_018 | **Status:** 📋 Backlog | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-01 | **Update:** 2026-01-01

## 🎯 Tujuan
Mengintegrasikan Push Notification (FCM) ke dalam fitur Todo Schedule. User harus diminta izin notifikasi saat mencoba menjadwalkan tugas, dan sistem harus memastikan token FCM tersimpan di backend agar reminder dapat terkirim.

## 🛠️ Strategi Implementasi

### Phase 1: Service Refinement
1. [ ] **Refactor `NotificationService`**: 
   - Pisahkan `requestPermission()` dari `initialize()`.
   - Tambahkan method untuk mengecek status permission saat ini.
2. [ ] **Global Initialization**: Panggil initialization di level `MainShell` atau `SessionService` setelah login berhasil.

### Phase 2: UI Integration (TodoEditSheet)
1. [ ] **Permission Check on Toggle**: 
   - Saat switch "Schedule" di-ON-kan, panggil permission request jika belum diizinkan.
   - Gunakan `NotificationService` via Dependency Injection (`GetIt`).
2. [ ] **Feedback UI**: Tampilkan Snackbar jika user menolak permission agar mereka tahu fitur reminder tidak akan aktif.

### Phase 3: Verification
1. [ ] Pastikan token tersimpan di tabel `user_devices` saat permission diberikan.
2. [ ] Tes pembuatan Todo dengan jadwal dan cek log Edge Function.

## ✅ Kriteria Sukses
- Switch "Schedule" memicu request permission.
- Token FCM ter-sync otomatis ke Supabase.
- User menerima feedback jika permission ditolak.

## 🔗 Terkait
- Topic: [07_push_notifications.md](../Topic/TOPIC_001_ripple_mvp/07_push_notifications.md)
- Plan: [PLAN_017_notification_optimization.md](PLAN_017_notification_optimization.md)
