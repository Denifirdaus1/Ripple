# Ripple MVP: Productivity App Vision

**ID:** TOPIC_001 | **Status:** 💬 Aktif | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-28 | **Update:** 2025-12-28
**Tipe:** 📂 Expanded Topic (Multi-file)

---

## Deskripsi

Ripple adalah aplikasi produktivitas terintegrasi AI yang menggabungkan **TodoList**, **Pomodoro (Focus Mode)**, **Notes**, dan **Milestone** dalam satu platform. Konsep utamanya adalah membantu user tidak hanya mengelola tugas harian, tetapi juga mencapai tujuan hidup jangka panjang dengan sistem yang terstruktur dan saling terhubung.

### Filosofi Produk
- **Interconnected Productivity**: Semua fitur saling terkait (Notes bisa mention Todo, Todo bisa di-attach ke Milestone)
- **AI-Assisted (Optional)**: User bisa memilih menggunakan AI atau tidak
- **Scheduled & Flexible**: Mendukung task terjadwal (timeline) dan fleksibel (priority-based)

---

## Poin Penting

- ✅ Project sudah di-setup dengan Clean Architecture folder structure
- ✅ Google OAuth 2.0 via Supabase Auth sudah terkonfigurasi
- ✅ `.env` sudah terhubung ke Supabase database (database masih kosong)
- ⏳ MVP akan mencakup 4 fitur utama: TodoList, Notes, Milestone, AI Integration
- ⏳ Perlu finalisasi wireframe sebelum masuk ke tahap Plan

---

## 📚 Daftar Sub-Topik

### ✅ Sudah Dibahas
| No | Sub-Topik | File | Status |
|----|-----------|------|--------|

### ⏳ Belum Dibahas
| No | Sub-Topik | File | Status |
|----|-----------|------|--------|
| 1 | Fitur TodoList & Focus Mode | [01_todolist_focusmode.md](01_todolist_focusmode.md) | ✅ Confirmed |
| 2 | Fitur Notes dengan Hyperlink | [02_notes_hyperlink.md](02_notes_hyperlink.md) | ✅ Confirmed |
| 3 | Fitur Milestone & Life Goals | [03_milestone_goals.md](03_milestone_goals.md) | ✅ Confirmed |
| 4 | AI Integration | [04_ai_integration.md](04_ai_integration.md) | ⏸️ Post-MVP |
| 5 | Wireframe & User Flow | [05_wireframe_userflow.md](05_wireframe_userflow.md) | ✅ Approved |
| 6 | Database Schema Design | [06_database_schema.md](06_database_schema.md) | ✅ Production-Ready |
| 7 | Push Notifications (FCM) | [07_push_notifications.md](07_push_notifications.md) | ✅ Confirmed |

---

## Tech Stack (Current)

| Layer | Technology |
|-------|------------|
| Frontend | Flutter |
| Backend/Auth | Supabase |
| Database | PostgreSQL (via Supabase) |
| AI | TBD |

---

## Terkait
Find: - | Plan: -
