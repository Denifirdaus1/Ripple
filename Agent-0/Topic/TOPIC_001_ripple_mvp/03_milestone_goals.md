# Fitur Milestone & Life Goals

**Parent:** [← Kembali ke Main](_main.md)
**Status:** ✅ Drafted

---

## Overview

Milestone adalah fitur untuk membantu user mencapai **tujuan hidup dan cita-cita jangka panjang**. Ini bukan sekadar todo, tapi peta perjalanan menuju impian.

---

## Konsep Utama

### Life Goal dengan Multi-Milestone
> Contoh: Goal "Menjadi Dokter" → 7 Milestones

```
🎯 Goal: Menjadi Dokter

├── 📍 Milestone 1: Lulus SMA dengan nilai bagus (2025)
├── 📍 Milestone 2: Masuk FK Universitas X (2026)
├── 📍 Milestone 3: Selesaikan tahun pre-klinik (2028)
├── 📍 Milestone 4: Lulus UKMPPD (2032)
├── 📍 Milestone 5: Selesaikan internship (2033)
├── 📍 Milestone 6: Dapat STR (2034)
└── 📍 Milestone 7: Praktik sebagai dokter! (2034)
```

### Elemen per Milestone
Setiap milestone bisa memiliki:
- **Judul** - Nama milestone
- **Target Waktu** - Tahun atau tanggal target
- **Notes** - Catatan detail/rencana
- **Banner** - Gambar penyemangat
- **Attached Todos** - Micro-progress untuk mencapai milestone

---

## User Flow

```
[User punya impian: "Jadi Dokter"]
    ↓
[Create Goal dengan beberapa Milestones]
    ↓
[Per Milestone: add judul, target tahun, notes, banner]
    ↓
[Attach Todos sebagai micro-progress]
    ↓
[Complete todos → progress toward milestone]
    ↓
[Centang milestone saat tercapai!]
```

---

## Fitur Wajib

### Goal Management
- [ ] Create goal dengan judul dan deskripsi
- [ ] Add multiple milestones per goal
- [ ] Reorder milestones (drag & drop)
- [ ] Delete/Archive goal

### Milestone Details
- [ ] Judul milestone
- [ ] Target waktu (tahun/tanggal)
- [ ] Notes field (rich text)
- [ ] Banner image upload
- [ ] Mark as complete (centang)

### Micro-Progress (Todo Attachment)
- [ ] Attach existing todo ke milestone
- [ ] Create new todo langsung dari milestone
- [ ] Track progress (X of Y todos done)
- [ ] Visual progress bar

---

## UI Concept

### Goal View
```
┌────────────────────────────────────────────┐
│  🎯 Menjadi Dokter                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━               │
│  Progress: ██████░░░░░░░░░░░░ 2/7          │
│                                            │
│  📍 ✓ Milestone 1: Lulus SMA        2025   │
│  📍 ✓ Milestone 2: Masuk FK         2026   │
│  📍 ○ Milestone 3: Pre-klinik       2028   │
│  📍 ○ Milestone 4: UKMPPD          2032   │
│  ...                                       │
└────────────────────────────────────────────┘
```

### Milestone Detail View
```
┌────────────────────────────────────────────┐
│  ┌──────────────────────────────────────┐  │
│  │         [Banner Image]               │  │
│  │     "You're gonna make it!"          │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  📍 Masuk FK Universitas X                 │
│  Target: 2026                              │
│                                            │
│  📝 Notes:                                 │
│  Persiapan UTBK, daftar bimbel, rajin     │
│  latihan soal...                           │
│                                            │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━               │
│  📋 Micro-Progress (Todos)                 │
│  ☑ Daftar bimbel UTBK                     │
│  ☑ Latihan soal 5x seminggu               │
│  ☐ Daftar SNBP/SNBT                       │
│  ☐ Prepare dokumen pendaftaran            │
│                                            │
│  Progress: ████████░░░░░░░░ 2/4           │
└────────────────────────────────────────────┘
```

---

## Data Model (Draft)

```
Goal {
  id: UUID
  title: String
  description: String?
  
  milestones: List<Milestone>
  
  createdAt: DateTime
  updatedAt: DateTime
}

Milestone {
  id: UUID
  goalId: UUID
  
  title: String
  targetDate: DateTime? // Bisa tahun saja atau full date
  notes: RichText?
  bannerUrl: String?
  
  // Progress
  isCompleted: Boolean
  completedAt: DateTime?
  
  // Attached todos
  todoIds: List<UUID>
  
  order: Int // For reordering
  createdAt: DateTime
  updatedAt: DateTime
}
```

---

## ✅ Confirmed Decisions

| Question | Decision |
|----------|----------|
| Todo attached ke milestone + daily schedule? | ✅ **Sync** - Itu benda yang sama. Centang satu = update semua |
| Sub-milestones (nested)? | ❌ **Tidak perlu** untuk MVP, bisa di-update nanti jika perlu |
| Sharing/accountability partner? | ⏳ **Future** - tidak untuk MVP |
