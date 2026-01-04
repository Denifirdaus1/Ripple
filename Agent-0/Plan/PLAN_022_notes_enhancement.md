# PLAN_022: Notes Enhancement & Mention System Fix

**ID:** PLAN_022 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-03 | **Update:** 2026-01-03
**Terkait:** [PLAN_004](PLAN_004_notes_feature.md), [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/02_notes_hyperlink.md)

---

## 🎯 Tujuan
1. **Fix Mention Search** - Dialog tidak menampilkan todo meskipun user punya banyak data
2. **Fix Mention Sync** - Link tidak ter-sync ke `note_mentions` table
3. **Implement Click Navigation** - Klik mention navigate ke Todo detail

---

## 🔍 Root Cause Analysis

### Issue 1: Empty Search Results
**Location:** `NoteEditorCubit.searchMentions()` (line 132-136)

```dart
// ❌ PROBLEM: Empty query returns nothing
if (query.isEmpty) {
  emit(state.copyWith(mentionSearchResults: []));
  return;
}
```

**Impact:** Dialog opens empty. User must type to see results.

**Fix:** Load recent todos on init when query is empty.

---

### Issue 2: Link Format Mismatch
**Problem:** Two different attribute formats used inconsistently.

| Component | Format Used | Expected |
|-----------|-------------|----------|
| `_insertMention()` | `LinkAttribute('todo://${todo.id}')` | ✅ Works for display |
| `_syncMentions()` | `attributes['mention'] = todoId` | ❌ Never set! |

**Code in `note_editor_page.dart` line 90:**
```dart
_controller.formatText(index, text.length, LinkAttribute('todo://${todo.id}'));
```

**Code in `note_repository_impl.dart` line 66:**
```dart
if (attributes != null && attributes.containsKey('mention')) { // ← Never matches!
```

**Impact:** Mentions never saved to `note_mentions` table.

**Fix Options:**
1. **Option A:** Change sync logic to parse `link` attribute for `todo://` prefix
2. **Option B:** Use custom `mention` attribute instead of `link` (more semantic)

**Decision:** Option A (simpler, no Quill customization needed)

---

### Issue 3: Click Navigation Not Implemented
**Current:** Shows SnackBar with Todo ID  
**Expected:** Navigate to Todo detail page

**Location:** `_handleLinkTap()` (line 96-106)

---

## 🛠️ Strategi Implementasi

### Phase 1: Fix Mention Search Dialog

#### [MODIFY] [note_editor_cubit.dart](file:///c:/Project/ripple/lib/features/notes/presentation/bloc/note_editor_cubit.dart)

1. Add `loadRecentTodos()` method to fetch todos on dialog open
2. Modify `searchMentions()` to fetch all todos when query empty

```dart
Future<void> searchMentions(String query) async {
  emit(state.copyWith(isMentionSearchLoading: true));
  try {
    // Empty query = load recent todos (not empty list)
    final results = await _searchMentions.searchTodos(query);
    emit(state.copyWith(
      mentionSearchResults: results,
      isMentionSearchLoading: false,
    ));
  } catch (e) {
    emit(state.copyWith(isMentionSearchLoading: false));
  }
}
```

#### [MODIFY] [note_repository_impl.dart](file:///c:/Project/ripple/lib/features/notes/data/repositories/note_repository_impl.dart)

Update `searchTodos()` to handle empty query:

```dart
@override
Future<List<Todo>> searchTodos(String query) async {
  try {
    AppLogger.d('Searching todos with query: $query');
    var request = _supabase.from('todos').select();
    
    // If query provided, filter by title
    if (query.isNotEmpty) {
      request = request.ilike('title', '%$query%');
    }
    
    // Order by recent and limit
    final response = await request
        .order('created_at', ascending: false)
        .limit(20);
    
    return (response as List).map((json) => TodoModel.fromJson(json)).toList();
  } catch (e, s) {
    AppLogger.e('Failed to search todos', e, s);
    rethrow;
  }
}
```

#### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)

Trigger search on dialog open:

```dart
// In _MentionDialog initState or build
@override
void initState() {
  super.initState();
  // Load todos immediately when dialog opens
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<NoteEditorCubit>().searchMentions('');
  });
}
```

---

### Phase 2: Fix Mention Sync to Database

#### [MODIFY] [note_repository_impl.dart](file:///c:/Project/ripple/lib/features/notes/data/repositories/note_repository_impl.dart)

Update `_syncMentions()` to parse `link` attribute for `todo://` prefix:

```dart
Future<void> _syncMentions(Note note) async {
  try {
    final ops = note.content['ops'] as List<dynamic>? ?? [];
    final mentionsToInsert = <Map<String, dynamic>>[];

    for (int i = 0; i < ops.length; i++) {
      final op = ops[i] as Map<String, dynamic>;
      final attributes = op['attributes'] as Map<String, dynamic>?;
      
      // Check for link attribute with todo:// scheme
      if (attributes != null && attributes.containsKey('link')) {
        final link = attributes['link'] as String;
        if (link.startsWith('todo://')) {
          final todoId = link.replaceFirst('todo://', '');
          mentionsToInsert.add({
            'note_id': note.id,
            'todo_id': todoId,
            'block_index': i,
          });
        }
      }
    }

    // Clear existing and insert new
    await _supabase.from('note_mentions').delete().eq('note_id', note.id);
    if (mentionsToInsert.isNotEmpty) {
      await _supabase.from('note_mentions').insert(mentionsToInsert);
    }
    
    AppLogger.d('Synced ${mentionsToInsert.length} mentions');
  } catch (e, s) {
    AppLogger.e('Failed to sync mentions for note: ${note.id}', e, s);
    // Don't rethrow - mention sync failure shouldn't block save
  }
}
```

---

### Phase 3: Implement Click Navigation

#### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)

Update `_handleLinkTap()` to navigate:

```dart
void _handleLinkTap(String url) {
  if (url.startsWith('todo://')) {
    final todoId = url.replaceFirst('todo://', '');
    // Navigate to Todo detail page
    context.push('/todos/detail/$todoId');
  }
}
```

> **Note:** Requires TodoDetailPage route to exist (implemented in PLAN_020)

---

## ✅ Kriteria Sukses

1. ✅ Open Mention Dialog → Recent todos appear immediately
2. ✅ Type search → Results filter by title
3. ✅ Select todo → Chip inserted as link
4. ✅ Save note → `note_mentions` table updated
5. ✅ Click mention → Navigate to Todo detail
6. ✅ `flutter analyze` → 0 errors

---

## 🧪 Verification Plan

### Automated Verification
```powershell
cd c:\Project\ripple
flutter analyze
```
**Expected:** 0 errors

### Manual Testing

**Test 1: Mention Dialog Shows Todos**
1. Buka app → Notes tab → Create new note
2. Tap ikon `@` di AppBar
3. **Expected:** Dialog muncul dengan list todos (tidak kosong)
4. Ketik "tes" di search
5. **Expected:** Hasil filter sesuai query

**Test 2: Mention Sync to Database**
1. Dari dialog, pilih satu todo
2. Tap back untuk save note
3. Cek database: `SELECT * FROM note_mentions WHERE note_id = '{note_id}'`
4. **Expected:** Ada row dengan `todo_id` yang di-mention

**Test 3: Click Mention Navigation**
1. Buka note yang sudah ada mention
2. Tap link mention di dalam text
3. **Expected:** Navigate ke Todo detail page

---

## 📊 Impact Analysis

| Aspect | Risk | Notes |
|--------|------|-------|
| Breaking Changes | 🟢 Low | Backward compatible |
| Performance | 🟢 Low | Query limit 20 |
| Side Effects | 🟡 Medium | Test mention sync carefully |
