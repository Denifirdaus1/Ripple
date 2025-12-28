---
description: Membuat Finding baru (Temuan/Bug/Isu) di Agent-0
---

1.  **Baca Standar & Cek Index**
    - Baca `.agent/STANDARDS.md` untuk konvensi terbaru.
    - Baca `agent-workspace/Find/index.md`.
    - Tentukan ID berikutnya (Format: `FIND_NNN`).

2.  **Minta/Tentukan Detail**
    - Pastikan memiliki **Judul** dan **Deskripsi Masalah**.
    - Jika belum ada, minta user atau ekstrak dari konteks percakapan.
    - **Generate Slug**: Ikuti aturan di `STANDARDS.md`.

3.  **Buat File Finding**
    - Buat file baru di `agent-workspace/Find/FIND_{NNN}_{slug}.md`.
    - Gunakan template berikut:
      ```markdown
      # {Judul}

      **ID:** FIND_{NNN} | **Status:** 🔍 Investigasi | **Prioritas:** 🟡 Normal
      **Dibuat:** {YYYY-MM-DD} | **Update:** {YYYY-MM-DD}

      ## 📝 Deskripsi Masalah
      {Jelaskan apa yang terjadi, error message, atau behavior yang salah}

      ## 🕵️ Analisis & Hipotesis
      - [ ] Cek file terkait
      - [ ] Analisis root cause

      ## 💡 Ide Solusi
      -

      ## 🔗 Terkait
      Topic: -
      ```

4.  **Update Index Finding**

    > **⚡ Optimized:** Jalankan `python scripts/auto_index_updater.py` untuk update semua index otomatis.
    
    **Manual (jika perlu):**
    - Edit `agent-workspace/Find/index.md`.
    - Tambahkan baris baru di tabel bagian `## 🔍 Investigasi`:
      `| FIND-{XXX} | {Judul} | 🟡 Normal |`
    - Update baris **Ringkasan** di bawah (tambah jumlah 🔍).

5.  **Log Aktivitas**
    - Tambahkan entri baru di `agent-workspace/Log/aktivitas.md`:
      `| {HH:mm} | Buat Finding | FIND-{XXX} | {Judul} |`
