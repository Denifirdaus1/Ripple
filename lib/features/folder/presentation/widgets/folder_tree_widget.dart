import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/folder.dart';
import '../bloc/folder_bloc.dart';
import 'folder_tile.dart';

/// Recursive tree view widget for displaying folder hierarchy.
/// Shows Inbox as first item, followed by root folders with nested children.
class FolderTreeWidget extends StatelessWidget {
  final bool showInbox;
  final VoidCallback? onCreateFolder;

  const FolderTreeWidget({
    super.key,
    this.showInbox = true,
    this.onCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, state) {
        if (state.status == FolderStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Inbox (virtual folder)
            if (showInbox)
              FolderTile(
                folder: null, // null = Inbox
                isSelected: state.selectedFolderId == null,
                onTap: () {
                  context.read<FolderBloc>().add(const FolderSelected(null));
                },
              ),

            // Root folders
            ...state.rootFolders.map((folder) => _buildFolderNode(
                  context,
                  folder,
                  state,
                  0,
                )),

            // Create folder button
            if (onCreateFolder != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton.icon(
                  onPressed: onCreateFolder,
                  icon: Icon(Icons.add, size: 18, color: AppColors.textSecondary),
                  label: Text(
                    'New Folder',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Recursively build folder tree nodes
  Widget _buildFolderNode(
    BuildContext context,
    Folder folder,
    FolderState state,
    int depth,
  ) {
    final children = state.getChildren(folder.id);
    final isSelected = state.selectedFolderId == folder.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FolderTile(
          folder: folder,
          isSelected: isSelected,
          depth: depth,
          hasChildren: children.isNotEmpty,
          onTap: () {
            context.read<FolderBloc>().add(FolderSelected(folder.id));
          },
        ),
        // Recursively render children
        ...children.map((child) => _buildFolderNode(
              context,
              child,
              state,
              depth + 1,
            )),
      ],
    );
  }
}
