import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../../core/theme/app_colors.dart';

/// Keyboard toolbar with both formatting tools and quick action icons
class NoteKeyboardToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback? onMentionTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onHideKeyboard;

  const NoteKeyboardToolbar({
    super.key,
    required this.controller,
    this.onMentionTap,
    this.onImageTap,
    this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.outlineGray, width: 0.5),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // Text formatting
          _ToolbarIcon(
            icon: Icons.format_bold,
            isActive: _isStyleActive(Attribute.bold),
            onTap: () => _toggleStyle(Attribute.bold),
          ),
          _ToolbarIcon(
            icon: Icons.format_italic,
            isActive: _isStyleActive(Attribute.italic),
            onTap: () => _toggleStyle(Attribute.italic),
          ),
          _ToolbarIcon(
            icon: Icons.format_underlined,
            isActive: _isStyleActive(Attribute.underline),
            onTap: () => _toggleStyle(Attribute.underline),
          ),
          _ToolbarIcon(
            icon: Icons.strikethrough_s,
            isActive: _isStyleActive(Attribute.strikeThrough),
            onTap: () => _toggleStyle(Attribute.strikeThrough),
          ),
          
          const SizedBox(width: 8),
          
          // Headers
          _ToolbarIcon(
            icon: Icons.title,
            onTap: () => _toggleHeader(),
          ),
          
          // Lists  
          _ToolbarIcon(
            icon: Icons.format_list_bulleted,
            isActive: _isBlockActive(Attribute.ul),
            onTap: () => _toggleBlock(Attribute.ul),
          ),
          _ToolbarIcon(
            icon: Icons.format_list_numbered,
            isActive: _isBlockActive(Attribute.ol),
            onTap: () => _toggleBlock(Attribute.ol),
          ),
          _ToolbarIcon(
            icon: Icons.check_box_outlined,
            isActive: _isBlockActive(Attribute.unchecked),
            onTap: () => _toggleBlock(Attribute.unchecked),
          ),
          
          const SizedBox(width: 8),
          
          // Link & Mention
          _ToolbarIcon(
            icon: Icons.link,
            onTap: () => _insertLink(context),
          ),
          if (onMentionTap != null)
            _ToolbarIcon(
              icon: Icons.alternate_email,
              onTap: onMentionTap,
            ),
          
          const SizedBox(width: 8),
          
          // Undo/Redo
          _ToolbarIcon(
            icon: Icons.undo,
            onTap: controller.hasUndo ? () => controller.undo() : null,
          ),
          _ToolbarIcon(
            icon: Icons.redo,
            onTap: controller.hasRedo ? () => controller.redo() : null,
          ),
          
          const SizedBox(width: 8),
          
          // New quick action icons
          _ToolbarIcon(
            icon: Icons.auto_awesome_outlined,
            onTap: () {},
          ),
          _ToolbarIcon(
            icon: Icons.camera_alt_outlined,
            onTap: onImageTap,
          ),
          _ToolbarIcon(
            icon: Icons.mic_none_outlined,
            onTap: () {},
          ),
          _ToolbarIcon(
            icon: Icons.notifications_none_outlined,
            onTap: () {},
          ),
          
          // Hide keyboard
          if (onHideKeyboard != null)
            _ToolbarIcon(
              icon: Icons.keyboard_hide_outlined,
              onTap: onHideKeyboard,
            ),
        ],
      ),
    );
  }

  bool _isStyleActive(Attribute attribute) {
    final style = controller.getSelectionStyle();
    return style.containsKey(attribute.key);
  }

  bool _isBlockActive(Attribute attribute) {
    final style = controller.getSelectionStyle();
    final block = style.attributes[Attribute.list.key];
    return block?.value == attribute.value;
  }

  void _toggleStyle(Attribute attribute) {
    if (_isStyleActive(attribute)) {
      controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      controller.formatSelection(attribute);
    }
  }

  void _toggleBlock(Attribute attribute) {
    if (_isBlockActive(attribute)) {
      controller.formatSelection(Attribute.clone(Attribute.list, null));
    } else {
      controller.formatSelection(attribute);
    }
  }

  void _toggleHeader() {
    final style = controller.getSelectionStyle();
    final current = style.attributes[Attribute.header.key];
    
    if (current == null || current.value == null) {
      controller.formatSelection(Attribute.h1);
    } else if (current.value == 1) {
      controller.formatSelection(Attribute.h2);
    } else if (current.value == 2) {
      controller.formatSelection(Attribute.h3);
    } else {
      controller.formatSelection(Attribute.clone(Attribute.header, null));
    }
  }

  void _insertLink(BuildContext context) async {
    final textController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
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
      controller.formatSelection(LinkAttribute(url));
    }
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ToolbarIcon({
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 24,
          color: onTap == null
              ? AppColors.textSecondary.withOpacity(0.3)
              : (isActive ? AppColors.rippleBlue : AppColors.textPrimary),
        ),
      ),
    );
  }
}
