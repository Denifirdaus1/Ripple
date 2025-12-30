# Database Schema Implementation (Supabase)

**ID:** PLAN_001 | **Status:** ✅ Selesai | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-30 | **Update:** 2025-12-30

## 🎯 Tujuan

Mengimplementasikan desain database schema Ripple MVP ke project Supabase secara terstruktur dan aman. Ini mencakup pembuatan tabel, RLS policies, storage buckets, database functions, cron jobs, dan edge functions untuk fitur notifikasi.

Implementasi ini didasarkan pada **TOPIC_006** (Database Schema & Backend) dan menggunakan best practices keamanan (RLS) serta performa (Indexing).

## 🛠️ Strategi Implementasi

### Phase 1: Preparation & Extensions
1. [ ] **Verify Environment**: Pastikan `SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` valid.
2. [ ] **Enable Extensions**: Aktifkan extension `pg_cron` dan `pg_net` via Dashboard atau API (jika memungkinkan).
3. [ ] **Vault Setup**: Konfigurasi Supabase Vault untuk menyimpan secrets (`project_url`, `service_role_key`).

### Phase 2: Core Tables & RLS (Sequential)
*Urutan penting untuk foreign key constraints.*

4. [ ] **Create `goals` Table**:
   - Table definition
   - Indexes
   - RLS (Select/Insert/Update/Delete own data)
5. [ ] **Create `milestones` Table**:
   - Definisikan FK ke `goals`
   - RLS policies inherit dari goals
6. [ ] **Create `todos` Table**:
   - Core fields, Scheduling fields, Notification fields (`notification_sent`)
   - FK ke `milestones` (optional)
   - Recursive FK (`parent_todo_id`)
   - Indexes untuk performance (terutama `scheduled_date` dan `user_id`)
   - RLS policies
7. [ ] **Create `focus_sessions` Table**:
   - Analytics tracking
   - RLS policies
8. [ ] **Create `user_devices` Table**:
   - FCM token storage
   - Unique constraint `(user_id, fcm_token)`
   - RLS policies

### Phase 3: Rich Content (Notes)
9. [ ] **Create `notes` Table**:
   - FK ke `milestones`
   - Content JSONB structure
   - RLS policies
10. [ ] **Create Junction Tables**:
    - `note_mentions` (notes <-> todos)
    - RLS policies
11. [ ] **Create `attachments` Table**:
    - Metadata storage
    - RLS policies

### Phase 4: Storage
12. [ ] **Create Buckets**:
    - `note-attachments` (50MB)
    - `milestone-banners` (10MB)
13. [ ] **Storage Policies**:
    - Implementasi RLS untuk akses folder berbasis `user_id`

### Phase 5: Backend Logic (Backend-as-a-Service)
14. [ ] **Deploy SQL Functions**:
    - `update_updated_at()` trigger
    - `generate_recurring_todos_for_date()`
    - `send_upcoming_reminders()`
15. [ ] **Schedule Cron Jobs**:
    - `generate-recurring-todos-weekly` (Midnight)
    - `send-upcoming-reminders` (Every minute)
    - Maintenance jobs (cleanup)
16. [ ] **Deploy Edge Function**:
    - `send-notification` (TypeScript)
    - Set Supabase Secrets (`FIREBASE_SERVICE_ACCOUNT`)

## ✅ Kriteria Sukses
- [ ] Semua tabel terbuat dengan constraint yang benar.
- [ ] RLS aktif di **SEMUA** tabel (Security check: tidak ada tabel public).
- [ ] Cron job berjalan dan tercatat di `cron.job_run_details`.
- [ ] Edge Function bisa dipanggil via `pg_net`.
- [ ] Flutter app bisa connect dan melakukan operasi CRUD user-scoped.

## 🔗 Terkait
- Topic: [06_database_schema.md](../Topic/TOPIC_001_ripple_mvp/06_database_schema.md)
- Topic: [07_push_notifications.md](../Topic/TOPIC_001_ripple_mvp/07_push_notifications.md)
