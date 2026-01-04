# PLAN_021: Fix Notes List Auto-Update

**ID:** PLAN_021 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-03 | **Update:** 2026-01-03
**Terkait:** [PLAN_004](PLAN_004_notes_feature.md), [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)

---

## 🎯 Tujuan
Fix bug dimana **Notes list tidak auto-update** setelah membuat atau mengedit note. User harus restart app untuk melihat perubahan.

---

## 🔍 Root Cause Analysis

### Problem
`NoteEditorPage` memiliki `BlocListener` yang seharusnya dispatch `NoteSaved` ke `NoteBloc`, namun **kondisi `listenWhen` salah**:

```dart
// ❌ Current (WRONG):
listenWhen: (previous, current) =>
    previous.status == NoteEditorStatus.loading &&
    current.status == NoteEditorStatus.success,
```

**Issue:** Kondisi ini hanya trigger saat **initial load** (loading → success), bukan saat **save complete** (saving → success).

### Expected Flow
1. User create/edit note → `NoteEditorCubit.save()` dipanggil
2. Status: `success → saving → success`
3. `BlocListener` should dispatch `NoteSaved(note)` ke `NoteBloc`
4. `NoteBloc._onNoteSaved()` update state dengan note baru
5. `NotesPage` re-render dengan list terbaru

### Actual Flow (Bug)
1. User create/edit note → save dipanggil
2. Status: `success → saving → success`  
3. ❌ `listenWhen` return false (karena previous ≠ loading)
4. ❌ `NoteSaved` tidak di-dispatch
5. ❌ List tidak update

---

## 🛠️ Strategi Implementasi

### 1. Fix BlocListener Condition

#### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)

**Change `listenWhen` condition** di line 111-113:

```diff
- listenWhen: (previous, current) =>
-     previous.status == NoteEditorStatus.loading &&
-     current.status == NoteEditorStatus.success,
+ listenWhen: (previous, current) =>
+     current.status == NoteEditorStatus.success &&
+     previous.status != current.status,
```

**Update listener logic** di line 114-124:

```diff
  listener: (context, state) {
-   if (state.status == NoteEditorStatus.success) {
-      // Notify NoteBloc to update the list manually
-      try {
-        context.read<NoteBloc>().add(NoteSaved(state.note));
-      } catch (e) {
-        // Bloc might not be in context if opened directly or structure differs.
-      }
-   }
-   _onNoteLoaded(state);
+   // Only notify NoteBloc when transitioning TO success (not during initial load)
+   if (state.note.id.isNotEmpty) {
+     try {
+       context.read<NoteBloc>().add(NoteSaved(state.note));
+     } catch (e) {
+       // Bloc might not be in context
+     }
+   }
+   // Load content into editor on initial load
+   if (state.status == NoteEditorStatus.success) {
+     _onNoteLoaded(state);
+   }
  },
```

### 2. Add Flag to Prevent Double-Load (Optional Improvement)

Tambahkan flag `_isInitialLoadDone` untuk memastikan `_onNoteLoaded` hanya dipanggil sekali saat pertama load.

---

## ✅ Kriteria Sukses

1. ✅ Create new note → kembali ke list → note baru muncul tanpa restart
2. ✅ Edit existing note → kembali ke list → perubahan terlihat
3. ✅ Auto-save (debounce) tetap berfungsi
4. ✅ `flutter analyze` clean (0 errors)

---

## 🧪 Verification Plan

### Manual Testing (Primary)

1. **Test Create Note:**
   - Buka app → Navigate ke Notes tab
   - Tap FAB (+) untuk create new note
   - Isi title "Test Note ABC" dan content apa saja
   - Tap back button
   - **Expected:** Note "Test Note ABC" muncul di list tanpa restart

2. **Test Edit Note:**
   - Dari Notes list, tap note yang sudah ada
   - Edit title menjadi "Edited Title XYZ"
   - Tap back button
   - **Expected:** Title "Edited Title XYZ" terlihat di list

3. **Test Auto-Save:**
   - Create/edit note
   - Ketik content, tunggu 2 detik (debounce)
   - Langsung tap back (tanpa menunggu)
   - Re-open note
   - **Expected:** Content tersimpan dengan benar

### Automated Verification
```powershell
flutter analyze
```
**Expected:** 0 errors, 0 warnings

---

## 📊 Impact Analysis

| Aspect | Risk | Notes |
|--------|------|-------|
| Breaking Changes | 🟢 Low | Hanya fix logic condition |
| Performance | 🟢 None | Tidak ada perubahan arsitektur |
| Side Effects | 🟡 Low | Pastikan initial load masih bekerja |
