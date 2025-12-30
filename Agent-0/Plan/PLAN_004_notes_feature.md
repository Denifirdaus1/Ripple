# PLAN_004: Implement Notes Feature with Rich Text & Mentions

**ID:** PLAN_004 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Terkait:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)
**Constraint:** Clean Architecture, Flutter Quill, Supabase JSONB

---

# Goal Description
Implement the **Notes** feature allowing users to create rich text content with support for **Hyperlinks/Mentions** to other system entities (Todos, Milestones).

## User Review Required
> [!IMPORTANT]
> **Rich Text Engine**:
> - We will use `flutter_quill` as the core editor.
> - Content is stored as **JSONB** in Supabase (`content` column), preserving formatting (Delta).
>
> **Mention System (@Linking)**:
> - Mentions (e.g., tagging a Todo) will use **Custom Embed Blocks** or **Attributes** in Quill.
> - **Backend Sync**: A dedicated `NoteRepository` logic will parse the JSON Delta upon saving to extract mentions and update the `note_mentions` table. This ensures the SQL relationship is always in sync with the Rich Text content.

---

## Proposed Changes

### 1. Domain Layer
#### [NEW] [lib/features/notes/domain/entities](file:///c:/Project/ripple/lib/features/notes/domain/entities/)
- `note.dart`: Entity with `Delta` (or Map/JSON) content, `title`, `milestoneId`.
- `note_mention.dart`: Entity representing a link between Note and Todo/Note.

#### [NEW] [lib/features/notes/domain/repositories](file:///c:/Project/ripple/lib/features/notes/domain/repositories/)
- `note_repository.dart`: Interface.
    - `getNotes()`: Stream of notes.
    - `saveNote(Note note)`: Saves note AND updates mentions.
    - `searchMentions(String query)`: Finds Todos/Notes for the @popup.

#### [NEW] [lib/features/notes/domain/usecases](file:///c:/Project/ripple/lib/features/notes/domain/usecases/)
- `manage_note.dart`: Save/Delete.
- `sync_mentions.dart`: Helper to extract mentions from Delta and sync DB.

### 2. Data Layer
#### [NEW] [lib/features/notes/data/models](file:///c:/Project/ripple/lib/features/notes/data/models/)
- `note_model.dart`: Maps Supabase JSONB to Dart Map/Delta.

#### [NEW] [lib/features/notes/data/repositories](file:///c:/Project/ripple/lib/features/notes/data/repositories/)
- `note_repository_impl.dart`:
    - Implements `saveNote`:
        1.  Upsert `notes` table.
        2.  Parse `Delta` to find Custom Embeds/Links with ID.
        3.  Diff detection (optional) or full replace in `note_mentions`.

### 3. Presentation Layer
#### [NEW] [lib/features/notes/presentation/bloc](file:///c:/Project/ripple/lib/features/notes/presentation/bloc/)
- `note_editor_bloc.dart`: Handles Editor state, Auto-save (debounce), and Mention searching.
- `note_list_bloc.dart`: Manages list view.

#### [NEW] [lib/features/notes/presentation/pages](file:///c:/Project/ripple/lib/features/notes/presentation/pages/)
- `note_editor_page.dart`: Full screen editor with `QuillEditor`.
- `note_list_page.dart`: Grid/List view of notes.

#### [NEW] [lib/features/notes/presentation/widgets/editor](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/editor/)
- `mention_overlay.dart`: Popup widget shown when typing '@'.
- `custom_embeds.dart`: Definitions for Todo/Milestone chips inside the text.

### 4. Dependency Injection
#### [MODIFY] [lib/injection_container.dart](file:///c:/Project/ripple/lib/injection_container.dart)
- Register Note dependencies.

---

## Verification Plan

### Automated Tests
```bash
flutter test test/features/notes/domain/usecases/sync_mentions_test.dart
```
- Test Delta Parsing: Create a Delta with 2 mentions. Verify `sync_mentions` returns correct list of IDs to insert.

### Manual Verification
1.  **Create Note**: Open Editor. Type "Discussing ".
2.  **Test Mention**: Type "@". Verify popup appears with list of Todos.
3.  **Insert Mention**: Select a Todo. Verify a Chip/Link appears in text.
4.  **Save & Verify**: Save note.
    - Check `notes` table: Content is JSON.
    - Check `note_mentions` table: Row exists linking NoteID -> TodoID.
5.  **Edit & Remove**: Delete the mention from text. Save.
    - Check `note_mentions` table: Row is deleted.
