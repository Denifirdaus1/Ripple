# PLAN_033: Notes Status & Description Properties

**ID:** PLAN_033 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05

## 🎯 Tujuan

Mengintegrasikan properti **Status** dan **Description** ke Notes dengan:
1. Penyimpanan di database (Supabase)
2. UI Editor di `NotePropertiesSection`
3. Tampilan di `NoteCard`
4. Status dengan 3 opsi dan warna referensi:
   - 🔘 **Belum Dimulai** (Not Started) - Abu-abu
   - 🔵 **Sedang Berjalan** (In Progress) - Biru
   - 🟢 **Selesai** (Done) - Hijau

## 📸 Reference

![Status Colors](uploaded_image_1767589902214.png)

| Status | ID | Label (ID) | Label (EN) | Color |
|--------|-----|------------|------------|-------|
| Not Started | `not_started` | Belum Dimulai | Not Started | Gray `#6B7280` |
| In Progress | `in_progress` | Sedang Berjalan | In Progress | Blue `#3B82F6` |
| Done | `done` | Selesai | Done | Green `#10B981` |

---

## 🛠️ Strategi Implementasi

### Phase 1: Database Migration (Supabase MCP)
- [ ] Add `status TEXT` column to `notes` table
- [ ] Add `description TEXT` column to `notes` table
- [ ] Allowed values: `not_started`, `in_progress`, `done`

### Phase 2: Update Note Entity & Model
- [ ] Add `NoteStatus` enum to `note.dart`
- [ ] Add `status` and `description` fields to `Note` entity
- [ ] Update `NoteModel.fromJson` dan `toJson`
- [ ] Update `copyWith` method

### Phase 3: Update PropertyRegistry (Status Options)
- [ ] Update `DefaultProperties.status` dari `checkbox` ke `select`
- [ ] Tambahkan 3 options: not_started, in_progress, done

### Phase 4: Update NoteEditorCubit
- [ ] Add methods: `updateStatus()`, `updateDescription()`
- [ ] Wire ke auto-save

### Phase 5: Update NotePropertiesSection
- [ ] Add UI untuk Status (dropdown selector)
- [ ] Add UI untuk Description (text field)

### Phase 6: Update NoteCard Display
- [ ] Show Status chip di row bawah (dengan dot indicator)
- [ ] Show Description preview di samping icon (max ~40 chars)

---

## 📝 Technical Details

### NoteStatus Enum
```dart
enum NoteStatus {
  notStarted,  // Belum Dimulai
  inProgress,  // Sedang Berjalan
  done,        // Selesai
}
```

### Status Chip Design (dari referensi)
```dart
// Color scheme from reference image
static const statusColors = {
  'not_started': Color(0xFF6B7280), // Gray
  'in_progress': Color(0xFF3B82F6), // Blue
  'done': Color(0xFF10B981),        // Green
};
```

### NoteCard Layout Update
```
┌──────────────────────────────┐
│  ┌────┐  Description preview │
│  │ 📝 │  (max 40 chars...)   │
│  └────┘                      │
│  Title Note                  │
│  📅 24 Jan │ 🏷️ Tag │ 🟢 Done│
└──────────────────────────────┘
```

---

## ✅ Kriteria Sukses

1. `flutter analyze` → 0 errors
2. Status dan Description tersimpan di database
3. Muncul di NoteCard dengan design sesuai referensi
4. Properti bisa di-enable/disable via sandbox

---

## 🧪 Verification Plan

### Automated
```bash
flutter analyze
flutter test test/features/notes/
```

### Manual Testing
1. Buka Note Editor → Tambah properti Status → Pilih status → Check database
2. Buka Note Editor → Tambah properti Description → Isi text → Check database
3. Kembali ke Notes List → Verify Status chip muncul dengan warna benar
4. Verify Description preview muncul di samping icon

---

## 🔗 Terkait
- [PLAN_029](PLAN_029_reusable_property_system.md) - Property System
- [PLAN_030](PLAN_030_property_sandbox_system.md) - Sandbox System
- [PLAN_031](PLAN_031_entity_properties_persistence.md) - Properties Persistence
