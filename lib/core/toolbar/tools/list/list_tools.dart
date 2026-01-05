import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../domain/entities/entities.dart';

/// Bullet list tool
class BulletListTool extends ToolDefinition {
  @override String get id => 'bullet_list';
  @override String get name => 'Bullet List';
  @override IconData get icon => Icons.format_list_bulleted;
  @override ToolCategory get category => ToolCategory.list;
  @override int get order => 200;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    final block = ctrl.getSelectionStyle().attributes[Attribute.list.key];
    return block?.value == Attribute.ul.value;
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.list, null));
    } else {
      ctrl.formatSelection(Attribute.ul);
    }
  }
}

/// Numbered list tool
class NumberedListTool extends ToolDefinition {
  @override String get id => 'numbered_list';
  @override String get name => 'Numbered List';
  @override IconData get icon => Icons.format_list_numbered;
  @override ToolCategory get category => ToolCategory.list;
  @override int get order => 201;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    final block = ctrl.getSelectionStyle().attributes[Attribute.list.key];
    return block?.value == Attribute.ol.value;
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.list, null));
    } else {
      ctrl.formatSelection(Attribute.ol);
    }
  }
}

/// Checkbox list tool
class CheckboxTool extends ToolDefinition {
  @override String get id => 'checkbox';
  @override String get name => 'Checkbox';
  @override IconData get icon => Icons.check_box_outlined;
  @override ToolCategory get category => ToolCategory.list;
  @override int get order => 202;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return false;
    final block = ctrl.getSelectionStyle().attributes[Attribute.list.key];
    return block?.value == Attribute.unchecked.value;
  }

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    if (isActive(context)) {
      ctrl.formatSelection(Attribute.clone(Attribute.list, null));
    } else {
      ctrl.formatSelection(Attribute.unchecked);
    }
  }
}
