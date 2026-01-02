# Implement Schedule Management (PLAN_016)

**ID:** PLAN_016 | **Status:** 📋 Backlog | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-31 | **Update:** 2025-12-31

## 🎯 Tujuan
Menambahkan formulir penjadwalan (Date & Time Picker) pada `TodoEditSheet` agar user bisa mengatur jadwal (`startTime`, `endTime`) yang akan muncul di **Calendar Timeline**. Saat ini `TodoEditSheet` belum memiliki input untuk jadwal.

## 🛠️ Strategi Implementasi
### Phase 1: Update UI TodoEditSheet
1. [ ] Tambahkan Switch/Checkbox "Schedule".
2. [ ] Tambahkan **Date Picker** (Hari).
3. [ ] Tambahkan **Time Range Picker** (Start Time & End Time).
   - Gunakan `showTimePicker` standar Flutter atau library jika perlu.
   - Default Duration: 1 jam.

### Phase 2: Logic & Data Mapping
1. [ ] Update `_submit` logic di `TodoEditSheet`:
   - Jika "Schedule" ON:
     - Set `isScheduled = true`
     - Set `scheduledDate` = selected date
     - Set `startTime` = selected date + start time
     - Set `endTime` = selected date + end time
     - Validasi `endTime > startTime`.
2. [ ] Pastikan data tersimpan ke Supabase via Bloc (sudah ter-handle di `TodosOverviewBloc`).

## ✅ Kriteria Sukses
- Form Schedule muncul di `TodoEditSheet`.
- Bisa pilih Tanggal, Jam Mulai, Jam Selesai.
- Task yang dijadwalkan muncul di `SfCalendar` (sudah di-implement di PLAN_015).
- Data persist di database.

## 🔗 Terkait
- PLAN_015 (Calendar View)
- Topic: TOPIC_003 (Calendar Library)
