# Fitur TodoList & Focus Mode

**Parent:** [← Kembali ke Main](_main.md)
**Status:** ✅ Drafted

---

## Overview

Fitur TodoList di Ripple memiliki 2 varian yang saling melengkapi:

1. **Scheduled TodoList (Timeline)** - Task dengan waktu spesifik
2. **Regular TodoList (Priority-based)** - Task fleksibel tanpa waktu

---

## 1. Scheduled TodoList (Daily Timeline)

### Konsep
- UI berbentuk **timeline waktu harian** 
- User harus set **waktu mulai** dan **waktu selesai** untuk setiap todo
- Visualisasi seperti kalender dengan slot waktu

### User Flow
```
[User membuat todo] 
    ↓
[Set waktu: 06:00 - 08:00] 
    ↓
[Todo tampil di timeline harian]
    ↓
[Notifikasi muncul tepat waktu]
    ↓
[Click notif → Masuk Focus Mode]
```

### Contoh Skenario
> User set todo "Olahraga" untuk 06:00-08:00 di malam sebelumnya.
> Keesokan hari tepat jam 06:00, notifikasi muncul.
> User click → langsung masuk Focus Mode untuk todo tersebut.

### Fitur Wajib
- [ ] Timeline UI dengan slot waktu
- [ ] Add todo dengan waktu start & end
- [ ] Integrasi notification system
- [ ] Link langsung ke Focus Mode dari notifikasi

---

## 2. Regular TodoList (Priority-based)

### Konsep
- Daftar todo **tanpa waktu spesifik**
- Hanya ada **skala prioritas** (High, Medium, Low)
- Bisa dikerjakan kapan saja user mau

### Fitur Wajib
- [ ] Add todo tanpa waktu
- [ ] Priority selector (High/Medium/Low)
- [ ] Opsi untuk **convert ke Scheduled Todo**
  - Syarat: User harus tambah waktu start & end

### Sandbox Features
- [ ] Dropdown untuk kategorisasi
- [ ] Progress list (subtasks)
- [ ] Custom labels/tags

### Recurring Todo Feature
> **Decision Confirmed:** Fitur recurring dibutuhkan dengan implementasi simpel

**UI - Dropdown "Repeat":**
- [ ] Opsi: None / Custom Days
- [ ] Multi-select hari (Senin, Selasa, ... atau "Setiap Hari")
- [ ] Per-day time override (optional)
  - Default: Sama dengan waktu original
  - Bisa diubah per hari jika berbeda (misal: Senin 08:00, Sabtu 11:00)

**Contoh UI:**
```
Repeat: [Custom Days ▼]
├── ☑ Senin     [08:00 - 09:00]
├── ☐ Selasa   
├── ☐ Rabu     
├── ☐ Kamis    
├── ☑ Jumat    [Same as original]
├── ☑ Sabtu    [11:00 - 12:00]  ← custom time
└── ☐ Minggu
```

**Technical Note (ISODOW):**
> ⚠️ Backend menggunakan **ISODOW** (ISO 8601) untuk locale-independent day matching:
> - 1 = Monday (Senin)
> - 2 = Tuesday (Selasa)
> - 3 = Wednesday (Rabu)
> - 4 = Thursday (Kamis)
> - 5 = Friday (Jumat)
> - 6 = Saturday (Sabtu)
> - 7 = Sunday (Minggu)
>
> Format JSONB: `{"days": [1, 5, 6], "time_overrides": {"6": {"start": "11:00", "end": "12:00"}}}`

---

## 3. Focus Mode (Pomodoro)

### Konsep
- Mode fokus yang bisa di-**enable** per todo
- Countdown timer dengan teknik Pomodoro (atau custom duration)
- Full-screen distraction-free UI

### User Flow
```
[Todo dengan Focus Mode enabled]
    ↓
[User click "Start Focus"]
    ↓
[Masuk halaman Focus Mode]
    ↓
[Timer countdown + todo details visible]
    ↓
[Complete / Pause / Cancel]
```

### Fitur Wajib
- [ ] Toggle enable/disable Focus Mode per todo
- [ ] Pomodoro timer (25min work / 5min break, customizable)
- [ ] Session tracking (berapa sesi sudah selesai)
- [ ] Pause & Resume capability
- [ ] Mark as complete dari Focus Mode
- [ ] **Sync activity data ke database** (untuk monthly summary/"Ripple Wrapped" feature)

---

## Data Model (Draft)

```
Todo {
  id: UUID
  title: String
  description: String?
  priority: Enum (high, medium, low)
  
  // Scheduled Todo
  isScheduled: Boolean
  startTime: DateTime?
  endTime: DateTime?
  
  // Focus Mode
  focusModeEnabled: Boolean
  focusDuration: Int? (minutes)
  sessionsCompleted: Int
  
  // Relations
  milestoneId: UUID? (optional link to Milestone)
  
  // Status
  isCompleted: Boolean
  createdAt: DateTime
  updatedAt: DateTime
}
```

---

## ✅ Confirmed Decisions

| Question | Decision |
|----------|----------|
| Todo overlap di timeline? | ✅ Allowed - tampilan bertumpuk/berdampingan seperti Google Calendar |
| Recurring/repeating todos? | ✅ Ya - simple dropdown dengan pilihan hari & optional time override |
| Focus Mode sync? | ✅ Sync ke database - untuk fitur monthly summary ("Ripple Wrapped") |
