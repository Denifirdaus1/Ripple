import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../domain/entities/entities.dart';

/// Bold text formatting tool
class BoldTool extends ToolDefinition {
  @override String get id => 'bold';
  @override String get name => 'Bold';
  @override IconData get icon => Icons.format_bold;
  @override ToolCategory get category => ToolCategory.formatting;
  @override int get order => 100;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    return ctrl.getSelectionStyle().containsKey(Attribute.bold.key);
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.bold, null));
    } else {
      ctrl.formatSelection(Attribute.bold);
    }
  }
}

/// Italic text formatting tool
class ItalicTool extends ToolDefinition {
  @override String get id => 'italic';
  @override String get name => 'Italic';
  @override IconData get icon => Icons.format_italic;
  @override ToolCategory get category => ToolCategory.formatting;
  @override int get order => 101;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    return ctrl.getSelectionStyle().containsKey(Attribute.italic.key);
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.italic, null));
    } else {
      ctrl.formatSelection(Attribute.italic);
    }
  }
}

/// Underline text formatting tool
class UnderlineTool extends ToolDefinition {
  @override String get id => 'underline';
  @override String get name => 'Underline';
  @override IconData get icon => Icons.format_underlined;
  @override ToolCategory get category => ToolCategory.formatting;
  @override int get order => 102;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    return ctrl.getSelectionStyle().containsKey(Attribute.underline.key);
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.underline, null));
    } else {
      ctrl.formatSelection(Attribute.underline);
    }
  }
}

/// Strikethrough text formatting tool
class StrikeTool extends ToolDefinition {
  @override String get id => 'strike';
  @override String get name => 'Strikethrough';
  @override IconData get icon => Icons.strikethrough_s;
  @override ToolCategory get category => ToolCategory.formatting;
  @override int get order => 103;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    return ctrl.getSelectionStyle().containsKey(Attribute.strikeThrough.key);
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.strikeThrough, null));
    } else {
      ctrl.formatSelection(Attribute.strikeThrough);
    }
  }
}

/// Header formatting tool (cycles H1 -> H2 -> H3 -> normal)
class HeaderTool extends ToolDefinition {
  @override String get id => 'header';
  @override String get name => 'Header';
  @override IconData get icon => Icons.title;
  @override ToolCategory get category => ToolCategory.formatting;
  @override int get order => 104;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    final style = ctrl.getSelectionStyle();
    return style.attributes.containsKey(Attribute.header.key);
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    
    final style = ctrl.getSelectionStyle();
    final current = style.attributes[Attribute.header.key];
    
    if (current == null || current.value == null) {
      ctrl.formatSelection(Attribute.h1);
    } else if (current.value == 1) {
      ctrl.formatSelection(Attribute.h2);
    } else if (current.value == 2) {
      ctrl.formatSelection(Attribute.h3);
    } else {
      ctrl.formatSelection(Attribute.clone(Attribute.header, null));
    }
  }
}
