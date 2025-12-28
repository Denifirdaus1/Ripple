---
description: Mekanisme introspeksi otonom untuk memastikan integritas data dan keselarasan strategi Agent-0.
---

# 🕵️ Workflow /self_audit

Workflow ini dijalankan untuk melakukan audit menyeluruh terhadap kesehatan Workspace dan kepatuhan agen terhadap standar yang telah ditetapkan.

## 📡 Phase 1: Data Integrity Check (Infrastruktur)

> **⚡ Optimized:** Phase ini menggunakan Python script untuk efisiensi.
> Lihat `/doc_health_check` untuk detail workflow terpisah.

// turbo
1.  **Run Document Health Analyzer**
    ```powershell
    cd d:\non-code\meta-workflow\scripts
    python document_health_analyzer.py
    ```
    
    Script akan menghasilkan:
    - Health Score (0-100)
    - Broken Links list
    - Orphan Files list  
    - Missing from Index list
    - Cross-reference map

2.  **Review Health Report**
    - Baca output terminal atau `scripts/document_health_report.json`
    - Jika score < 80 → lanjut ke fix issues
    - Jika score >= 80 → lanjut ke Phase 1.5

## 🔴 Phase 1.5: Failure System Check (Self-Learning)

2a. **Failure Log Review**
    - Baca `agent-workspace/Log/failures.md`
    - Hitung: Total entries, Identified patterns, Unpatterned failures
    - Jika ada ≥3 failure serupa tanpa Pattern ID → flag sebagai "New Pattern Detected"
    - **Output:** "📊 Failures: {N} entries, {M} patterns, {X} unpatterned"

2b. **Failure Re-test Offering** (Interactive)
    - Cek tanggal pembuatan setiap pattern di section "Identified Patterns"
    - Jika pattern berusia >7 hari dari hari ini:
      - Tampilkan: "⏰ Pattern {ID} ({deskripsi}) berusia {N} hari."
      - Prompt: "Mau saya test ulang apakah constraint ini masih berlaku? (y/n)"
    - Jika user approve → jalankan test case terkait dari section "Test Cases"
    - Lanjut ke step 2c

2c. **Post-Test Actions** (Hybrid Approach)
    - **Jika test GAGAL (error masih terjadi):**
      - Pattern masih VALID
      - Update `last_tested` date di test case
      - Output: "✅ Pattern {ID} masih berlaku. Last tested: {date}"
    
    - **Jika test BERHASIL (error tidak terjadi lagi):**
      - Pattern kemungkinan OBSOLETE
      - Agent PROPOSE perubahan:
        1. "🔔 Pattern {ID} sepertinya sudah tidak berlaku."
        2. "📋 Saya sarankan:"
           - Archive pattern ke section "Archived Patterns"
           - Revisi/hapus rule terkait di STANDARDS.md
        3. "⚠️ Ini adalah perubahan signifikan. Approve? (y/n)"
      - Jika user APPROVE → eksekusi perubahan
      - Jika user REJECT → keep as is, catat di log

## 🏗️ Phase 2: Strategic Alignment (Eksperimental)


3.  **Stalled Plan Detection**
    - Baca log aktivitas terakhir.
    - Cari Plan dengan status "In Progress" yang tidak memiliki update dalam 3 sesi terakhir.
    - **Output:** Tandai sebagai ⚠️ Stalled jika terdeteksi.

4.  **Information Redundancy Scan**
    - Baca ringkasan dari 5 Topik terbaru.
    - Gunakan `deep_thinking` untuk menilai apakah ada Topik yang isinya dapt digabungkan (merge recommendation).

## ⚖️ Phase 3: Safety & Alignment (Etika)

5.  **Constitutional Compliance**
    - Baca file `.agent/STANDARDS.md` dan `agent-workspace/Topic/TOPIC_005_alignment_constitution.md`.
    - Review ringkasan sesi terbaru (Aktivitas Log).
    - **Output:** Laporkan jika ada tindakan agen yang berpotensi melanggar constraint atau prinsip otonom yang disepakati.

## 📋 Phase 4: Audit Reporting

6.  **Generate Audit Report**
    Sajikan temuan dalam format:
    - **Integritas:** ✅ Clean / ⚠️ {N} Orphan Files.
    - **Strategi:** ✅ On Track / ⚠️ {N} Stalled Plans.
    - **Alignment:** ✅ Aligned / ⚠️ Issues Detected.
    - **Rekomendasi Utama:** [Daftar tindakan korektif, misal: "Update index Topic", "Archive Plan-00X"].

7.  **Auto-Fix (Optional)**
    - Jika user memberikan approval, lakukan perbaikan otomatis untuk masalah integritas data (update index).

---
// turbo-all
