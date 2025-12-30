# PLAN_008: Implement Brand Identity & Design System

**ID:** PLAN_008 | **Status:** 🏗️ In Progress | **Prioritas:** 🔴 High
**Terkait:** [TOPIC_002](../Topic/TOPIC_002_brand_identity.md)
**Constraint:** Flutter Theme, Google Fonts, Custom Widgets

---

# Goal Description
Translate the "Cozy Productivity" visual identity into a reusable Flutter Design System. This will be the foundation for all feature implementation (Todo, Notes, etc.).

The goal is to provide a unified `AppTheme` and a set of "Primitive Widgets" so that we don't hardcode colors or styles in feature pages.

## User Review Required
> [!IMPORTANT]
> **Asset Strategy**:
> - **Fonts**: We will use `google_fonts` package to load Nunito and DM Sans. This avoids manual asset management and reduces repo size.
> - **Icons**: We will use `phosphor_flutter` or `lucide_icons` (if available) or standard Cupertino/Material icons styled to look "Line Art". *Recommendation: Phosphor Icons (Regular/Fill variants match the brief perfectly).*
> - **Mascot**: We will create a placeholder `AppMascot` widget. The user can drop SVGs into `assets/images/` later.

---

## Proposed Changes

### 1. Core Layer (Theming)
#### [NEW] [lib/core/theme]
- `app_colors.dart`: Static definitions of the Palette (Paper White, Ripple Blue, etc.).
- `app_typography.dart`: `TextTheme` configuration using Google Fonts.
- `app_theme.dart`: Assemble `ThemeData` (Light Mode only for MVP as per "Paper White" brief).
    - `scaffoldBackgroundColor`: Paper White.
    - `cardTheme`: Elevation 0, Border Gray.
    - `elevatedButtonTheme`: Stadium border, Ripple Blue.

### 2. Core UI Components (Primitives)
#### [NEW] [lib/core/widgets]
- `ripple_card.dart`: Container with specific border/radius logic.
- `ripple_button.dart`: Primary (Blue), Secondary (Soft Gray), Ghost (Text) variants.
- `ripple_input.dart`: TextField with soft background and no strict borders.
- `ripple_page_header.dart`: Standard header with "Headline" typography.

### 3. Assets
#### [MODIFY] [pubspec.yaml](file:///c:/Project/ripple/pubspec.yaml)
- Add `google_fonts`.
- Add `flutter_svg`.
- Add `phosphor_flutter`.

---

## Verification Plan

### Automated Tests
- Widget test for `AppTheme` to ensure it applies correct font family.

### Manual Verification
1.  **Kitchen Sink Page**: Create a temporary page `lib/features/kitchen_sink.dart`.
2.  **Verify Typography**: Check "Display Large", "Headline", "Body" rendering with correct Fonts.
3.  **Verify Colors**: Check Buttons (Blue), Warnings (Orange), Success (Green).
4.  **Verify Shape**: Check Buttons and Cards have rounded corners (Radius 24).
