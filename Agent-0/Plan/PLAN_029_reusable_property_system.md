# PLAN_029: Reusable Property Library System

**ID:** PLAN_029 | **Status:**  In Progress | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04

## 🎯 Tujuan
1. Membuat sistem property yang reusable dan extensible
2. Property dapat digunakan di Notes, Todos, Milestones, dan entity lainnya
3. User dapat menambah custom property baru di masa depan
4. UI widgets otomatis ter-generate berdasarkan property type

---

## 📊 Research Findings

### Current State Analysis

| Entity | Properties | Status |
|--------|-----------|--------|
| **Note** | date, tags, priority | Hardcoded in `NotePropertiesSection` |
| **Todo** | priority, scheduledDate, startTime, endTime, tags | Hardcoded in entity |
| **Milestone** | targetDate, notes | Hardcoded in entity |

### Common Properties Identified
- **Date/DateTime**: `noteDate`, `scheduledDate`, `targetDate`
- **Priority**: `NotePriority`, `TodoPriority`
- **Tags**: `List<String> tags`
- **Text**: `description`, `notes`
- **Number**: `focusDurationMinutes`, `reminderMinutes`
- **Boolean**: `isCompleted`, `focusEnabled`

### Design Pattern: Entity-Attribute-Value (EAV) + Hybrid

```
┌─────────────────────────────────────────────────────────────┐
│                    PropertyDefinition                        │
│  - id: String                                                │
│  - name: String (e.g., "Due Date", "Priority")              │
│  - type: PropertyType (date, text, select, multiSelect...)  │
│  - icon: IconData                                            │
│  - options: List<PropertyOption>? (for select types)        │
│  - defaultValue: dynamic?                                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      PropertyValue                           │
│  - propertyId: String (ref to PropertyDefinition)           │
│  - value: dynamic                                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              PropertyAwareEntity (mixin)                     │
│  - properties: Map<String, PropertyValue>                   │
│  - getProperty(String key): dynamic                         │
│  - setProperty(String key, dynamic value): void             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🏗️ Architecture

### Core Library Structure
```
lib/core/properties/
├── domain/
│   ├── entities/
│   │   ├── property_definition.dart    # Property type definition
│   │   ├── property_value.dart         # Actual value holder
│   │   └── property_type.dart          # Enum of property types
│   └── repositories/
│       └── property_repository.dart    # CRUD for definitions
├── data/
│   ├── models/
│   │   ├── property_definition_model.dart
│   │   └── property_value_model.dart
│   └── repositories/
│       └── property_repository_impl.dart
└── presentation/
    ├── widgets/
    │   ├── property_row.dart           # Single property row UI
    │   ├── property_section.dart       # List of properties
    │   ├── property_editor.dart        # Edit property value
    │   └── property_type_widgets/
    │       ├── date_property_widget.dart
    │       ├── select_property_widget.dart
    │       ├── multi_select_property_widget.dart
    │       ├── text_property_widget.dart
    │       └── number_property_widget.dart
    └── bloc/
        └── property_cubit.dart         # State management
```

### Property Types Supported
| Type | UI Widget | Value Type |
|------|----------|------------|
| `text` | TextField | `String` |
| `number` | NumberField | `int/double` |
| `date` | DatePicker | `DateTime?` |
| `datetime` | DateTimePicker | `DateTime?` |
| `select` | Dropdown/BottomSheet | `String` |
| `multiSelect` | Chips/BottomSheet | `List<String>` |
| `checkbox` | Checkbox | `bool` |
| `url` | TextField + Validator | `String` |
| `email` | TextField + Validator | `String` |
| `phone` | TextField + Validator | `String` |

---

## 🛠️ Strategi Implementasi

### Phase 1: Core Entities & Types ✅
- [x] Create `PropertyType` enum
- [x] Create `PropertyDefinition` entity
- [x] Create `PropertyValue` entity
- [x] Create `PropertyOption` for select types

### Phase 2: Default Property Library ✅
- [x] Create predefined properties: Date, Priority, Tags, Status
- [x] Create `PropertyRegistry` singleton for managing definitions
- [x] Load default properties on app start

### Phase 3: UI Widgets ✅
- [x] Create base `PropertyRow` widget
- [x] Create `PropertySection` (list of PropertyRow)
- [x] Create type-specific editors (DatePropertyWidget, etc.)
- [x] Create `AddPropertyButton` for adding new properties

### Phase 4: Integration with Notes ✅
- [x] Migrate `NotePropertiesSection` to use new system
- [x] Update Note entity to use property system
- [x] Ensure backward compatibility

### Phase 5: Database Schema (Optional - for custom properties)
- [ ] Create `property_definitions` table for custom properties
- [ ] Create `entity_properties` table for property values
- [ ] Add RLS policies

---

## 📁 Files to Create

### [NEW] Core Property System
- `lib/core/properties/domain/entities/property_type.dart`
- `lib/core/properties/domain/entities/property_definition.dart`
- `lib/core/properties/domain/entities/property_value.dart`
- `lib/core/properties/domain/entities/property_option.dart`
- `lib/core/properties/presentation/widgets/property_row.dart`
- `lib/core/properties/presentation/widgets/property_section.dart`
- `lib/core/properties/presentation/widgets/property_editors/*.dart`
- `lib/core/properties/property_registry.dart`

### [MODIFY] Notes Integration
- `lib/features/notes/presentation/widgets/note_properties_section.dart`
- `lib/features/notes/domain/entities/note.dart`

---

## ✅ Kriteria Sukses
1. Property system berdiri sendiri di `lib/core/properties/` ✅
2. Notes menggunakan property system baru ✅
3. Easily extendable - dapat menambah property type baru ✅
4. UI otomatis ter-generate berdasarkan property type ✅

---

## 🧪 Verification Plan

### Static Analysis
```bash
flutter analyze
```

### Manual Testing
1. **Test di Note Editor:**
   - Buka note editor
   - Verify property section tampil dengan benar
   - Edit date, tags, priority
   - Verify perubahan tersimpan

2. **Test Extensibility:**
   - Coba tambah property definition baru di code
   - Verify UI otomatis ter-generate

---

## ⚠️ Complexity Warning

> [!WARNING]
> Ini adalah refactoring besar yang akan mempengaruhi banyak file. 
> Disarankan untuk implementasi bertahap dan testing menyeluruh.

---

## 🔗 Terkait
- [PLAN_024](PLAN_024_ui_refinement_tags.md) - UI Refinements & Tags
- [PLAN_028](PLAN_028_notes_image_upload.md) - Image Upload
