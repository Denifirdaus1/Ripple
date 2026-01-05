import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/folder.dart';

/// Individual folder tile in the tree view.
/// Handles depth indentation, selection state, and folder icon/color.
class FolderTile extends StatelessWidget {
  final Folder? folder; // null = Inbox
  final bool isSelected;
  final int depth;
  final bool hasChildren;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FolderTile({
    super.key,
    this.folder,
    this.isSelected = false,
    this.depth = 0,
    this.hasChildren = false,
    this.onTap,
    this.onLongPress,
  });

  bool get isInbox => folder == null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.only(
          left: 12 + (depth * 16.0), // Indent based on depth
          right: 12,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.rippleBlue.withOpacity(0.15)
              : Colors.transparent,
          border: isSelected
              ? Border(left: BorderSide(color: AppColors.rippleBlue, width: 3))
              : null,
        ),
        child: Row(
          children: [
            // Folder icon
            Icon(
              _getIcon(),
              size: 20,
              color: _getIconColor(),
            ),
            const SizedBox(width: 10),
            // Folder name
            Expanded(
              child: Text(
                isInbox ? 'Inbox' : folder!.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.rippleBlue : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Expand indicator if has children
            if (hasChildren)
              Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (isInbox) return Icons.inbox_rounded;
    
    // Use custom icon if set
    if (folder!.icon != null) {
      return _getIconFromString(folder!.icon!);
    }
    
    return hasChildren ? Icons.folder_open_rounded : Icons.folder_rounded;
  }

  Color _getIconColor() {
    if (isInbox) return AppColors.textSecondary;
    
    // Use custom color if set
    if (folder!.color != null) {
      return _parseColor(folder!.color!);
    }
    
    return isSelected ? AppColors.rippleBlue : AppColors.textSecondary;
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return AppColors.textSecondary;
    } catch (_) {
      return AppColors.textSecondary;
    }
  }

  IconData _getIconFromString(String iconName) {
    // Map common icon names to IconData
    const iconMap = {
      'folder': Icons.folder_rounded,
      'work': Icons.work_rounded,
      'home': Icons.home_rounded,
      'star': Icons.star_rounded,
      'book': Icons.book_rounded,
      'code': Icons.code_rounded,
      'music': Icons.music_note_rounded,
      'photo': Icons.photo_rounded,
      'video': Icons.videocam_rounded,
      'travel': Icons.flight_rounded,
      'shopping': Icons.shopping_cart_rounded,
      'health': Icons.favorite_rounded,
      'finance': Icons.attach_money_rounded,
      'education': Icons.school_rounded,
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.folder_rounded;
  }
}
