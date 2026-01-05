# Universal Folder System untuk Notes & Todos

**ID:** TOPIC_004 | **Status:** ✅ Decided | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05
**Tipe:** 📄 Simple

## Deskripsi
Diskusi tentang implementasi sistem folder universal yang dapat menampung berbagai jenis entity (Notes, Todos) dalam satu struktur hierarki. Tujuannya adalah memberikan user kemampuan untuk mengorganisir kontennya dalam folder/workspace yang fleksibel.

---

## ✅ Keputusan Final

### Q1: Hierarchy Depth (Nested Folders?)
**Jawaban: YA, dengan batasan UI/Logic**
- Di database: `parent_folder_id` (Recursive Adjacency List)
- Di Flutter: Recursive Tree View
- ⚠️ **Warning**: Perlu check constraint untuk mencegah circular dependency (A→B→A)

### Q2: Default Folder?
**Jawaban: YA (Inbox / Uncategorized)**
- Item tanpa folder tampil di "Inbox" 
- Di database: `folder_id` bisa NULL
- Mencegah items "hilang" saat user quick capture

### Q3: Folder per Feature vs Shared?
**Jawaban: SHARED (Universal)**
- Notes dan Todos dalam folder yang sama
- Use case: Folder "Renovasi Rumah" berisi List Belanja (Todos) + Ide Desain (Notes)
- Tidak perlu pindah-pindah tab

### Q4: Milestone Relationship?
**Jawaban: Option 2 - Parallel (Terpisah)**
- **Folder** = Tempat Penyimpanan (Storage/Context) — Kantor, Rumah, Ide Skripsi
- **Milestone/Goal** = Waktu & Pencapaian (Time/Achievement) — Q1 Target, Launch MVP
- Matriks 2D: Note "Draft Kontrak" → Folder "Legal" + Milestone "Launching MVP"

### Q5: UI/UX?
**Jawaban: Sidebar Tree (Collapsible)**
- Standar industri (VS Code, Notion, Slack)
- Tab-based kurang cocok untuk hierarki dalam

---

## � Final Database Schema

### Pattern A: Junction Table with Entity Type (Selected)

```sql
-- ============================================
-- FOLDERS TABLE
-- ============================================
CREATE TABLE folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(name) >= 1),
  parent_folder_id UUID REFERENCES folders(id) ON DELETE CASCADE,
  icon TEXT,
  color TEXT,
  order_index INTEGER DEFAULT 0,
  is_system BOOLEAN DEFAULT FALSE,  -- For system folders like "Inbox"
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Prevent circular dependency (basic check - deeper validation in app layer)
ALTER TABLE folders ADD CONSTRAINT no_self_parent CHECK (id != parent_folder_id);

-- Indexes
CREATE INDEX idx_folders_user ON folders(user_id);
CREATE INDEX idx_folders_parent ON folders(parent_folder_id);

-- RLS
ALTER TABLE folders ENABLE ROW LEVEL SECURITY;
CREATE POLICY folders_user_policy ON folders 
  USING (auth.uid() = user_id);

-- ============================================
-- FOLDER ITEMS TABLE (Junction)
-- ============================================
CREATE TABLE folder_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id UUID NOT NULL REFERENCES folders(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('note', 'todo')),
  entity_id UUID NOT NULL,
  order_index INTEGER DEFAULT 0,
  added_at TIMESTAMPTZ DEFAULT now(),
  
  -- Unique constraint: same entity can't be in same folder twice
  UNIQUE(folder_id, entity_type, entity_id)
);

-- Indexes for performance
CREATE INDEX idx_folder_items_folder ON folder_items(folder_id);
CREATE INDEX idx_folder_items_entity ON folder_items(entity_type, entity_id);
CREATE INDEX idx_folder_items_lookup ON folder_items(folder_id, added_at DESC);

-- RLS (inherit from folder ownership)
ALTER TABLE folder_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY folder_items_user_policy ON folder_items 
  USING (
    folder_id IN (SELECT id FROM folders WHERE user_id = auth.uid())
  );
```

### Query Strategy (Performance)

```sql
-- Get all items in a folder (sorted by order, then newest first)
SELECT 
  fi.entity_type,
  fi.entity_id,
  fi.order_index,
  fi.added_at,
  CASE 
    WHEN fi.entity_type = 'note' THEN n.title
    WHEN fi.entity_type = 'todo' THEN t.title
  END as title
FROM folder_items fi
LEFT JOIN notes n ON fi.entity_type = 'note' AND fi.entity_id = n.id
LEFT JOIN todos t ON fi.entity_type = 'todo' AND fi.entity_id = t.id
WHERE fi.folder_id = $1
ORDER BY fi.order_index, fi.added_at DESC;

-- Get folder tree for user (recursive CTE)
WITH RECURSIVE folder_tree AS (
  -- Root folders (no parent)
  SELECT id, name, parent_folder_id, icon, color, order_index, 0 as depth
  FROM folders
  WHERE user_id = $1 AND parent_folder_id IS NULL
  
  UNION ALL
  
  -- Child folders
  SELECT f.id, f.name, f.parent_folder_id, f.icon, f.color, f.order_index, ft.depth + 1
  FROM folders f
  INNER JOIN folder_tree ft ON f.parent_folder_id = ft.id
  WHERE ft.depth < 10  -- Max depth limit
)
SELECT * FROM folder_tree ORDER BY depth, order_index;

-- "Inbox" items (items without any folder)
SELECT 'note' as entity_type, n.id, n.title, n.created_at
FROM notes n
WHERE n.user_id = $1
  AND n.id NOT IN (SELECT entity_id FROM folder_items WHERE entity_type = 'note')
UNION ALL
SELECT 'todo' as entity_type, t.id, t.title, t.created_at
FROM todos t
WHERE t.user_id = $1
  AND t.id NOT IN (SELECT entity_id FROM folder_items WHERE entity_type = 'todo');
```

---

## 🏗️ Implementation Phases

### Phase 1: Database Schema
- [ ] Create `folders` table
- [ ] Create `folder_items` table
- [ ] Add indexes and RLS policies

### Phase 2: Domain Layer
- [ ] Create `Folder` entity
- [ ] Create `FolderItem` entity
- [ ] Create `FolderRepository` interface

### Phase 3: Data Layer
- [ ] Implement `FolderRepositoryImpl`
- [ ] Create `FolderModel` with JSON serialization

### Phase 4: Presentation Layer
- [ ] Create `FolderBloc`
- [ ] Create Folder Tree Widget (collapsible sidebar)
- [ ] Add folder selection to Note/Todo editors

### Phase 5: UI Integration
- [ ] Add folder sidebar to main shell
- [ ] Implement drag & drop for items
- [ ] Add folder CRUD UI (create, rename, delete, move)

---

## Poin Penting
- ✅ Pattern A (Junction Table) selected
- ✅ Nested folders with circular dependency prevention
- ✅ Shared folders for Notes & Todos
- ✅ Parallel to Milestone system (2D organization)
- ✅ Sidebar Tree UI (collapsible)

## Terkait
Find: - | Plan: PLAN_036 (To be created)
