# Notification Deep Linking: Navigate to Todo Detail

**ID:** PLAN_020 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-02 | **Update:** 2026-01-02

## 🎯 Tujuan
Mengimplementasikan deep linking untuk notifikasi sehingga user dapat langsung membuka halaman detail Todo terkait saat mengklik notifikasi.

## 📚 Hasil Research 

### Sumber Referensi
1. **FlutterFire Docs** - `onMessageOpenedApp` + `getInitialMessage` untuk handle tap FCM
2. **flutter_local_notifications** - `onDidReceiveNotificationResponse` + payload
3. **go_router** - `context.go('/todo/:id')` untuk deep link navigation

### Temuan Penting
- **Sudah ada**: Handler untuk `onDidReceiveNotificationResponse`, `onMessageOpenedApp`, `getInitialMessage`
- **Belum ada**: Route `/todo/:id` untuk detail Todo
- **Masalah**: Saat ini hanya navigate ke home (`/`), bukan ke detail Todo

## 🛠️ Strategi Implementasi

### Phase 1: Backend - Update Edge Function Payload
1. [ ] Update `send-notification` Edge Function untuk include `route` dalam data
2. [ ] Payload format: `{ todo_id: "xxx", route: "/todo/xxx" }`

### Phase 2: Frontend - Add Todo Detail Route
1. [ ] Buat halaman `TodoDetailPage` untuk menampilkan detail Todo
2. [ ] Tambahkan route `/todo/:todoId` di `app_router.dart`

### Phase 3: Frontend - Update Navigation Service
1. [ ] Update `NotificationNavigationService.navigateToTodo()` untuk navigate ke `/todo/:id`
2. [ ] Handle kasus TodoId null (fallback ke home)
3. [ ] Update `processPendingNavigation()` untuk deep link

### Phase 4: Testing
1. [ ] Test tap notification saat app foreground
2. [ ] Test tap notification saat app background
3. [ ] Test tap notification saat app terminated
4. [ ] Verifikasi navigasi ke Todo detail yang benar

## ✅ Kriteria Sukses
- Tap notifikasi → App buka halaman detail Todo terkait
- Handle semua state: foreground, background, terminated
- Fallback graceful jika todoId tidak valid

## 🔗 Terkait
- Plan: [PLAN_019](PLAN_019_notification_enhancements.md) (Click Navigation basic)
- Topic: [07_push_notifications.md](../Topic/TOPIC_001_ripple_mvp/07_push_notifications.md)
