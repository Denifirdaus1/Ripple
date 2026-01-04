# PLAN_025: Note Card UI Fix & Data Sync Verification

**ID:** PLAN_025 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-04 | **Update:** 2026-01-04
**Terkait:** [PLAN_024](PLAN_024_ui_refinement_tags.md)

## 🎯 Tujuan
1. Fix NoteCard UI agar semua icon sama (notes icon)
2. Perbaiki tampilan priority agar sama seperti tag (chip dengan background)
3. Verifikasi bahwa semua data yang diedit di note editor tersimpan ke database

## 📊 Analisis Current State

### NoteCard Issues (dari screenshot):
- Icon berbeda-beda (ada yang 📄, ada yang 📌)
- Priority hanya tampil sebagai `!` kecil, bukan sebagai chip seperti tag

### Data Sync Verification:
Field yang di-edit di editor vs yang tersimpan ke DB:

| Field | Editor | NoteModel.toJson() | Status |
|-------|--------|-------------------|--------|
| title | ✅ TextField | ✅ `'title': title` | ✅ Synced |
| content | ✅ QuillEditor | ✅ `'content': content` | ✅ Synced |
| note_date | ✅ DatePicker | ✅ `'note_date': noteDate` | ✅ Synced |
| tags | ✅ TagSelectorSheet | ✅ `'tags': tags` | ✅ Synced |
| priority | ✅ PriorityPicker | ✅ `'priority': priority` | ✅ Synced |

**Kesimpulan:** Semua field sudah di-serialize dengan benar ke database.

## 🛠️ Strategi Implementasi

### Phase 1: Fix NoteCard Icons
- [ ] Ubah `_getNoteIcon()` untuk selalu return icon yang sama (`Icons.description_outlined`)
- [ ] Hapus conditional logic berdasarkan priority

### Phase 2: Fix Priority Display  
- [ ] Ubah `_PriorityBadge` menjadi chip dengan full text seperti `_TagBadge`
- [ ] Tampilkan text "Penting", "Sedang", "Rendah" dengan background color

### Phase 3: Verify Data Sync (Optional)
- [ ] Test manual: Edit semua property → Save → Close → Reopen → Verify data loaded

## 📁 Files Affected

#### [MODIFY] [note_card.dart](file:///c:/Project/ripple/lib/features/notes/presentation/widgets/note_card.dart)
- Fix `_getNoteIcon()` to always return same icon
- Redesign `_PriorityBadge` to match tag style

## ✅ Kriteria Sukses
- Semua note cards menampilkan icon yang sama
- Priority tampil sebagai chip dengan text dan background color
- Data tetap tersimpan dengan benar (tidak ada regresi)

## 🧪 Verification Plan

### Static Analysis
```bash
flutter analyze
```

### Manual Testing
1. Buka halaman Notes
2. Pastikan semua cards punya icon yang sama (📄)
3. Pastikan priority tampil sebagai chip (contoh: "Penting" dengan background merah)
4. Test edit note:
   - Ubah title, date, tags, priority
   - Exit dan reopen
   - Verifikasi semua data ter-load dengan benar
