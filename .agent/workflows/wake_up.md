---
description: Ritual awal sesi untuk memuat konteks 'Otak' (Topic) dan 'Rencana' (Plan) ke dalam Working Memory
---

## 🧠 Phase 0: Load Operating System

0.  **Load Standards (Pre-requisite)**
    - Baca file `.agent/STANDARDS.md` untuk memuat semua aturan dan constraint.
    - Internalize Section 7 (Known Constraints) dan Section 8 (Self-Learning Rules).
    - **Output:** "✅ Standards loaded. {N} constraints aktif."

---

## 📡 Phase 1: Situational Awareness

> **⚡ Optimized:** Step 1 menggunakan Python script untuk efisiensi.

// turbo
1.  **Scan Horizon (Python-Assisted)**
    - Jalankan: 
      ```powershell
      cd d:\non-code\meta-workflow\scripts
      python analyze_workspace.py
      ```
    - Baca output `scripts/workspace_index.json` untuk ringkasan cepat.
    - **Alternatif Manual:** Baca `index.md` per folder jika butuh detail lebih.
    - Tampilkan ringkasan singkat:
      - "📚 Topik Aktif: {N} topik"
      - "🏗️ Plan On-Going: {N} plan"
      - "📖 Knowledge: {N} domains"
      - "🔬 Research: {N} entries"
      - "📋 Find: {N} findings"

2.  **Review Failure Log (Self-Learning)**
    - Baca file `agent-workspace/Log/failures.md`.
    - Cek apakah ada failure baru yang belum di-pattern.
    - Jika ada ≥3 failure serupa tanpa Pattern ID → identifikasi sebagai pattern baru.
    - **Output:** 
      - "📊 Failure Log: {N} entries, {M} patterns identified"
      - Jika ada pattern baru: "⚠️ New pattern detected: [deskripsi] - perlu buat rule baru"

3.  **Review User Behaviour (Personalization)**
    - Baca file `agent-workspace/Log/user_behaviour.md`.
    - Cek section "Pending Patterns" — apakah ada yang sudah ≥3 evidence?
    - Jika ada → **Promote** ke section "Learned Preferences".
    - Tampilkan Learned Preferences aktif.
    - **Output:**
      - "👤 User Preferences: {N} aktif, {M} pending"
      - Jika ada promotion: "✨ New preference learned: [deskripsi]"

---

## 🎯 Phase 2: Focus Selection

4.  **Attention Focus (User Query)**
    - Tanyakan kepada user: *"Selamat pagi! Hari ini kita mau fokus memajukan topik atau plan yang mana?"*
    - Jika user menjawab "Lanjut yang kemarin", cek Log terakhir di direktori `agent-workspace/Log/aktivitas.md`.

---

## 📂 Phase 3: Context Loading

5.  **Load Context (Retrieval)**
    Berdasarkan pilihan user:
    - **Jika Topic:**
      - Baca file topik tersebut (misal `TOPIC_002_xxx.md`).
      - Cek apakah ada Plan terkait di dalamnya. Jika ada, baca juga file Plan-nya.
    - **Jika Plan:**
      - Baca file plan tersebut (misal `PLAN_001_xxx.md`).
      - Baca file Topic induknya (wajib ada link di section 'Terkait').
      - Baca file Find terkait jika ada di section 'Terkait'.

---

## 📋 Phase 4: Briefing

6.  **Morning Briefing (Synthesis)**
    Berikan laporan kesiapan:
    - "🧠 **Konteks Terload:** [Nama Topik]"
    - "🎯 **Misi Hari Ini:** [Judul Plan / Langkah Selanjutnya di ceklist Plan]"
    - "⚠️ **Pending Issue:** [Jika ada Finding terkait yg open]"
    - "🔄 **Learned Constraints:** [Jika ada pattern baru yang perlu diperhatikan]"
    
    Tutup dengan: *"Saya siap. Apa instruksi pertama?"*
