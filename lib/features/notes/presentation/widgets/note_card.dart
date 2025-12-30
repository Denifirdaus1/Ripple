import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_card.dart';
import '../../domain/entities/note.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  String _getPreviewText() {
    // Basic extraction from Delta JSON
    try {
      final ops = note.content['ops'] as List<dynamic>?;
      if (ops == null || ops.isEmpty) return 'No content';
      
      final buffer = StringBuffer();
      for (final op in ops) {
        if (op['insert'] is String) {
          buffer.write(op['insert']);
        }
      }
      final text = buffer.toString().trim();
      return text.isEmpty ? 'No content' : text;
    } catch (e) {
      return 'Error loading content';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RippleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title.isNotEmpty ? note.title : 'Untitled',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _getPreviewText(),
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat.yMMMd().format(note.updatedAt),
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
