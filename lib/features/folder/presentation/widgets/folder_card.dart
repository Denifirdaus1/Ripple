import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/folder.dart';

/// Folder Card widget - displays a folder in the notes list
/// UI similar to NoteCard but with folder icon
class FolderCard extends StatelessWidget {
  final Folder folder;
  final int noteCount;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.folder,
    required this.noteCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getFolderColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getFolderColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Folder icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getFolderColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder_rounded,
                size: 24,
                color: _getFolderColor(),
              ),
            ),
            const SizedBox(width: 14),
            // Folder info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$noteCount notes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Color _getFolderColor() {
    if (folder.color != null && folder.color!.isNotEmpty) {
      try {
        if (folder.color!.startsWith('#')) {
          return Color(
            int.parse(folder.color!.substring(1), radix: 16) + 0xFF000000,
          );
        }
      } catch (_) {}
    }
    return AppColors.rippleBlue;
  }
}
