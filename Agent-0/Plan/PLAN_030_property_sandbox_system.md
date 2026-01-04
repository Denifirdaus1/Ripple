# PLAN_030: Property Sandbox System

**ID:** PLAN_030 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04

## 🎯 Tujuan

Membuat sistem property yang bersifat "sandbox" dimana:
1. **Default Property Minimal**: Notes hanya memiliki "Tanggal" sebagai default property
2. **Add Property Manual**: Property lain (Tags, Priority) ditambahkan manual via tombol "Add Property"
3. **User-owned Options**: Setiap user memiliki daftar options sendiri untuk Tags dan Priority
4. **Starter Defaults**: User baru mendapat starter options yang sudah tersedia

---

## 📊 Database Schema Design

### Tabel `user_property_options`

Menyimpan options yang dimiliki user untuk select/multiSelect properties.

```sql
CREATE TABLE user_property_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  property_id TEXT NOT NULL,           -- 'tags', 'priority', dll
  option_id TEXT NOT NULL,             -- unique identifier dalam property
  label TEXT NOT NULL,                 -- display label
  color TEXT,                          -- hex color (optional)
  icon TEXT,                           -- icon name (optional)
  order_index INT DEFAULT 0,
  is_default BOOLEAN DEFAULT false,    -- starter option
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  UNIQUE(user_id, property_id, option_id)
);

-- Index untuk performance
CREATE INDEX idx_user_property_options_user ON user_property_options(user_id);
CREATE INDEX idx_user_property_options_property ON user_property_options(user_id, property_id);
```

### Tabel `entity_properties`

Menyimpan property yang aktif pada entity (note, todo, dll).

```sql
CREATE TABLE entity_properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL,           -- 'note', 'todo', 'milestone'
  entity_id UUID NOT NULL,             -- ID of the entity
  property_id TEXT NOT NULL,           -- 'date', 'tags', 'priority'
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  
  UNIQUE(entity_type, entity_id, property_id)
);

-- Index untuk performance
CREATE INDEX idx_entity_properties_entity ON entity_properties(entity_type, entity_id);
```

### Starter Options

```sql
-- Function untuk seed starter options saat user register
CREATE OR REPLACE FUNCTION seed_user_property_options()
RETURNS TRIGGER AS $$
BEGIN
  -- Seed Tags
  INSERT INTO user_property_options (user_id, property_id, option_id, label, color, order_index, is_default)
  VALUES
    (NEW.id, 'tags', 'pengingat', 'Pengingat', '#3B82F6', 1, true),
    (NEW.id, 'tags', 'personal', 'Personal', '#22C55E', 2, true),
    (NEW.id, 'tags', 'kerja', 'Kerja', '#F59E0B', 3, true),
    (NEW.id, 'tags', 'ide', 'Ide', '#A855F7', 4, true);
    
  -- Seed Priority
  INSERT INTO user_property_options (user_id, property_id, option_id, label, color, order_index, is_default)
  VALUES
    (NEW.id, 'priority', 'high', 'Penting', '#EF4444', 1, true),
    (NEW.id, 'priority', 'medium', 'Sedang', '#F97316', 2, true),
    (NEW.id, 'priority', 'low', 'Rendah', '#3B82F6', 3, true);
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION seed_user_property_options();
```

---

## 🏗️ Architecture Changes

### New Files

```
lib/core/properties/
├── data/
│   ├── models/
│   │   └── user_property_option_model.dart
│   ├── datasources/
│   │   └── property_remote_datasource.dart
│   └── repositories/
│       └── property_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_property_option.dart
│   ├── repositories/
│   │   └── property_repository.dart
│   └── usecases/
│       ├── get_user_options.dart
│       ├── create_option.dart
│       ├── update_option.dart
│       └── delete_option.dart
└── presentation/
    ├── bloc/
    │   └── property_options_cubit.dart
    └── widgets/
        ├── add_property_sheet.dart      # Bottom sheet to add property
        └── manage_options_sheet.dart    # Manage tags/priorities
```

---

## 🛠️ Strategi Implementasi

### Phase 1: Database Schema
- [ ] Create `user_property_options` table via Supabase migration
- [ ] Create `entity_properties` table via Supabase migration
- [ ] Create trigger for seeding starter options
- [ ] Add RLS policies

### Phase 2: Domain Layer
- [ ] Create `UserPropertyOption` entity
- [ ] Create `PropertyRepository` interface
- [ ] Create use cases (GetUserOptions, CreateOption, etc.)

### Phase 3: Data Layer
- [ ] Create `UserPropertyOptionModel`
- [ ] Create `PropertyRemoteDataSource`
- [ ] Create `PropertyRepositoryImpl`

### Phase 4: Presentation Layer
- [ ] Create `PropertyOptionsCubit` for state management
- [ ] Create `AddPropertySheet` widget
- [ ] Create `ManageOptionsSheet` widget
- [ ] Update `NotePropertiesSection` to support dynamic properties

### Phase 5: Notes Integration
- [ ] Modify Notes to only show "Date" by default
- [ ] Implement "Add Property" flow
- [ ] Connect to user-owned options for Tags/Priority

---

## 🎨 UX Flow

### Add Property Flow
```
1. User taps "Tambah Properti" button
2. Bottom sheet shows available properties:
   - 📅 Tanggal (already added - disabled)
   - 🏷️ Tag
   - 🚩 Prioritas
   - 📝 Deskripsi
   - [Custom...] (future)
3. User taps "Tag"
4. Property added to note, shows in properties list
```

### Manage Options Flow
```
1. User taps Tag property row
2. Bottom sheet shows:
   - Current selected tags (checkboxes)
   - "Kelola Tag" button
3. User taps "Kelola Tag"
4. New sheet shows:
   - List of user's tags with edit/delete
   - "Tambah Tag Baru" button
```

---

## ✅ Kriteria Sukses

1. User baru dengan starter options (4 tags, 3 priorities)
2. User dapat menambah property ke note via "Add Property"
3. User dapat create/edit/delete custom tags
4. User dapat create/edit/delete custom priorities
5. Each user's data isolated (RLS)
6. `flutter analyze` → 0 errors

---

## 🧪 Verification Plan

### Automated Tests
```bash
flutter analyze
flutter test test/core/properties/
```

### Manual Testing
1. **New User Flow:**
   - Login dengan akun baru
   - Cek di database: user_property_options ada 7 rows (4 tags, 3 priorities)

2. **Add Property Flow:**
   - Buat note baru
   - Verify hanya "Tanggal" yang muncul
   - Tap "Tambah Properti" → pilih "Tag"
   - Verify Tag property muncul

3. **Manage Options Flow:**
   - Tap Tag property
   - Tap "Kelola Tag"
   - Tambah tag baru "Custom Tag"
   - Verify muncul di list

---

## 🔗 Terkait
- [PLAN_029](PLAN_029_reusable_property_system.md) - Reusable Property Library
- [PLAN_024](PLAN_024_ui_refinement_tags.md) - Tags Implementation
