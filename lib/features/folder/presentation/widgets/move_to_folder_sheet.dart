import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/folder.dart';
import '../bloc/folder_bloc.dart';

/// Bottom sheet for selecting a folder to move an item to.
class MoveToFolderSheet extends StatefulWidget {
  final String entityType; // 'note' or 'todo'
  final String entityId;
  final String? currentFolderId;

  const MoveToFolderSheet({
    super.key,
    required this.entityType,
    required this.entityId,
    this.currentFolderId,
  });

  /// Show the sheet and returns true if moved, false if cancelled.
  static Future<bool> show(
    BuildContext context, {
    required String entityType,
    required String entityId,
    String? currentFolderId,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.paperWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<FolderBloc>(),
        child: MoveToFolderSheet(
          entityType: entityType,
          entityId: entityId,
          currentFolderId: currentFolderId,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  State<MoveToFolderSheet> createState() => _MoveToFolderSheetState();
}

class _MoveToFolderSheetState extends State<MoveToFolderSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, state) {
        return SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.outlineGray),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.drive_file_move_rounded,
                          color: AppColors.rippleBlue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Move to Folder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Inbox option (remove from all folders)
                  _FolderOption(
                    icon: Icons.inbox_rounded,
                    name: 'Inbox (No Folder)',
                    isSelected: widget.currentFolderId == null,
                    onTap: _isLoading ? null : () => _removeFromFolder(context),
                  ),

                  const Divider(height: 1),

                  // Folder list
                  if (state.folders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No folders yet.\nCreate one from the Folders menu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.folders.length,
                        itemBuilder: (context, index) {
                          final folder = state.folders[index];
                          return _FolderOption(
                            icon: Icons.folder_rounded,
                            name: folder.name,
                            color: folder.color != null
                                ? _parseColor(folder.color!)
                                : null,
                            isSelected: folder.id == widget.currentFolderId,
                            onTap: _isLoading
                                ? null
                                : () => _moveToFolder(context, folder),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
              // Loading overlay
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _moveToFolder(BuildContext context, Folder folder) async {
    setState(() => _isLoading = true);

    // Remove from current folder first if applicable
    if (widget.currentFolderId != null) {
      context.read<FolderBloc>().add(
        FolderItemRemoved(
          widget.currentFolderId!,
          widget.entityType,
          widget.entityId,
        ),
      );
    }
    // Add to new folder
    context.read<FolderBloc>().add(
      FolderItemAdded(folder.id, widget.entityType, widget.entityId),
    );

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pop(true);
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil dipindahkan ke "${folder.name}"'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _removeFromFolder(BuildContext context) async {
    setState(() => _isLoading = true);

    if (widget.currentFolderId != null) {
      context.read<FolderBloc>().add(
        FolderItemRemoved(
          widget.currentFolderId!,
          widget.entityType,
          widget.entityId,
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dipindahkan ke Inbox'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
      return AppColors.textSecondary;
    } catch (_) {
      return AppColors.textSecondary;
    }
  }
}

class _FolderOption extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FolderOption({
    required this.icon,
    required this.name,
    this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isSelected ? AppColors.rippleBlue.withOpacity(0.1) : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color:
                  color ??
                  (isSelected ? AppColors.rippleBlue : AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.rippleBlue
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 20, color: AppColors.rippleBlue),
          ],
        ),
      ),
    );
  }
}
