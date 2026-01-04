# PLAN_023: Note Editor UI Redesign (Notion-Style)

**ID:** PLAN_023 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-03 | **Update:** 2026-01-03
**Terkait:** [PLAN_004](PLAN_004_notes_feature.md), [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/02_notes_hyperlink.md)

---

## 🎯 Tujuan

Redesign 90% UI/UX halaman Add/Edit Note dengan referensi Notion-style:
1. **Properties Bar** - Tanggal, Tag, Prioritas sebagai property row
2. **Keyboard Toolbar** - Formatting tools muncul di atas keyboard saat typing
3. **Clean Header** - Minimal AppBar hanya back button dan menu
4. **Add Property Button** - Untuk menambah properti kustom

---

## 📸 Reference Design Analysis

![Reference UI](uploaded_image_1767449212989.jpg)

| Element | Description |
|---------|-------------|
| **Header** | Back button (←), Share icon, Menu (...) |
| **Title** | Italic serif font "Halaman baru", large |
| **Properties** | Tanggal, Tag, Prioritas, URL - dengan label + value |
| **Add Property** | "+ Tambahkan properti" button |
| **Comment** | Avatar + "Tambahkan komentar..." |
| **Keyboard Toolbar** | Icons: magic wand, +, Aa, clipboard, image, redo, undo, comment, keyboard |

---

## 🔍 Gap Analysis (Current vs Target)

| Feature | Current State | Target State | Action Needed |
|---------|--------------|--------------|---------------|
| Date Property | ❌ Not in DB | ✅ `note_date DATE` | Schema Migration |
| Tags Property | ❌ Not in DB | ✅ `tags TEXT[]` | Schema Migration |
| Priority Property | ❌ Not in DB | ✅ `priority TEXT` | Schema Migration |
| Title Style | Bold sans-serif | Italic serif | CSS change |
| Properties UI | ❌ None | ✅ Property rows | New widget |
| Toolbar Location | Header/Fixed | Above keyboard | Refactor |
| Toolbar Visibility | Always visible | Show on focus | State management |

---

## 🛠️ Strategi Implementasi

### Phase 1: Database Schema Migration

#### [MIGRATION] Add Note Properties Columns

```sql
-- Add new columns to notes table
ALTER TABLE notes 
ADD COLUMN IF NOT EXISTS note_date DATE,
ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS priority TEXT CHECK (priority IN ('low', 'medium', 'high'));
```

> Menggunakan Supabase MCP untuk apply migration.

---

### Phase 2: Update Domain & Data Layer

#### [MODIFY] [note.dart](file:///c:/Project/ripple/lib/features/notes/domain/entities/note.dart)

```dart
class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic> content;
  final String? milestoneId;
  final DateTime? noteDate;        // NEW
  final List<String> tags;          // NEW
  final NotePriority? priority;     // NEW
  final DateTime createdAt;
  final DateTime updatedAt;
  // ...
}

enum NotePriority { low, medium, high }
```

#### [MODIFY] [note_model.dart](file:///c:/Project/ripple/lib/features/notes/data/models/note_model.dart)

Update `fromJson()` dan `toJson()` untuk handle new fields.

---

### Phase 3: UI Redesign

#### [MODIFY] [note_editor_page.dart](file:///c:/Project/ripple/lib/features/notes/presentation/pages/note_editor_page.dart)

**Complete rewrite** dengan struktur baru:

```dart
Scaffold(
  backgroundColor: AppColors.background,
  appBar: _buildMinimalAppBar(),  // Back, Share, Menu only
  body: Column(
    children: [
      // Title Field (Italic, large)
      _TitleField(controller: _titleController),
      
      // Properties Section
      _PropertiesSection(
        date: state.note.noteDate,
        tags: state.note.tags,
        priority: state.note.priority,
        onDateTap: () => _showDatePicker(),
        onTagsTap: () => _showTagsEditor(),
        onPriorityTap: () => _showPriorityPicker(),
      ),
      
      // Add Property Button
      _AddPropertyButton(onTap: _showPropertyMenu),
      
      // Divider
      const Divider(),
      
      // Editor Content (Expanded)
      Expanded(
        child: QuillEditor.basic(...),
      ),
      
      // Keyboard Toolbar (Conditional)
      if (_isEditorFocused)
        _KeyboardToolbar(controller: _controller),
    ],
  ),
)
```

#### [NEW] [note_properties_section.dart](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/note_properties_section.dart)

Widget untuk menampilkan property rows:

```dart
class NotePropertiesSection extends StatelessWidget {
  // Tanggal row
  // Tag row  
  // Prioritas row
}

class _PropertyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  // ...
}
```

#### [NEW] [note_keyboard_toolbar.dart](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/note_keyboard_toolbar.dart)

Horizontal scrollable toolbar yang muncul di atas keyboard:

```dart
class NoteKeyboardToolbar extends StatelessWidget {
  // Icons: magic wand, +, Aa, clipboard, image, redo, undo, comment, keyboard hide
  // Horizontal ListView
  // Positioned above keyboard using MediaQuery.viewInsets
}
```

---

### Phase 4: State Management Updates

#### [MODIFY] [note_editor_cubit.dart](file:///c:/Project/ripple/lib/features/notes/presentation/bloc/note_editor_cubit.dart)

Add methods:
- `updateDate(DateTime? date)`
- `updateTags(List<String> tags)`
- `updatePriority(NotePriority? priority)`

Update `save()` to include new fields.

---

## ✅ Kriteria Sukses

1. ✅ Schema migration applied tanpa error
2. ✅ Properties (Date, Tags, Priority) bisa di-set dan tersimpan
3. ✅ Toolbar muncul di atas keyboard saat fokus ke editor
4. ✅ Toolbar hilang saat focus out dari editor
5. ✅ UI clean dan match dengan reference design
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

**Test 1: Schema Migration**
- Cek Supabase: `SELECT * FROM notes LIMIT 1`
- **Expected:** Kolom `note_date`, `tags`, `priority` exists

**Test 2: Properties UI**
1. Buka Note Editor (create baru)
2. **Expected:** Lihat property rows: Tanggal, Tag, Prioritas
3. Tap Tanggal → Date picker muncul
4. Tap Tag → Tag editor muncul
5. Tap Prioritas → Priority picker muncul

**Test 3: Keyboard Toolbar**
1. Tap di area editor (content)
2. **Expected:** Toolbar muncul di atas keyboard
3. Tap di luar editor
4. **Expected:** Toolbar hilang

**Test 4: Save Properties**
1. Set date, add tag "work", set priority "high"
2. Save dan re-open
3. **Expected:** Semua value tersimpan

---

## 📊 Impact Analysis

| Aspect | Risk | Notes |
|--------|------|-------|
| Breaking Changes | 🟡 Medium | Schema migration needed, existing notes tanpa properties akan null |
| Performance | 🟢 Low | No heavy computation |
| Side Effects | 🟢 Low | Backward compatible - new columns nullable |
| UI/UX | 🟡 Medium | Major redesign, test thoroughly |
