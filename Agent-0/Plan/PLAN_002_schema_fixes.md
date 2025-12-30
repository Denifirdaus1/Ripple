# Schema Security & Performance Fixes (Supabase Linter Warnings)

**ID:** PLAN_002 | **Status:** ✅ Selesai | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-30 | **Update:** 2025-12-30

## 🎯 Tujuan

Mengatasi **11 peringatan (Warning)** dari Supabase Linter yang terdeteksi di project Ripple. Peringatan ini terkait **Security** (mutable `search_path` pada functions) dan **Performance** (RLS policies yang tidak teroptimasi & missing FK indexes).

## 🔬 Hasil Deep Research

### Security: Mutable `search_path`
- **Masalah:** Functions `SECURITY DEFINER` tanpa `search_path` eksplisit rawan injeksi karena bisa dimanipulasi oleh user.
- **Solusi (Supabase Docs):** Tambahkan `SET search_path = ''` pada definisi function. Semua referensi tabel harus menggunakan nama lengkap (e.g., `public.todos`).

### Performance: RLS `auth.uid()` Re-evaluation
- **Masalah:** `auth.uid()` dalam policy dievaluasi ulang untuk **setiap baris**, menyebabkan overhead signifikan pada tabel besar.
- **Solusi (Supabase Docs):** Bungkus dengan subquery: `(select auth.uid())`. PostgreSQL akan mengevaluasi sekali sebagai *InitPlan* dan meng-cache hasilnya.

### Performance: Unindexed Foreign Keys
- **Masalah:** FK tanpa index memperlambat `JOIN` dan `ON DELETE CASCADE`.
- **Solusi:** Buat index pada kolom FK.

## 🛠️ Strategi Implementasi

### Phase 1: Fix Functions (Security)
1. [ ] **Recreate `update_updated_at()`** with `SET search_path = ''`
2. [ ] **Recreate `generate_recurring_todos_for_date()`** with `SET search_path = ''` and fully qualified table names.
3. [ ] **Recreate `send_upcoming_reminders()`** with `SET search_path = ''` and fully qualified table names.

### Phase 2: Fix RLS Policies (Performance)
4. [ ] **Drop & Recreate `goals_all`** policy using `(select auth.uid())`
5. [ ] **Drop & Recreate `milestones_all`** policy using `(select auth.uid())`
6. [ ] **Drop & Recreate `todos_all`** policy using `(select auth.uid())`
7. [ ] **Drop & Recreate `focus_sessions_all`** policy using `(select auth.uid())`
8. [ ] **Drop & Recreate `user_devices_all`** policy using `(select auth.uid())`
9. [ ] **Drop & Recreate `notes_all`** policy using `(select auth.uid())`
10. [ ] **Drop & Recreate `note_mentions_all`** policy using `(select auth.uid())`
11. [ ] **Drop & Recreate `attachments_all`** policy using `(select auth.uid())`

### Phase 3: Add Missing Indexes (Performance)
12. [ ] **Create `idx_focus_sessions_todo_id`** on `focus_sessions(todo_id)`
13. [ ] **Create `idx_todos_parent_todo_id`** on `todos(parent_todo_id)` (partial: WHERE NOT NULL)

## ✅ Kriteria Sukses
- [ ] Supabase Linter shows **0 WARN** for Security.
- [ ] Supabase Linter shows **0 WARN** for Performance (RLS initplan).
- [ ] All FK indexes present.
- [ ] Flutter app CRUD operations still function correctly.

## 🔗 Terkait
- Topic: [06_database_schema.md](../Topic/TOPIC_001_ripple_mvp/06_database_schema.md)
- Research: Exa MCP (RLS Performance), Supabase Docs (search_path)
