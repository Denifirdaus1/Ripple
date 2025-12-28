# Fitur Notes dengan Hyperlink

**Parent:** [← Kembali ke Main](_main.md)
**Status:** ✅ Drafted

---

## Overview

Notes di Ripple bukan sekadar catatan teks biasa, tapi **interconnected canvas** yang bisa menghubungkan ke todo dan resources lain.

---

## Konsep Utama

### Canvas-Style Notes
- Area kosong yang bisa diisi dengan berbagai elemen
- Support untuk formatting dasar (headers, paragraphs, lists)
- Freeform layout

### Hyperlink/Mention System
> Seperti mention di WhatsApp, tapi untuk Todo

**Contoh:**
```
"Aduh aku males banget hari ini, tapi aku tetap harus melakukan 
[@Olahraga Pagi] dan [@Belajar Flutter] sebelum istirahat..."
```

- User bisa **mention todo** dari todolist yang ada
- Mention bisa single atau multiple todos
- Click mention → langsung navigate ke todo page

---

## User Flow: Mention Todo

```
[User sedang mengetik di Notes]
    ↓
[Ketik trigger: "@" atau "[["]
    ↓
[Muncul dropdown autocomplete: list todos]
    ↓
[User pilih todo]
    ↓
[Todo ter-embed sebagai interactive chip/box]
    ↓
[Click chip → Navigate ke Todo detail]
```

---

## Supported Media

Selain teks dan mentions, Notes harus support:

| Media Type | Description |
|------------|-------------|
| 🔗 Links | External URLs (auto-preview if possible) |
| 🖼️ Images | Upload atau paste image |
| 🎵 Audio | Voice notes atau audio files |
| 🎬 Video | Video embed atau upload |

---

## Fitur Wajib

### Text Formatting (Markdown-based)
> **Decision Confirmed:** Menggunakan Markdown untuk clean UI dan kemudahan user

- [ ] Judul otomatis **bigger & bold** (H1 treatment)
- [ ] Headers (H1, H2, H3) via `#`, `##`, `###`
- [ ] Paragraphs
- [ ] **Bold** (`**text**`), *Italic* (`*text*`), ~~Strikethrough~~
- [ ] Bullet lists (`-`) & Numbered lists (`1.`)
- [ ] Checkboxes (`- [ ]` inline todo)
- [ ] Code blocks & inline code

### Mentions & Links
- [ ] Todo mention dengan autocomplete
- [ ] Multiple mentions dalam 1 notes
- [ ] Interactive chip UI untuk mentions
- [ ] Click-to-navigate functionality

### Media Embeds
- [ ] Image upload & display
- [ ] External link embed
- [ ] Audio player embed
- [ ] Video player embed

---

## Data Model (Draft)

```
Note {
  id: UUID
  title: String
  content: RichText/JSON // Structured content
  
  // Mentions (embedded references)
  todoMentions: List<UUID> // IDs of mentioned todos
  
  // Media attachments
  attachments: List<Attachment>
  
  // Metadata
  createdAt: DateTime
  updatedAt: DateTime
}

Attachment {
  id: UUID
  type: Enum (image, audio, video, link)
  url: String
  metadata: JSON? // dimensions, duration, etc
}
```

---

## UI Considerations

### Mention Chip Design
```
┌─────────────────────────┐
│ ✓ Olahraga Pagi    →   │
│   06:00 - 08:00         │
└─────────────────────────┘
```
- Tampilkan status (done/pending)
- Tampilkan waktu jika scheduled
- Arrow/icon untuk indicate "clickable"

---

## ✅ Confirmed Decisions

| Question | Decision |
|----------|----------|
| Editor engine? | ✅ **Markdown Support** - clean UI, populer untuk produktivitas modern |
| Notes attach ke Milestone? | ✅ **Ya** - fitur bagus untuk pengorganisasian |
| Collaborative editing? | ⏳ **Future** - tidak untuk MVP |
