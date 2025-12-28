---
description: Create a new Topic in the Agent-0 system
---

1.  **Baca Standar & Cek Index**
    - Baca `.agent/STANDARDS.md` untuk konvensi terbaru.
    - Baca `agent-workspace/Topic/index.md` untuk ID terakhir.
    - Tentukan ID berikutnya (Format: `TOPIC_NNN`).

2.  **Get Topic Details**
    - If the user hasn't provided a **Title**, ask for it.
    - If the user hasn't provided a **Description**, ask for it (or draft one based on context).
    - **Generate Slug**: Buat versi singkat dari judul (2-4 kata, lowercase, underscore).
      - Contoh: "Meta Prompting: Manusia sebagai Arsitek" → `meta_prompting`
      - Contoh: "Strategi Deployment Cloudflare" → `deploy_cloudflare`

3.  **Determine Topic Type**
    - **📄 Simple Topic**: Untuk topik sederhana yang bisa dibahas dalam 1 file.
    - **📂 Expanded Topic**: Untuk topik kompleks yang memerlukan banyak sub-topic.
    - Jika tidak yakin, mulai dengan Simple. Bisa di-expand nanti (lihat langkah 8).

4.  **Create Topic File(s)**

    **A. Simple Topic (Default)**
    - Create file: `agent-workspace/Topic/TOPIC_{NNN}_{slug}.md`
    - Template:
      ```markdown
      # {Title}

      **ID:** TOPIC_{NNN} | **Status:** 💬 Aktif | **Prioritas:** 🟡 Normal
      **Dibuat:** {YYYY-MM-DD} | **Update:** {YYYY-MM-DD}
      **Tipe:** 📄 Simple

      ## Deskripsi
      {Description}

      ## Poin Penting
      - 

      ## Terkait
      Find: - | Plan: -
      ```

    **B. Expanded Topic**
    - Create folder: `agent-workspace/Topic/TOPIC_{NNN}_{slug}/`
    - Create main file: `agent-workspace/Topic/TOPIC_{NNN}_{slug}/_main.md`
    - Template untuk `_main.md`:
      ```markdown
      # {Title}

      **ID:** TOPIC_{NNN} | **Status:** 💬 Aktif | **Prioritas:** 🟡 Normal
      **Dibuat:** {YYYY-MM-DD} | **Update:** {YYYY-MM-DD}
      **Tipe:** 📂 Expanded Topic (Multi-file)

      ---

      ## Deskripsi
      {Description}

      ---

      ## Poin Penting
      - 

      ---

      ## 📚 Daftar Sub-Topik

      ### ✅ Sudah Dibahas
      | No | Sub-Topik | File | Status |
      |----|-----------|------|--------|

      ### ⏳ Belum Dibahas
      | No | Sub-Topik | File | Status |
      |----|-----------|------|--------|
      | 1 | [Nama sub-topik] | [01_nama_file.md](01_nama_file.md) | ⏳ Pending |

      ---

      ## Terkait
      Find: - | Plan: -
      ```

5.  **Update Topic Index**

    > **⚡ Optimized:** Jalankan `python scripts/auto_index_updater.py` untuk update semua index otomatis.
    
    **Manual (jika perlu):**
    - Edit `agent-workspace/Topic/index.md`.
    - Kolom tabel: `| ID | Judul | Tipe | Prioritas |`
    - **Simple**: `| [TOPIC_{NNN}](TOPIC_{NNN}_{slug}.md) | {Title} | 📄 Simple | 🟡 Normal |`
    - **Expanded**: `| [TOPIC_{NNN}](TOPIC_{NNN}_{slug}/_main.md) | {Title} | 📂 Expanded | 🟡 Normal |`
    - Update **Ringkasan** count.

6.  **Log Activity**
    - Append to `agent-workspace/Log/aktivitas.md`:
      `| {HH:mm} | Buat Topic | TOPIC_{NNN} | {Title} |`

7.  **Confirm & Transition**
    - Inform user topic created.
    - State entering **Discussion Cycle**.

8.  **Expand Existing Topic (Optional)**
    Jika topic **Simple** sudah membesar dan perlu di-expand:
    
    a. Buat folder: `agent-workspace/Topic/TOPIC_{NNN}_{slug}/`
    b. Pindahkan/rename file lama ke `_main.md` di dalam folder
    c. Ekstrak section-section besar ke file terpisah: `01_xxx.md`, `02_xxx.md`, dst.
    d. Di `_main.md`, buat tabel link ke sub-topic files
    e. Update index untuk mengarah ke `_main.md`
    f. Hapus file simple lama jika sudah tidak diperlukan

9.  **Add Sub-Topic (untuk Expanded Topic)**
    Untuk menambah sub-topik baru:
    
    a. Buat file: `{NN}_{slug}.md` di dalam folder topic
    b. Template sub-topic:
       ```markdown
       # {Sub-Topic Title}

       **Parent:** [← Kembali ke Main](_main.md)
       **Status:** ⏳ Pending / ✅ Selesai

       ---

       [Konten sub-topic]
       ```
    c. Update tabel di `_main.md` dengan link ke file baru
