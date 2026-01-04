# PLAN_027: System Back Gesture Fix & Auto-Date Note

**ID:** PLAN_027 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04

## 🎯 Tujuan
1. Fix: System back gesture (swipe/button android) tidak trigger NoteBloc update
2. Feature: Auto-fill note date dengan tanggal pembuatan untuk note baru

---

## 📊 Root Cause Analysis

### Issue 1: System Back Gesture Tidak Update

**Current Code:**
```dart
PopScope(
  canPop: true,  // ← Pop happens INSTANTLY
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;  // ← Returns early, NoteBloc never notified!
    // ...save logic never runs when didPop is true
  },
)
```

**Problem:** With `canPop: true`:
- Pop happens BEFORE callback executes
- `didPop` is always `true`
- Our code returns early, skipping NoteBloc notification

**Solution:** Use `canPop: false` and manually handle save + pop:
```dart
PopScope(
  canPop: false,  // ← Block automatic pop
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    // Save and notify NoteBloc
    await _saveAndNotifyBloc();
    if (mounted) Navigator.of(context).pop();  // Manual pop
  },
)
```

---

## 🛠️ Strategi Implementasi

### Phase 1: Fix PopScope Logic
- [ ] Change `canPop: true` → `canPop: false`
- [ ] In `onPopInvokedWithResult`: save, notify NoteBloc, then manually pop
- [ ] Remove separate `_saveAndPop()` method (merge logic)

### Phase 2: Auto-Date for New Notes
- [ ] In `NoteEditorCubit.loadNoteById()`, when creating new note (`id == 'new'`)
- [ ] Set `noteDate: DateTime.now()` automatically
- [ ] User can still clear it manually via date picker

---

## 📁 Files Affected

### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)
- Change PopScope to `canPop: false`
- Update `onPopInvokedWithResult` to save, notify, and manual pop

### [MODIFY] [note_editor_cubit.dart](file:///c:/Project/ripple/lib/features/notes/presentation/bloc/note_editor_cubit.dart)
- Auto-set `noteDate` when creating new note

---

## ✅ Kriteria Sukses
1. Edit note → System back gesture → Notes list updates immediately ✅
2. Back button → Notes list updates immediately ✅
3. Create new note → Date field auto-filled with today's date ✅

---

## 🧪 Verification Plan

### Static Analysis
```bash
flutter analyze
```

### Manual Testing (User)
1. **Test System Back Gesture:**
   - Open existing note
   - Change the title
   - Use system back gesture (swipe from edge or back button)
   - Verify notes list shows updated title immediately

2. **Test Auto-Date:**
   - Create a new note (tap + button on Notes tab)
   - Verify date field shows today's date by default
   - Verify user can clear or change the date

---

## 🔗 Terkait
- [PLAN_026](PLAN_026_notes_save_sync_fix.md) - Notes Save/Sync Fix
