# PLAN_031: Entity Properties Persistence (Efficient Sync)

**ID:** PLAN_031 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04

## 🎯 Tujuan

Memperbaiki persistence entity properties agar:
1. **Data tidak hilang** saat user uninstall/logout
2. **Tidak boros API call** ke server
3. **User experience tetap responsive**

---

## 📊 Research Findings

### Problem Statement
- `extraEnabledProperties` hanya di memory (cubit state)
- Saat kembali ke note editor, state reset ke default
- User harus add property lagi

### Solusi yang Diteliti

| Approach | Pros | Cons |
|----------|------|------|
| **A. Sync on every change** | Real-time | Boros API, lag UI |
| **B. Sync on app pause** | Batch save, efficient | Delay sync |
| **C. Derive from data** | Zero extra API | Empty properties lost |
| **D. Hybrid: Store in Note entity** | Minimal change | Need DB migration |

### ✅ Recommended: Approach D (Store in Note Entity)

Simpan `enabled_properties` langsung di Note entity sebagai JSON array di kolom baru. 

**Advantages:**
- Satu API call saat save note (sudah ada)
- Persist to database automatically
- No extra table needed
- Survives uninstall/logout

---

## 🛠️ Strategi Implementasi

### Phase 1: Database Migration
- [ ] Add column `enabled_properties TEXT[]` to `notes` table
- [ ] Default value: `['date']`

### Phase 2: Update Note Entity & Model
- [ ] Add `enabledProperties` field to `Note` entity
- [ ] Update `NoteModel.fromJson()` and `toJson()`
- [ ] Update `Note.copyWith()`

### Phase 3: Update NoteEditorCubit
- [ ] Remove `extraEnabledProperties` from state (computed → stored)
- [ ] Store `enabledPropertyIds` in note entity
- [ ] On `enableProperty()`, update note.enabledProperties

### Phase 4: Auto-persist on Note Save
- [ ] `enabledPropertyIds` saved with note automatically
- [ ] No extra API call needed

---

## 📝 Technical Details

### Database Change
```sql
ALTER TABLE notes 
ADD COLUMN enabled_properties TEXT[] DEFAULT ARRAY['date']::TEXT[];
```

### Note Entity Update
```dart
class Note extends Equatable {
  // ... existing fields ...
  final List<String> enabledProperties; // NEW
  
  const Note({
    // ...
    this.enabledProperties = const ['date'],
  });
}
```

### NoteModel Update
```dart
factory NoteModel.fromJson(Map<String, dynamic> json) {
  return NoteModel(
    // ... existing ...
    enabledProperties: (json['enabled_properties'] as List?)
        ?.map((e) => e.toString()).toList() 
        ?? ['date'],
  );
}

Map<String, dynamic> toJson() {
  return {
    // ... existing ...
    'enabled_properties': enabledProperties,
  };
}
```

### Cubit Simplification
```dart
// Before (complex)
final Set<String> extraEnabledProperties;
List<String> get enabledPropertyIds => computed...

// After (simple)
void enableProperty(String propertyId) {
  if (state.note.enabledProperties.contains(propertyId)) return;
  emit(state.copyWith(
    note: state.note.copyWith(
      enabledProperties: [...state.note.enabledProperties, propertyId],
    ),
  ));
}
```

---

## ✅ Kriteria Sukses

1. Notes dengan custom properties tersimpan ke database
2. Setelah uninstall & install ulang, properties masih ada
3. **0 extra API calls** - properties saved with note save
4. `flutter analyze` → 0 errors

---

## 🧪 Verification Plan

### Automated Tests
```bash
flutter analyze
flutter test test/features/notes/
```

### Manual Testing
1. Buat note baru
2. Add property "Tags" dan "Priority"
3. Navigate away dan kembali → Properties masih ada ✅
4. Kill app dan buka lagi → Properties masih ada ✅
5. Uninstall & install ulang → Login → Properties masih ada ✅

---

## 🔗 Terkait
- [PLAN_030](PLAN_030_property_sandbox_system.md) - Property Sandbox System
- [PLAN_029](PLAN_029_reusable_property_system.md) - Reusable Property Library
