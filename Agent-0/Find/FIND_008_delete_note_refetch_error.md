# Delete Note Causes Refetch Error

**ID:** FIND_008 | **Status:** ✅ Resolved | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05

## 📝 Deskripsi Masalah
Setelah delete note berhasil (note dihapus dari DB), terjadi error:
```
PostgrestException(message: Cannot coerce the result to a single JSON object, code: PGRST116, details: The result contains 0 rows, hint: null)
⛔ Failed to fetch note: a4c27260-177d-4ef3-af84-382851cd6f87
```

**Root Cause:**
Ada listener/watcher yang mencoba fetch note setelah delete, tapi note sudah tidak ada di database (0 rows).

## 🕵️ Analisis & Hipotesis
1. [x] `deleteNote()` berhasil menghapus note
2. [ ] Setelah delete, ada kode yang masih mencoba fetch note by ID
3. Kemungkinan: `save()` dipanggil saat `dispose()` atau realtime listener

## 💡 Solusi
- Skip fetch/save jika note sudah di-delete
- Add flag `isDeleted` untuk prevent re-fetch
- Atau: pastikan Navigator.pop sebelum delete selesai trigger listener

## 🔗 Terkait
- PLAN_034: Notes Menu Actions (Delete & Favorite)
- File: `lib/features/notes/presentation/bloc/note_editor_cubit.dart`
