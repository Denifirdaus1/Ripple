# Ripple Brand Identity & Design System

**ID:** TOPIC_002 | **Status:** 💬 Aktif | **Prioritas:** 🔴 High
**Dibuat:** 2025-12-30 | **Update:** 2025-12-30
**Tipe:** 🎨 Design & Frontend
**Related:** [TOPIC_001](../Topic/TOPIC_001_ripple_mvp/_main.md)

---

# 1. Brand Identity: "Cozy Productivity"

Menggabungkan filosofi "Ripple" (riak air) dengan estetika yang menenangkan. Tidak kaku, tidak korporat.

*   **Core Vibe**: Tenang, Mengalir, Personal, Playful.
*   **Design Language**: Soft Minimalist & Hand-Drawn Aesthetic.
*   **Filosofi Visual**: "Productivity without Pressure" — Fokus pada progres, bukan kesempurnaan.

---

# 2. Color Palette

Dasar "Kertas Putih" dengan aksen lembut namun kontras.

### 🎨 Primary & Base
| Name | Hex | Usage |
| :--- | :--- | :--- |
| **Paper White** | `#FFFFFF` | **Background Utama** (80% layar). Bersih & lapang. |
| **Ripple Blue** | `#5D9CEC` | **Primary Brand Color**. Tombol utama, link aktif, highlight. (Langit cerah lembut). |
| **Ink Black** | `#2D3436` | **Teks Utama**. (Bukan pure black `#000000` agar mata nyaman). |
| **Soft Gray** | `#F5F7FA` | **Secondary Background**. Card, input field, spacer. |

### 🌈 Semantic Accents
| Name | Hex | Usage |
| :--- | :--- | :--- |
| **Warm Tangerine** | `#FFAD60` | **Focus Mode / Warning**. Energi hangat (Playful). |
| **Sage Green** | `#A8D5BA` | **Success / Done**. Menenangkan. |
| **Coral Pink** | `#FF6B6B` | **High Priority / Error**. Mendesak tapi tidak agresif. |
| **Outline Gray** | `#E0E0E0` | **Border / Divider**. Garis tipis halus. |

---

# 3. Typography

Kombinasi **Rounded** (ramah) dan **Geometric Sans** (bacaan panjang).

### 🅰️ Font Families
1.  **Headings**: [Nunito](https://fonts.google.com/specimen/Nunito) atau [Fredoka](https://fonts.google.com/specimen/Fredoka).
    *   *Karakter*: Rounded, ramah, modern, lucu.
2.  **Body**: [DM Sans](https://fonts.google.com/specimen/DM+Sans) atau [Outfit](https://fonts.google.com/specimen/Outfit).
    *   *Karakter*: Geometris, rapi, high readability.

### 📐 Text Hierarchy (Flutter)
| Style | Font | Weight | Size | Color |
| :--- | :--- | :--- | :--- | :--- |
| **Display Large** | Nunito | Bold | 64px | Ink Black (Timer) |
| **Headline** | Nunito | Bold | 24px | Ink Black (Page Title) |
| **Body Text** | DM Sans | Regular | 16px | Ink Black (Notes, LineHeight 1.5) |
| **Caption** | DM Sans | Medium | 12px | Dark Gray (Subtext) |

---

# 4. Frontend Style Guide (Flutter Implementation)

### 🖌️ Shape & Borders
*   **Corner Radius**: Besar & Soft. `BorderRadius.circular(24.0)`.
*   **Buttons**: Stadium (Capsule) atau Rounded Rect (`20px`).
*   **Lines**: Stroke width `1.5 - 2.0px`.

### 🖼️ Illustration Style
*   **Mascot**: Bebek (Duck) / Karakter lucu.
*   **Style**: Doodle Line Art.
*   **Stroke**: Hitam tipis (`1.5px`).
*   **Fill**: Flat / Offset color (warna "keluar garis" sedikit).

### 🧱 UI Components

#### 1. Navigation Bar
*   **Inactive**: Outline / Line Icon.
*   **Active**: Solid / Filled Icon (Color: Ripple Blue).
*   **Label**: Hilangkan text label (Clean look).

#### 2. Todo List Item
*   **Background**: Putih atau Soft Gray (very light).
*   **Checkbox**: **Bulat** (Circle), bukan kotak.
*   **Done State**: Coret garis tipis, text gray.

#### 3. Cards (Notes/Milestone)
*   **Elevation**: 0 (Flat).
*   **Border**: `BorderSide(color: Color(0xFFE0E0E0), width: 1.5)`.
*   **Shadow**: None atau Ultra-soft diffuse.
