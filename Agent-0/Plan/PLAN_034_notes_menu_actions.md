# PLAN_034: Notes Menu Actions (Delete & Favorite)

**ID:** PLAN_034 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05

## 🎯 Tujuan
Menambahkan fitur aksi pada note editor melalui menu titik 3 (PopupMenu):
- **Delete Note** - Hapus note dengan konfirmasi
- **Add to Favorite** - Toggle favorite status note
- Hapus tombol Share yang tidak terpakai

## 🛠️ Strategi Implementasi

### Phase 1: Database Schema
1. [ ] Add `is_favorite` column to `notes` table via Supabase migration

---

### Phase 2: Update Note Entity & Model
1. [ ] Add `isFavorite` field to `Note` entity
2. [ ] Update `NoteModel.fromJson()` and `toJson()` 
3. [ ] Update `copyWith` method

---

### Phase 3: Update Note Repository & Cubit
1. [ ] Add `deleteNote()` method to `NoteEditorCubit`
2. [ ] Add `toggleFavorite()` method to `NoteEditorCubit`
3. [ ] Update auto-save to include `is_favorite`

---

### Phase 4: Update NoteEditorPage UI
1. [ ] Remove Share button from AppBar
2. [ ] Replace 3-dot menu with PopupMenuButton
3. [ ] Add menu items:
   - 🗑️ Hapus (with delete confirmation)
   - ⭐ Tambah ke Favorit / ✓ Hapus dari Favorit
   - *(Placeholder for future)*: Duplikat, Tambah ke Folder

---

### Phase 5: Update NoteCard Display
1. [ ] Add favorite indicator (star icon) on NoteCard
2. [ ] Visual feedback when note is favorited

---

## ✅ Kriteria Sukses
- Database memiliki kolom `is_favorite`
- User dapat delete note dengan konfirmasi
- User dapat toggle favorite status
- Share button dihapus
- NoteCard menampilkan indikator favorite
- `flutter analyze` → 0 errors

## 🔗 Terkait
- PLAN_033: Notes Status & Description (completed)
- Entity: `lib/features/notes/domain/entities/note.dart`
- UI: `lib/features/notes/presentation/pages/note_editor_page.dart`
