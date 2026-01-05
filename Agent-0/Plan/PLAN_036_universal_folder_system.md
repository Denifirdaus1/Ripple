# PLAN_036: Universal Folder System Implementation

**ID:** PLAN_036 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05

## 🎯 Tujuan
Implementasi sistem folder universal yang dapat menampung Notes dan Todos dalam hierarki nested. Menggunakan Pattern A (Junction Table) dengan sidebar tree UI collapsible.

## 📐 Keputusan Design (dari TOPIC_004)
- ✅ Nested folders dengan circular dependency prevention
- ✅ Shared folders (Notes & Todos dalam folder sama)
- ✅ Parallel ke Milestone (2D organization)
- ✅ "Inbox" untuk items tanpa folder
- ✅ Sidebar Tree UI (collapsible)

---

## 🛠️ Strategi Implementasi

### Phase 1: Database Schema (Supabase)

#### 1.1 Create `folders` Table
```sql
CREATE TABLE folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1),
  parent_folder_id UUID REFERENCES folders(id) ON DELETE CASCADE,
  icon TEXT,
  color TEXT,
  order_index INTEGER DEFAULT 0,
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE folders ADD CONSTRAINT no_self_parent CHECK (id != parent_folder_id);
CREATE INDEX idx_folders_user ON folders(user_id);
CREATE INDEX idx_folders_parent ON folders(parent_folder_id);

ALTER TABLE folders ENABLE ROW LEVEL SECURITY;
CREATE POLICY folders_all ON folders FOR ALL USING (auth.uid() = user_id);
```

#### 1.2 Create `folder_items` Table
```sql
CREATE TABLE folder_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id UUID NOT NULL REFERENCES folders(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('note', 'todo')),
  entity_id UUID NOT NULL,
  order_index INTEGER DEFAULT 0,
  added_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(folder_id, entity_type, entity_id)
);

CREATE INDEX idx_folder_items_folder ON folder_items(folder_id);
CREATE INDEX idx_folder_items_entity ON folder_items(entity_type, entity_id);
CREATE INDEX idx_folder_items_lookup ON folder_items(folder_id, added_at DESC);

ALTER TABLE folder_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY folder_items_all ON folder_items FOR ALL 
  USING (folder_id IN (SELECT id FROM folders WHERE user_id = auth.uid()));
```

**Tasks:**
- [ ] Apply migration via Supabase MCP
- [ ] Verify tables created
- [ ] Test RLS policies

---

### Phase 2: Domain Layer (lib/features/folder/domain/)

#### 2.1 Entities
- [ ] `Folder` entity (`id`, `userId`, `name`, `parentFolderId`, `icon`, `color`, `orderIndex`, `isSystem`, `createdAt`, `updatedAt`)
- [ ] `FolderItem` entity (`id`, `folderId`, `entityType`, `entityId`, `orderIndex`, `addedAt`)

#### 2.2 Repository Interface
- [ ] `FolderRepository` interface:
  - `getFoldersStream()` → Stream<List<Folder>>
  - `getFolderContents(folderId)` → Future<FolderContents> (Notes + Todos hydrated)
  - `getInboxContents()` → Future<FolderContents> (items tanpa folder)
  - `createFolder(Folder)` → Future<Folder>
  - `updateFolder(Folder)` → Future<Folder>
  - `deleteFolder(folderId)` → Future<void>
  - `addItemToFolder(folderId, entityType, entityId)` → Future<FolderItem>
  - `removeItemFromFolder(folderId, entityType, entityId)` → Future<void>
  - `moveFolder(folderId, newParentId)` → Future<void>

#### 2.3 Value Objects
- [ ] `FolderContents` - Contains `List<Note>` + `List<Todo>` (hydrated entities, not just IDs)

#### 2.4 Use Cases
- [ ] `GetFoldersStream`
- [ ] `GetFolderContents`
- [ ] `GetInboxContents`
- [ ] `CreateFolder`
- [ ] `UpdateFolder`
- [ ] `DeleteFolder`
- [ ] `AddItemToFolder`
- [ ] `RemoveItemFromFolder`
- [ ] `MoveFolder`

---

### Phase 3: Data Layer (lib/features/folder/data/)

#### 3.1 Models
- [ ] `FolderModel` with `fromJson()`, `toJson()`, `fromEntity()`
- [ ] `FolderItemModel` with `fromJson()`, `toJson()`, `fromEntity()`

#### 3.2 Repository Implementation
- [ ] `FolderRepositoryImpl` implementing `FolderRepository`
- [ ] Supabase stream for real-time folder updates
- [ ] Recursive query for folder tree

> ⚠️ **IMPORTANT: N+1 Query Prevention**
>
> `FolderItem` hanya berisi `entity_id` dan `entity_type`. Untuk menghindari 50 requests individual:
>
> **Batch Fetching Strategy:**
> 1. Fetch semua `folder_items` untuk folder
> 2. Pisahkan IDs: `noteIds` dan `todoIds`
> 3. Lakukan 2 batch queries:
>    - `SELECT * FROM notes WHERE id IN (noteIds)`
>    - `SELECT * FROM todos WHERE id IN (todoIds)`
> 4. Gabungkan hasil di memori (Dart) dan return `FolderContents`

> ⚠️ **IMPORTANT: Inbox Definition**
>
> "Inbox" bukan folder fisik di database! Inbox = items yang **TIDAK ADA** di `folder_items`.
>
> **Anti-Join Query untuk Inbox:**
> ```sql
> -- Notes tanpa folder
> SELECT * FROM notes 
> WHERE user_id = $1
>   AND id NOT IN (SELECT entity_id FROM folder_items WHERE entity_type = 'note');
>
> -- Todos tanpa folder  
> SELECT * FROM todos
> WHERE user_id = $1
>   AND id NOT IN (SELECT entity_id FROM folder_items WHERE entity_type = 'todo');
> ```

---

### Phase 4: Presentation Layer (lib/features/folder/presentation/)

#### 4.1 BLoC
- [ ] `FolderBloc` with events:
  - `FolderSubscriptionRequested`
  - `FolderCreated`
  - `FolderUpdated`
  - `FolderDeleted`
  - `FolderItemAdded`
  - `FolderItemRemoved`
  - `FolderMoved`
  - `FolderClearRequested`

#### 4.2 Widgets
- [ ] `FolderTreeWidget` - Collapsible tree view
- [ ] `FolderTile` - Individual folder row
- [ ] `FolderItemTile` - Note/Todo item in folder
- [ ] `CreateFolderDialog`
- [ ] `FolderContextMenu` - Right-click/long-press menu

---

### Phase 5: UI Integration

#### 5.1 Main Shell
- [ ] Add folder sidebar to `MainShell`
- [ ] Toggle sidebar button
- [ ] Responsive: drawer on mobile, panel on desktop

#### 5.2 Note/Todo Editors
- [ ] Add "Move to folder" option in editors
- [ ] Show current folder in header

#### 5.3 Drag & Drop (Future)
- [ ] Drag items between folders
- [ ] Drag folders to reorder/nest

---

### Phase 6: Dependency Injection

- [ ] Register `FolderRepository`
- [ ] Register `FolderBloc` (singleton like NoteBloc)
- [ ] Register use cases
- [ ] Add to `MultiBlocProvider` in `app.dart`

---

## ✅ Kriteria Sukses

### Functionality
- [ ] User dapat create folder dengan nama dan warna
- [ ] User dapat create nested folder (max 10 levels)
- [ ] User dapat add Note/Todo ke folder
- [ ] User dapat lihat items dalam folder
- [ ] "Inbox" menampilkan items tanpa folder
- [ ] Delete folder → items kembali ke Inbox (tidak hapus entity)

### Performance
- [ ] Folder tree loads dalam < 500ms
- [ ] Real-time sync saat folder/items berubah

### UI/UX
- [ ] Sidebar collapsible
- [ ] Expand/collapse folder smooth
- [ ] Visual indicator untuk folder dengan items vs empty

### Code Quality
- [ ] `flutter analyze` → 0 errors
- [ ] Clean architecture maintained

---

## 📊 Estimasi Effort

| Phase | Effort | Priority |
|-------|--------|----------|
| Phase 1: Database | 🟢 Low | 1st |
| Phase 2: Domain | 🟡 Medium | 2nd |
| Phase 3: Data | 🟡 Medium | 3rd |
| Phase 4: Presentation | 🟠 High | 4th |
| Phase 5: UI Integration | 🟠 High | 5th |
| Phase 6: DI | 🟢 Low | 6th |

**Total Estimate:** 2-3 development sessions

---

## 🔗 Terkait
Topic: [TOPIC_004](../Topic/TOPIC_004_universal_folder_system.md) - Universal Folder System
Find: -
