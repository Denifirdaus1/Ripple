import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dialog for creating a new folder.
class CreateFolderDialog extends StatefulWidget {
  final String? parentFolderId;
  final String? parentFolderName;

  const CreateFolderDialog({
    super.key,
    this.parentFolderId,
    this.parentFolderName,
  });

  /// Show the dialog and return folder name if created, null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    String? parentFolderId,
    String? parentFolderName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => CreateFolderDialog(
        parentFolderId: parentFolderId,
        parentFolderName: parentFolderName,
      ),
    );
  }

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _create() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      Navigator.pop(context, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        widget.parentFolderName != null
            ? 'New Folder in "${widget.parentFolderName}"'
            : 'New Folder',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Folder name',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.rippleBlue),
          ),
        ),
        style: TextStyle(color: AppColors.textPrimary),
        onSubmitted: (_) => _create(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _create,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rippleBlue,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
