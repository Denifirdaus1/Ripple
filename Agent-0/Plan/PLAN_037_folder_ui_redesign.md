# Folder UI Redesign - Notes Integration

**ID:** PLAN_037 | **Status:** 📋 Backlog | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-06 | **Update:** 2026-01-06

## 🎯 Tujuan

Redesign folder system agar terintegrasi langsung dengan Notes page:
1. **Hapus Inbox** - Fokus hanya pada folder, tidak ada virtual inbox
2. **Bottom Sheet** - Ganti drawer dengan bottom sheet untuk create/select folder
3. **Folder Cards** - Tampilkan folder sebagai cards di notes_page (mirip note_card)
4. **Folder Detail Page** - Halaman untuk melihat & menambah notes ke folder

## 🛠️ Strategi Implementasi

### Phase 1: Remove Old UI & Prepare
1. [ ] Hapus `FolderDrawer` dari `notes_page.dart`
2. [ ] Hapus `folder_drawer.dart` widget (deprecated)
3. [ ] Hapus referensi inbox di `folder_tree_widget.dart` dan `folder_bloc.dart`
4. [ ] Update `folder_repository_impl.dart` - hapus `getInboxContents()` calls

---

### Phase 2: Create FolderCard Widget
5. [ ] Buat `folder_card.dart` mirip `note_card.dart`:
   - Icon folder (bukan notes icon)
   - Nama folder sebagai title
   - Jumlah notes di dalamnya
   - Color indicator jika ada
   - onTap → navigate ke folder detail

---

### Phase 3: Update Notes Page
6. [ ] Ubah `notes_page.dart` menjadi mixed view:
   - Section "Folders" → list of `FolderCard`
   - Section "Notes" → list of `NoteCard` (notes tanpa folder)
7. [ ] Ganti folder icon action → `CreateFolderBottomSheet`:
   - Bottom sheet untuk input nama folder
   - Langsung create folder saat submit

---

### Phase 4: Create Folder Detail Page (Clean Architecture)

#### Domain Layer
8. [ ] Gunakan existing entities: `Folder`, `FolderContents`
9. [ ] Tambah use case `GetFolderWithNotes` jika belum ada

#### Presentation Layer
10. [ ] Buat `folder_detail_page.dart`:
    - Header: folder name, edit/delete actions
    - Body: list of `NoteCard` dalam folder
    - FAB: add existing note / create new note in folder
11. [ ] Buat `FolderDetailCubit` atau gunakan `FolderBloc` existing
12. [ ] Register route `/notes/folder/:folderId` di router

---

### Phase 5: Create/Select Note for Folder
13. [ ] Opsi 1: FAB → bottom sheet pilih note existing untuk ditambahkan
14. [ ] Opsi 2: FAB → create new note yang otomatis masuk folder
15. [ ] Update `MoveToFolderSheet` jika perlu

---

### Phase 6: Cleanup & Testing
16. [ ] Hapus file-file deprecated (folder_drawer, folder_tree_widget)
17. [ ] Run flutter analyze
18. [ ] Manual test full flow

## 📁 File Changes

### New Files
```
lib/features/notes/presentation/widgets/folder_card.dart  [NEW]
lib/features/notes/presentation/pages/folder_detail_page.dart  [NEW]
lib/features/notes/presentation/widgets/create_folder_bottom_sheet.dart  [NEW]
```

### Modified Files
```
lib/features/notes/presentation/pages/notes_page.dart  [MODIFY]
lib/features/folder/presentation/bloc/folder_bloc.dart  [MODIFY]
lib/core/router/app_router.dart  [MODIFY]
```

### Deleted Files
```
lib/features/folder/presentation/widgets/folder_drawer.dart  [DELETE]
lib/features/folder/presentation/widgets/folder_tree_widget.dart  [DELETE]
lib/features/folder/presentation/widgets/folder_tile.dart  [DELETE]
```

## ✅ Kriteria Sukses
- Build berhasil tanpa error
- `flutter analyze` clean
- Notes page menampilkan folder cards + notes cards
- Tap folder card → masuk folder detail page
- Folder detail page menampilkan notes di folder
- Bisa create folder, tambah note ke folder, hapus folder

## 🧪 Verifikasi

### Manual Testing
1. **Create Folder:** 
   - Buka Notes page → tap folder icon → isi nama → submit
   - Folder card muncul di notes page
2. **Open Folder:**
   - Tap folder card → masuk folder detail page
   - Page menampilkan notes dalam folder (awalnya kosong)
3. **Add Note to Folder:**
   - Di folder detail, tap FAB → pilih/create note
   - Note muncul di folder detail page
4. **Move Note:**
   - Di note editor, tap ⋯ → "Pindahkan ke Folder"
   - Note berpindah ke folder yang dipilih

## 🔗 Terkait
- Plan: PLAN_036 (Universal Folder System - base implementation)
- Topic: TOPIC_004 (Universal Folder System)
