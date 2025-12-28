---
description: Membuat Knowledge entry baru di Agent-0 Knowledge Base
---

## 📖 Create Knowledge Workflow

### Step 1: Gather Information
Tanyakan kepada user (jika belum jelas):
1. **Domain:** Di domain apa knowledge ini? (misal: programming, business, general)
2. **Judul:** Apa judul knowledge ini?
3. **Konten:** Apa isi knowledge-nya?
4. **Source:** Dari mana sumber informasi ini? (URL, buku, pengalaman, dll)
5. **Tags:** Tag apa yang relevan?

### Step 2: Check Domain
1. Baca `agent-workspace/Knowledge/index.md`
2. Cek apakah domain sudah ada
3. Jika **belum ada**:
   - Buat folder baru: `Knowledge/{domain_slug}/`
   - Buat file `index.md` di dalam folder tersebut
   - Update `Knowledge/index.md` dengan domain baru

### Step 3: Generate ID
1. Baca `Knowledge/{domain}/index.md`
2. Cari ID tertinggi yang ada (misal: K_003)
3. ID baru = increment +1 (misal: K_004)

### Step 4: Create Knowledge File
1. Gunakan template `.agent/templates/knowledge_template.md`
2. Buat file: `Knowledge/{domain}/K_NNN_{slug}.md`
3. Isi semua field:
   - Domain, Tags, Source
   - Ringkasan (1-2 kalimat)
   - Konten lengkap
   - Related Knowledge/Topic jika ada

### Step 5: Update Indices

> **⚡ Optimized:** Gunakan `python scripts/auto_index_updater.py` untuk update semua index otomatis.

**Manual (jika perlu):**
1. Update `Knowledge/{domain}/index.md`:
   - Tambah entry di tabel
   - Update statistik
2. Update `Knowledge/index.md`:
   - Update jumlah entries
   - Update Last Updated

### Step 6: Log Activity
1. Catat di `agent-workspace/Log/aktivitas.md`:
   - `| {HH:mm} | Buat Knowledge | {K_ID} | {Judul} |`

### Step 7: Confirmation
Output:
- "✅ Knowledge created: **{K_ID}** - {Judul}"
- "📁 Location: `Knowledge/{domain}/{filename}`"
- "🏷️ Tags: {tags}"
