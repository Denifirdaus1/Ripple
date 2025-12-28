---
description: Membuat Plan baru (Rencana Implementasi) di Agent-0
---

1.  **Baca Standar & Cek Index**
    - Baca `.agent/STANDARDS.md` untuk konvensi terbaru.
    - Baca `agent-workspace/Plan/index.md`.
    - Tentukan ID berikutnya (Format: `PLAN_NNN`).

2.  **Minta/Tentukan Detail**
    - Pastikan memiliki **Judul Rencana** dan **Tujuan**.
    - **Generate Slug**: Ikuti aturan di `STANDARDS.md`.

3.  **Buat File Plan**
    - Buat file baru di `agent-workspace/Plan/PLAN_{NNN}_{slug}.md`.
    - Gunakan template berikut:
      ```markdown
      # {Judul}

      **ID:** PLAN_{NNN} | **Status:** 📋 Backlog | **Prioritas:** 🟡 Normal
      **Dibuat:** {YYYY-MM-DD} | **Update:** {YYYY-MM-DD}

      ## 🎯 Tujuan
      {Jelaskan tujuan dari plan ini}

      ## 🛠️ Strategi Implementasi
      1. [ ] Langkah 1
      2. [ ] Langkah 2

      ## ✅ Kriteria Sukses
      - Build berhasil
      - Bug teratasi / Fitur berjalan

      ## 🔗 Terkait
      Find: -
      Topic: -
      ```

4.  **Update Index Plan**

    > **⚡ Optimized:** Jalankan `python scripts/auto_index_updater.py` untuk update semua index otomatis.
    
    **Manual (jika perlu):**
    - Edit `agent-workspace/Plan/index.md`.
    - Tambahkan baris baru di tabel bagian `## 📋 Backlog`:
      `| PLAN-{XXX} | {Judul} | 🟡 Normal | - |`
    - Update baris **Ringkasan** di bawah (tambah jumlah 📋).

5.  **Log Aktivitas**
    - Tambahkan entri baru di `agent-workspace/Log/aktivitas.md`:
      `| {HH:mm} | Buat Plan | PLAN-{XXX} | {Judul} |`
