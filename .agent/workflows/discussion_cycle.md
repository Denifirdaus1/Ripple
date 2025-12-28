---
description: Berdiskusi mengenai topik dan mencatat intisari diskusi ke file Topic
---

1.  **Context Check**
    - Pastikan file `TOPIC_{NNN}.md` yang relevan sedang dibuka atau diketahui.
    - Jika belum jelas, tanyakan kepada user topik mana yang sedang didiskusikan.

2.  **Diskusi (Discussion)**
    - Lakukan diskusi dengan user mengenai topik tersebut.
    - Jawab pertanyaan, berikan saran, atau analisis sesuai kebutuhan user.
    - *Langkah ini adalah proses interaktif yang terjadi di chat.*

3.  **Ringkas Intisari (Summarize)**
    - Setelah diskusi mencapai titik kesimpulan atau user meminta dicatat:
    - Buat ringkasan poin-poin penting, keputusan, atau ide baru dari percakapan.
    - Pastikan ringkasan padat dan jelas.

4.  **Update Topic File**
    - Edit file `agent-workspace/Topic/TOPIC_{NNN}.md`.
    - Update field header: `**Update:** {YYYY-MM-DD}` (gunakan tanggal hari ini).
    - Tambahkan konten ke bagian `## Poin Penting` (atau `## Catatan Diskusi` jika dibuat baru).
        - Gunakan format list bullet ` - Point`.
        - Jika perlu, tambahkan sub-header tanggal/waktu agar kronologis terlihat:
          ```markdown
          ### [{YYYY-MM-DD HH:mm}]
          - Poin diskusi 1...
          - Poin diskusi 2...
          ```

5.  **Log Activity**
    - Tambahkan entry baru ke `agent-workspace/Log/aktivitas.md`.
    - Format: `| {YYYY-MM-DD HH:mm} | DISKUSI | TOPIC_{NNN} | {Ringkasan singkat topik diskusi} |`

6.  **Konfirmasi**
    - Informasikan kepada user bahwa poin-poin penting telah dicatat.
