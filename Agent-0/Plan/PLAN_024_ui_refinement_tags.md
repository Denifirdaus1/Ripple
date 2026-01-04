# PLAN_024: Note Editor UI Refinements & Advanced Tags

**ID:** PLAN_024 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-03 | **Update:** 2026-01-03
**Terkait:** [PLAN_023](PLAN_023_note_editor_redesign.md)

---

## 🎯 Tujuan

Refine UI Note Editor sesuai feedback user dan implementasi sistem Tags yang lebih advanced (warna custom) serta perbaikan fitur Tanggal.

---

## 🔍 Feedback Points & Solutions

1.  **Garis Hitam**: Hapus `Divider` di `note_editor_page.dart` (below add property).
2.  **Header Styles**:
    *   Hapus background container di Title.
    *   Ubah font Title menjadi **Bold** (bukan Italic).
3.  **Editor Font Small**: Naikkan default font size editor.
4.  **Date Issue**: Fix date saver.
    *   *Investigation needed*: Cek apakah `noteDate` ter-map dengan benar di `toJson`.
5.  **Advanced Tags**:
    *   Template: Ide, Catatan, Pengingat.
    *   Custom Tags + Color Edit.
    *   *Solution*: Buat tabel `tags` untuk menyimpan definisi tag (nama & warna).
6.  **Priority Highlight**: Ubah UI Priority menjadi Chip dengan background color.

---

## 🛠️ Strategi Implementasi

### Phase 1: Schema Migration (Tags)

Kita butuh menyimpan metadata tag (warna). Kolom `notes.tags` saat ini hanya `TEXT[]`.
Kita buat tabel referensi `user_tags`.

```sql
CREATE TABLE user_tags (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  color_hex TEXT NOT NULL DEFAULT '#808080', -- Default gray
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, name)
);

-- RLS
ALTER TABLE user_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their tags" ON user_tags
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### Phase 2: Domain & Data Layer Updates

1.  **Tag Entity**: Create `Tag` class (id, name, color).
2.  **Repository**:
    *   `getTags()`: Fetch available tags.
    *   `createTag(String name, String color)`: Save new definition.
    *   `updateTagColor(...)`.
3.  **Note Repository**:
    *   Saat load Note, kita load juga daftar `user_tags` untuk map warna.

### Phase 3: UI Implementation

#### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)

*   **Header**: Hapus `InputDecoration` style yang italic/gray. Pakai `TextStyle` bold black large.
*   **Editor**: Set `QuillEditor` defaultTheme / styling options.
*   **Properties**: Hapus `Divider`.

#### [MODIFY] [note_properties_section.dart](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/note_properties_section.dart)

*   **Priority Row**: Gunakan `Container` dengan background color (opacity) untuk value priority.
    *   High: Red Background + Red Text.
    *   Medium: Orange Background + Orange Text.
*   **Tag Row**:
    *   Tampilkan tags sebagai Chips dengan warna dari `user_tags`.

#### [NEW] [tag_selector_sheet.dart](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/tag_selector_sheet.dart)

*   BottomSheet baru untuk manage tags.
*   List tags yang ada (Ide, Catatan, Pengingat defaults).
*   Add new tag functionality.
*   Color picker untuk tag background.

### Phase 4: Fix Date Logic

*   Verify `NoteEditorCubit.updateDate`.
*   Ensure UI rebuilds on state change.

---

## ✅ Kriteria Sukses

1. ✅ Title Header: Bold, Clean background.
2. ✅ Editor Font: Lebih besar dan terbaca.
3. ✅ Tanggal: Berfungsi simpan dan load.
4. ✅ Tags: Bisa create, pilih warna, dan save ke note.
5. ✅ Priority: Tampil dengan background highlight.
6. ✅ `flutter analyze` clean.

---

## 🧪 Verification Plan

### Test Manual
1.  **UI Check**: Buka editor, pastikan header clean bold.
2.  **Date Test**: Set tanggal -> Back -> Buka lagi -> Tanggal harus persist.
3.  **Tag Flow**:
    *   Buka Tag Selector.
    *   Buat tag "Test" warna Biru.
    *   Pilih tag "Test".
    *   Save note.
    *   Buka note -> Tag "Test" harus ada dengan background Biru.
