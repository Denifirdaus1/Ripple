# Agent-0 Standards & Conventions

Dokumen ini adalah **Single Source of Truth** untuk semua konvensi penamaan, struktur file, dan prosedur operasional di dalam Agent-0. Semua workflow **WAJIB** merujuk ke dokumen ini pada langkah pertama.

---

## 1. Konvensi Penamaan (Naming Convention)

### A. Format ID
Gunakan **Underscore (`_`)** sebagai pemisah antar komponen ID, bukan dash (`-`).
- **Topic:** `TOPIC_NNN` (Contoh: `TOPIC_001`)
- **Plan:** `PLAN_NNN` (Contoh: `PLAN_001`)
- **Finding:** `FIND_NNN` (Contoh: `FIND_001`)
- **Knowledge:** `K_NNN` (Contoh: `K_001`)

### B. Slug & Nama File
Format: `{ID}_{slug}.md`
- **Slug:** 2-4 kata, lowercase, dipisahkan underscore.
- **Contoh Benar:** `TOPIC_001_project_setup.md`

---

## 2. Struktur Folder & Lokasi
- **Topic:** `Agent-0/Topic/`
- **Plan:** `Agent-0/Plan/`
- **Finding:** `Agent-0/Find/`
- **Knowledge:** `Agent-0/Knowledge/{domain}/`
- **Log:** `Agent-0/Log/`
- **Standards:** `.agent/STANDARDS.md` (Dokumen ini)

---

## 3. Prinsip Dasar (HHH)

1. **Helpfulness (Kemanfaatan):** Berusaha maksimal memberikan solusi efektif.
2. **Harmlessness (Ketidakberbahayaan):** Tidak merusak sistem atau data.
3. **Honesty (Kejujuran):** Transparan tentang limitasi dan ketidakpastian.

---

## 4. Prosedur Update Index

Setiap kali membuat artefak baru, Agent **WAJIB** mengupdate file `index.md` di folder terkait.

---

## 5. Prosedur Logging

Setiap aksi signifikan dicatat di `Agent-0/Log/aktivitas.md`:
- Format: `| {HH:mm} | {Aktivitas} | {ID} | {Keterangan} |`

---

## 6. Self-Learning

Setiap kegagalan tool/command dicatat di `Agent-0/Log/failures.md` untuk pembelajaran.

---

## 7. Filosofi Agent-0

Agent-0 adalah **mesin berpikir eksternal** — perpanjangan pikiran yang belajar dari cara user bekerja, bukan user yang beradaptasi dengan Agent.
