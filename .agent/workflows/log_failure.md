---
description: Mencatat kegagalan tool/command ke failure log untuk pembelajaran Agent
---

## Kapan Dipanggil
- Otomatis oleh Agent saat tool/command gagal (sesuai STANDARDS.md Section 8A)
- Manual oleh User jika ingin mencatat kegagalan yang terlewat

---

## Langkah-langkah

1. **Kumpulkan Informasi Kegagalan**
   - **Tool yang gagal:** {nama tool: run_command, write_to_file, view_file, dll}
   - **Parameter/Command:** {detail parameter atau command yang dijalankan}
   - **Error Message:** {pesan error atau deskripsi kegagalan}
   - **Context:** {apa yang sedang dikerjakan saat gagal}

2. **Cek Apakah Ada Pattern Serupa**
   - Baca `agent-workspace/Log/failures.md`
   - Cari entry dengan Tool + Error yang mirip
   - Jika ada pattern yang sudah diidentifikasi, catat Pattern ID-nya

3. **Coba Temukan Workaround**
   - Apakah ada cara lain untuk mencapai tujuan yang sama?
   - Jika ditemukan, catat workaround tersebut
   - Jika tidak, tulis "Belum ditemukan"

4. **Append Entry ke failures.md**
   - Buka `agent-workspace/Log/failures.md`
   - Tentukan ID baru (F-{NNN} increment dari entry terakhir)
   - Tambahkan entry dengan format:
   
   ```markdown
   ### F-{NNN} | {Tool} | {Date YYYY-MM-DD}
   - **Command/Params:** {detail}
   - **Error:** {error message}
   - **Context:** {apa yang sedang dikerjakan}
   - **Workaround:** {jika ditemukan, atau "Belum ditemukan"}
   - **Pattern ID:** {jika sudah ada pattern serupa, atau "-"}
   ```

5. **Update Statistik**
   - Update tabel statistik di bagian atas `failures.md`
   - Increment counter untuk tool yang gagal
   - Update "Last Failure" date

6. **Notify User**
   - Informasikan: "📝 Failure logged: F-{NNN} - {brief description}"
   - Jika ini failure ke-3+ untuk pattern yang sama: "⚠️ Pattern detected! Pertimbangkan buat rule baru."

---

## Contoh Output

```
📝 Failure logged: F-004 - run_command del stuck
⚠️ Pattern detected: Terminal file operations (P-001). Workaround: gunakan write_to_file.
```
