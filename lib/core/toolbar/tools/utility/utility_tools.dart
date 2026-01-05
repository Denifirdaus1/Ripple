import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../domain/entities/entities.dart';

/// Undo tool
class UndoTool extends ToolDefinition {
  @override String get id => 'undo';
  @override String get name => 'Undo';
  @override IconData get icon => Icons.undo;
  @override ToolCategory get category => ToolCategory.utility;
  @override int get order => 500;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) {
    return context.quillController?.hasUndo ?? false;
  }

  @override
  void execute(ToolContext context) {
    context.quillController?.undo();
  }
}

/// Redo tool
class RedoTool extends ToolDefinition {
  @override String get id => 'redo';
  @override String get name => 'Redo';
  @override IconData get icon => Icons.redo;
  @override ToolCategory get category => ToolCategory.utility;
  @override int get order => 501;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) {
    return context.quillController?.hasRedo ?? false;
  }

  @override
  void execute(ToolContext context) {
    context.quillController?.redo();
  }
}

/// Link insertion tool
class LinkTool extends ToolDefinition {
  @override String get id => 'link';
  @override String get name => 'Link';
  @override IconData get icon => Icons.link;
  @override ToolCategory get category => ToolCategory.utility;
  @override int get order => 502;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => context.quillController != null;

  @override
  void execute(ToolContext context) async {
    final ctrl = context.quillController;
    if (ctrl == null) return;
    
    final textController = TextEditingController();
    final url = await showDialog<String>(
      context: context.buildContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Insert Link'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            labelText: 'URL',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, textController.text),
            child: const Text('Insert'),
          ),
        ],
      ),
    );
    
    if (url != null && url.isNotEmpty) {
      ctrl.formatSelection(LinkAttribute(url));
    }
  }
}

/// Mention tool
class MentionTool extends ToolDefinition {
  @override String get id => 'mention';
  @override String get name => 'Mention';
  @override IconData get icon => Icons.alternate_email;
  @override ToolCategory get category => ToolCategory.utility;
  @override int get order => 503;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => context.onMentionTap != null;

  @override
  void execute(ToolContext context) {
    context.onMentionTap?.call();
  }
}

/// Notification reminder tool (placeholder)
class NotificationTool extends ToolDefinition {
  @override String get id => 'notification';
  @override String get name => 'Notification';
  @override IconData get icon => Icons.notifications_none_outlined;
  @override ToolCategory get category => ToolCategory.utility;
  @override int get order => 504;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => false; // Not implemented yet

  @override
  void execute(ToolContext context) {
    // TODO: Implement notification reminder
  }
}

/// Hide keyboard tool
class HideKeyboardTool extends ToolDefinition {
  @override String get id => 'hide_keyboard';
  @override String get name => 'Hide Keyboard';
  @override IconData get icon => Icons.keyboard_hide_outlined;
  @override ToolCategory get category => ToolCategory.utility;
  @override int get order => 599;
  @override bool get isSystem => true;

  @override
  bool isActive(ToolContext context) => false;

  @override
  bool isEnabled(ToolContext context) => context.onHideKeyboard != null;

  @override
  void execute(ToolContext context) {
    context.onHideKeyboard?.call();
  }
}
