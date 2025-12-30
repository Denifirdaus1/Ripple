# Flutter Analyze Errors & Schema Sync Issues

**ID:** FIND_002 | **Status:** 🔍 Investigasi | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-30 | **Update:** 2025-12-30

## 📝 Deskripsi Masalah
User melaporkan 100+ error pada `flutter analyze`.
Analisis awal menunjukkan kemungkinan isu sinkronisasi antara logic Flutter dan Supabase Database, serta potensi masalah dependensi.

## 🕵️ Analisis & Hipotesis
- [x] **Todo Model**: Sudah disinkronisasi dengan kolom `recurrence_rule`, `parent_todo_id`, `notification_sent`.
- [ ] **Repository**: Perlu dicek apakah implementasi query Supabase (`.select()`, `.insert()`) sudah menyertakan kolom baru.
- [ ] **Analysis Errors**: Gagal dibaca via terminal (encoding issue). Menggunakan `dart analyze` untuk retry.

## 💡 Ide Solusi
1. **Fix Repository**: Pastikan semua query Supabase memuat kolom baru.
2. **Fix Dependencies**: Cek `pubspec.yaml` dan jalankan `flutter pub get`.
3. **Fix Linter Errors**: Auto-fix atau manual fix error `flutter_lints`.

## 🔗 Terkait
- Topic: TOPIC_002_fix_analyze_errors
