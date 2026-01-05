import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';

/// Redesigned Note Card with consistent icon and property chips
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Icon + Description preview + Favorite star
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                // Description preview (if exists)
                if (note.description != null && note.description!.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        note.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // Spacer if no description
                if (note.description == null || note.description!.isEmpty)
                  const Spacer(),
                // Favorite star indicator
                if (note.isFavorite)
                  const Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.amber,
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              note.title.isNotEmpty ? note.title : 'Tanpa Judul',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Properties row
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Date
                if (note.noteDate != null)
                  _PropertyChip(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat('dd MMM').format(note.noteDate!),
                    color: AppColors.textSecondary,
                  ),
                
                // Priority - now as full chip like tags
                if (note.priority != null)
                  _PriorityChip(priority: note.priority!),
                
                // Status chip with dot indicator
                if (note.status != null)
                  _StatusChip(status: note.status!),
                
                // Tags (show all tags)
                ...note.tags.map((tag) => _TagChip(tag: tag)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Priority chip with full text and background color (like tags)
class _PriorityChip extends StatelessWidget {
  final NotePriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      NotePriority.high => ('Penting', Colors.red),
      NotePriority.medium => ('Sedang', Colors.orange),
      NotePriority.low => ('Rendah', Colors.blue),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// Tag chip
class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary.withOpacity(0.8),
        ),
      ),
    );
  }
}

/// Generic property chip with icon
class _PropertyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PropertyChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

/// Status chip with dot indicator (matches reference image)
class _StatusChip extends StatelessWidget {
  final NoteWorkStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      NoteWorkStatus.notStarted => ('Belum Dimulai', const Color(0xFF6B7280)),
      NoteWorkStatus.inProgress => ('Sedang Berjalan', const Color(0xFF3B82F6)),
      NoteWorkStatus.done => ('Selesai', const Color(0xFF10B981)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
