# PLAN_035: Fix Notes List Reactive Update After Delete

**ID:** PLAN_035 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05

## 🎯 Tujuan
Fix issue dimana notes list tidak ter-update secara langsung setelah delete note. User harus restart aplikasi untuk melihat note terhapus.

## 📝 Root Cause Analysis

### Log Evidence:
```
│ 🐛 Removing note from list: 2bfb638d-...
│ 🐛 NoteSaved event received: yes aja    <-- THIS OVERRIDES REMOVAL!
```

### Problem Flow:
1. User confirms delete
2. `cubit.deleteNote()` → deletes from DB ✅
3. `NoteBloc.add(NoteRemovedFromList)` → removes from state list ✅
4. `Navigator.pop()` triggers `dispose()` 
5. `dispose()` calls `_saveImmediately()` → triggers `NoteSaved` event
6. **`NoteSaved` re-adds the note to list!** ❌

### Current Guard Issue:
- `_saveImmediately()` checks `cubit.state.isDeleted`
- BUT `NoteSaved` event in `WillPopScope` on line 369 is called BEFORE delete completes!

## 🛠️ Strategi Implementasi

### Phase 1: Fix WillPopScope Save Logic
Modify `note_editor_page.dart` WillPopScope to skip save when note is deleted.

1. [ ] Add check for `cubit.state.isDeleted` in WillPopScope's `onWillPop`
2. [ ] Move `NoteSaved` dispatch inside the `!isDeleted` condition

### Phase 2: Verify All NoteSaved Dispatches
Audit all places that dispatch `NoteSaved` event.

1. [ ] Check line 127: `initState()` save callback
2. [ ] Check line 341: `BlocListener` save  
3. [ ] Check line 369: `WillPopScope` onWillPop
4. [ ] Add `isDeleted` guard to each

### Phase 3: Consider Alternative Approach
If Phase 1-2 don't fix, consider:

1. [ ] Add `deletedNoteIds` Set in NoteBloc to filter out deleted notes from stream
2. [ ] Modify `_onNoteSaved` to check if noteId is in deleted set

## ✅ Kriteria Sukses
- [ ] Delete note, immediately see it removed from list on notes_page
- [ ] No restart required
- [ ] `flutter analyze` → 0 errors

## 🧪 Verification Plan

### Manual Test (Primary)
1. Run `flutter run`
2. Create a new note dengan title "Test Delete" 
3. Tap note untuk edit
4. Tap 3-dot menu → Delete → Confirm
5. **Expected:** Note card "Test Delete" langsung hilang dari list tanpa restart

### Code Verification
1. Check console logs:
   - Should see: "Removing note from list: {id}"
   - Should NOT see: "NoteSaved event received" after delete

## 🔗 Terkait
- FIND_008: Delete Note Causes Refetch Error (Resolved)
- PLAN_034: Notes Menu Actions (Delete & Favorite)
