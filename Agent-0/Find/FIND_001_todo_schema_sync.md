# Schema Sync: Todo Entity Missing DB Columns

**ID:** FIND_001 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High  
**Dibuat:** 2024-12-30 | **Update:** 2024-12-30

## 📝 Deskripsi Masalah

Setelah audit schema, ditemukan bahwa **entity `Todo` di Flutter** tidak memiliki beberapa kolom yang **sudah ada di database Supabase**:

### Kolom yang Ada di DB tapi TIDAK di Code:

| DB Column | DB Type | Fungsi |
|-----------|---------|--------|
| `recurrence_rule` | jsonb | Untuk recurring todos (aturan pengulangan) |
| `parent_todo_id` | uuid | FK ke todo induk (untuk todo turunan recurring) |
| `notification_sent` | boolean | Flag apakah reminder sudah dikirim |

### Impact:
1. **Recurring Todos**: Fitur recurring tidak dapat digunakan karena entity tidak mengekspos `recurrence_rule` dan `parent_todo_id`.
2. **Push Notifications**: Edge Function `notify-users` menggunakan `notification_sent` untuk filter. Jika code Flutter tidak menghiraukan ini, behavior bisa tidak konsisten (misal: tidak bisa reset notification).

## 🕵️ Analisis & Hipotesis

- [x] Cek `todos` table di Supabase → Kolom ada.
- [x] Cek `Todo` entity di Flutter → Kolom TIDAK ada.
- [x] Cek `TodoModel.fromJson/toJson` → Tidak parsing kolom tersebut.

**Root Cause**: Kolom ditambahkan ke DB (mungkin via PLAN_001/PLAN_002) tapi tidak di-sync ke entity/model di Flutter. Kemungkinan ditambahkan saat membuat Edge Function untuk notifications, tapi Flutter client tidak diupdate.

## 💡 Ide Solusi

1. **Update `Todo` Entity** (`lib/features/todo/domain/entities/todo.dart`):
   - Tambah `recurrence_rule: Map<String, dynamic>?`
   - Tambah `parentTodoId: String?`
   - Tambah `notificationSent: bool`

2. **Update `TodoModel`** (`lib/features/todo/data/models/todo_model.dart`):
   - Tambah parsing di `fromJson`.
   - Tambah field di `toJson`.

3. **Consider UI for Recurring**: Jika recurring feature akan diaktifkan, perlu UI untuk set recurrence rule.

## 🔗 Terkait
- **Topic:** [TOPIC_001 - Ripple MVP](..\Topic\TOPIC_001_ripple_mvp\_main.md)
- **Plan:** PLAN_003 (TodoList & Focus Mode)
- **Plan:** PLAN_006 (Push Notifications - `notification_sent` related)
