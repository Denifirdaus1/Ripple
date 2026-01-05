# PLAN_032: Toolbar Sandbox Extension System

**ID:** PLAN_032 | **Status:** ✅ Implemented | **Prioritas:** 🔴 High
**Dibuat:** 2026-01-05 | **Update:** 2026-01-05

## 🎯 Tujuan

Merancang ulang **keyboard toolbar** menjadi **extension system** yang:
1. Memiliki folder struktur sendiri (`lib/core/toolbar/`)
2. Mengikuti Clean Architecture
3. Bersifat **pluggable/extensible** - tools baru bisa ditambahkan dengan mudah
4. **Reusable** - bisa diimplementasikan di mana saja (Notes, Todo, Focus Mode, dll)
5. Tidak terikat spesifik ke Notes

---

## 📊 Analisis Current State

### Masalah Saat Ini
```
lib/features/notes/presentation/widgets/note_keyboard_toolbar.dart
```
- ❌ Hardcoded di features/notes
- ❌ Semua tools di-hardcode dalam widget
- ❌ Tidak bisa dipakai di fitur lain
- ❌ Menambah tool baru harus edit file ini

### Solusi: Registry-Based Extension Pattern
Mengikuti pattern `PropertyRegistry` yang sudah ada di `lib/core/properties/`.

---

## 🏗️ Arsitektur Baru

### Folder Structure
```
lib/core/toolbar/
├── toolbar.dart                    # Barrel export
├── toolbar_registry.dart           # Singleton registry
│
├── domain/
│   └── entities/
│       ├── entities.dart           # Barrel
│       ├── tool_definition.dart    # Base entity
│       ├── tool_category.dart      # Category enum
│       └── tool_context.dart       # Context for tool execution
│
├── presentation/
│   ├── widgets/
│   │   ├── widgets.dart            # Barrel
│   │   ├── extensible_toolbar.dart # Main reusable widget
│   │   └── toolbar_icon.dart       # Single tool icon widget
│   │
│   └── bloc/                       # (Optional) State management
│       └── toolbar_state_cubit.dart
│
└── tools/                          # Built-in tools
    ├── tools.dart                  # Barrel export
    ├── formatting/                 # Text formatting tools
    │   ├── bold_tool.dart
    │   ├── italic_tool.dart
    │   └── ...
    ├── media/                      # Media tools
    │   ├── image_tool.dart
    │   └── camera_tool.dart
    ├── ai/                         # AI tools
    │   └── ai_suggest_tool.dart
    └── utility/                    # Utility tools
        ├── undo_tool.dart
        ├── redo_tool.dart
        └── hide_keyboard_tool.dart
```

---

## 🛠️ Strategi Implementasi

### Phase 1: Domain Layer (Entities)
- [ ] Create `ToolCategory` enum (formatting, media, ai, utility)
- [ ] Create `ToolContext` class (holds QuillController, context, callbacks)
- [ ] Create `ToolDefinition` abstract class:
  ```dart
  abstract class ToolDefinition {
    String get id;
    String get name;
    IconData get icon;
    ToolCategory get category;
    int get order;
    bool get isSystem;
    
    bool isActive(ToolContext context);
    bool isEnabled(ToolContext context);
    void execute(ToolContext context);
  }
  ```

### Phase 2: Registry (Singleton)
- [ ] Create `ToolbarRegistry` following `PropertyRegistry` pattern:
  ```dart
  class ToolbarRegistry {
    void register(ToolDefinition tool);
    void unregister(String toolId);
    ToolDefinition? get(String toolId);
    List<ToolDefinition> get all;
    List<ToolDefinition> byCategory(ToolCategory category);
  }
  ```

### Phase 3: Built-in Tools
- [ ] Create formatting tools (Bold, Italic, Underline, Strike, Header)
- [ ] Create list tools (Bullet, Numbered, Checkbox)
- [ ] Create media tools (Image, Camera)
- [ ] Create utility tools (Undo, Redo, Link, HideKeyboard)
- [ ] Create AI tool placeholder

### Phase 4: Presentation Layer
- [ ] Create `ToolbarIcon` widget (stateless, reusable)
- [ ] Create `ExtensibleToolbar` widget:
  ```dart
  class ExtensibleToolbar extends StatelessWidget {
    final ToolContext context;
    final List<String>? enabledToolIds;  // null = show all
    final List<String>? disabledToolIds; // hide specific tools
    final ToolCategory? filterCategory;  // show only category
  }
  ```

### Phase 5: Migration
- [ ] Refactor `NoteKeyboardToolbar` to use `ExtensibleToolbar`
- [ ] Update `NoteEditorPage` to use new toolbar
- [ ] Remove old hardcoded toolbar

### Phase 6: Barrel Exports
- [ ] Create all barrel files for clean imports
- [ ] Update `lib/core/core.dart` to export toolbar module

---

## 📝 Technical Details

### ToolContext Class
```dart
class ToolContext {
  final BuildContext buildContext;
  final QuillController? quillController;
  final VoidCallback? onHideKeyboard;
  final VoidCallback? onImageTap;
  final VoidCallback? onMentionTap;
  // Extensible map for custom data
  final Map<String, dynamic> extra;
}
```

### Example Tool Implementation
```dart
class BoldTool extends ToolDefinition {
  @override String get id => 'bold';
  @override String get name => 'Bold';
  @override IconData get icon => Icons.format_bold;
  @override ToolCategory get category => ToolCategory.formatting;
  @override int get order => 100;
  @override bool get isSystem => true;
  
  @override
  bool isActive(ToolContext ctx) {
    return ctx.quillController?.getSelectionStyle()
        .containsKey(Attribute.bold.key) ?? false;
  }
  
  @override
  bool isEnabled(ToolContext ctx) => ctx.quillController != null;
  
  @override
  void execute(ToolContext ctx) {
    if (isActive(ctx)) {
      ctx.quillController!.formatSelection(
        Attribute.clone(Attribute.bold, null)
      );
    } else {
      ctx.quillController!.formatSelection(Attribute.bold);
    }
  }
}
```

### Usage di Feature Lain
```dart
// Di NotesEditorPage
ExtensibleToolbar(
  context: ToolContext(
    buildContext: context,
    quillController: _quillController,
    onImageTap: _handleImageTap,
  ),
)

// Di TodoDetailsPage (contoh)
ExtensibleToolbar(
  context: ToolContext(buildContext: context),
  enabledToolIds: ['ai_suggest', 'notification'],
)
```

---

## ✅ Kriteria Sukses

1. `flutter analyze` → 0 errors
2. Toolbar Notes berfungsi sama seperti sebelumnya
3. Bisa register custom tool dari luar module
4. Struktur folder sesuai Clean Architecture
5. Mudah menambah tool baru

---

## 🧪 Verification Plan

### Automated Tests
```bash
flutter analyze
flutter test test/core/toolbar/
```

### Manual Testing
1. Buka Note Editor → Toolbar muncul dengan semua tools
2. Test formatting (Bold, Italic) → Text berubah format
3. Test Image tool → Camera/Gallery muncul
4. Register custom tool dari outside module → Tool muncul di toolbar

---

## 🔗 Terkait
- [PLAN_029](PLAN_029_reusable_property_system.md) - Similar pattern reference
- [PLAN_030](PLAN_030_property_sandbox_system.md) - Registry pattern reference
