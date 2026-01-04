# PLAN_026: Notes Save/Sync System Fix & FAB Keyboard Bug

**ID:** PLAN_026 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04

## 🎯 Tujuan

### Problem 1: Data Not Persisting (Priority: Critical)
User reports date, tags, and priority changes are not saved to database. After exiting and re-entering, data is lost.

### Problem 2: Notes List Not Auto-Updating (Priority: High)
After editing a note, the notes list page doesn't show updated data until user re-enters editor.

### Problem 3: FAB Moves with Keyboard (Priority: Medium)
When keyboard appears in note editor, the FAB from MainShell moves up with the keyboard.

---

## 📊 Root Cause Analysis

### Issue 1 & 2: Save/Sync Architecture Gap

**Current Flow (Broken):**
```
NoteEditorCubit.save() → _saveNote() → DB ✅
                       ↓
                       Updates NoteEditorCubit state ❌ (only local)
                       ↓
                       NoteBloc is NOT notified ❌
```

**TodosOverviewBloc (Working):**
```
TodosOverviewBloc._onTodoSaved() → await _saveTodo() → DB ✅
                                 ↓
                                 Updates TodosOverviewBloc.state ✅ (optimistic)
                                 ↓
                                 UI auto-updates ✅
```

**Key Differences:**
| Aspect | TodosOverviewBloc | NoteEditorCubit |
|--------|-------------------|-----------------|
| Save location | Bloc (central) | Cubit (isolated) |
| State sharing | Same Bloc for list & edit | Separate Cubit for editing |
| List notification | Automatic via same Bloc | Manual (not implemented) |

### Issue 3: FAB Keyboard Behavior

**Root Cause:** MainShell's Scaffold doesn't handle keyboard resize for nested pages. The FAB is part of MainShell and moves with `resizeToAvoidBottomInset`.

---

## 🛠️ Strategi Implementasi

### Phase 1: Fix Save Persistence (Critical)

**Problem:** `NoteEditorCubit.save()` updates `state.note` but doesn't include `noteDate`, `tags`, `priority` in the `copyWith`.

- [ ] **Step 1.1:** Verify `NoteEditorCubit.save()` includes ALL fields in `copyWith`:
  - Currently only includes: `title`, `content`, `updatedAt`
  - Missing: `noteDate`, `tags`, `priority` ← **BUG HERE**
  
- [ ] **Step 1.2:** Fix `save()` method to preserve all properties from current state.note

### Phase 2: Fix Notes List Auto-Update

**Strategy:** After save in NoteEditorCubit, dispatch `NoteSaved` event to NoteBloc.

- [ ] **Step 2.1:** Pass `NoteBloc` reference to `NoteEditorPage` or use a global event bus
- [ ] **Step 2.2:** After successful save in Cubit, dispatch `NoteSaved(savedNote)` to `NoteBloc`
- [ ] **Step 2.3:** `NoteBloc._onNoteSaved` already updates the list locally, so this should work

**Alternative (Better):** Rely on Supabase Realtime stream which NoteBloc already subscribes to. The stream should auto-update the list when data changes in DB. Need to verify stream is working.

### Phase 3: Fix FAB Keyboard Issue

- [ ] **Step 3.1:** In `main_shell.dart`, check current route and hide FAB when on note editor
- [ ] **Step 3.2:** Alternative: Use `resizeToAvoidBottomInset: false` on MainShell Scaffold when in note editor

---

## 📁 Files Affected

### [MODIFY] [note_editor_cubit.dart](file:///c:/Project/ripple/lib/features/notes/presentation/bloc/note_editor_cubit.dart)
- Fix `save()` method to include ALL note properties in `copyWith`

### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)
- After successful save, dispatch `NoteSaved` event to `NoteBloc`
- Verify FAB behavior with keyboard

### [MODIFY] [main_shell.dart](file:///c:/Project/ripple/lib/core/layout/main_shell.dart)
- Hide FAB when on note editor page OR
- Add keyboard-aware handling

---

## ✅ Kriteria Sukses
1. Edit note → add date/tags/priority → exit → re-enter → data is preserved ✅
2. Edit note title → go back to notes list → title updates immediately ✅
3. Open note editor → tap in editor → keyboard appears → FAB stays at original position ✅

---

## 🧪 Verification Plan

### Static Analysis
```bash
flutter analyze
```

### Manual Testing (User)
1. **Test Save Persistence:**
   - Open note editor
   - Add a date (e.g., today)
   - Add a tag
   - Set priority to "Penting"
   - Type some title/content
   - Go back (should auto-save)
   - Reopen same note
   - Verify date, tag, priority are preserved

2. **Test List Auto-Update:**
   - Open a note
   - Change the title to something new
   - Go back to notes list
   - Verify the new title appears immediately (no need to re-enter editor)

3. **Test FAB Keyboard:**
   - Open note editor
   - Tap in text content area
   - Keyboard should appear
   - FAB should NOT move up with keyboard (or should hide completely)

---

## 🔗 Terkait
- [PLAN_025](PLAN_025_notecard_fix_sync.md) - Note Card UI Fix
- [PLAN_024](PLAN_024_ui_refinement_tags.md) - Note Editor UI Refinements
