import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_tag.dart';

/// Notion-style properties section for notes
class NotePropertiesSection extends StatelessWidget {
  final DateTime? noteDate;
  final List<String> tags;
  final List<NoteTag> availableTags;
  final NotePriority? priority;
  final VoidCallback onDateTap;
  final VoidCallback onTagsTap;
  final VoidCallback onPriorityTap;

  const NotePropertiesSection({
    super.key,
    this.noteDate,
    this.tags = const [],
    this.availableTags = const [],
    this.priority,
    required this.onDateTap,
    required this.onTagsTap,
    required this.onPriorityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Property
        _PropertyRow(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal',
          onTap: onDateTap,
          child: Text(
            noteDate != null 
                ? DateFormat('dd MMMM yyyy').format(noteDate!) 
                : 'Kosong',
            style: TextStyle(
              color: noteDate != null 
                  ? AppColors.textPrimary 
                  : AppColors.textSecondary.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
        
        // Tags Property
        _PropertyRow(
          icon: Icons.label_outline,
          label: 'Tag',
          onTap: onTagsTap,
          child: tags.isEmpty
              ? Text(
                  'Kosong',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags.map((tagName) {
                    final tagDef = _findTag(tagName);
                    return _TagChip(
                      name: tagName,
                      color: tagDef?.color ?? Colors.grey,
                    );
                  }).toList(),
                ),
        ),
        
        // Priority Property
        _PropertyRow(
          icon: Icons.flag_outlined,
          label: 'Prioritas',
          onTap: onPriorityTap,
          child: priority == null
              ? Text(
                  'Kosong',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                )
              : _PriorityChip(priority: priority!),
        ),
      ],
    );
  }

  NoteTag? _findTag(String name) {
    try {
      return availableTags.firstWhere((t) => t.name == name);
    } catch (_) {
      // Check defaults
      try {
        return NoteTag.defaults.firstWhere((t) => t.name == name);
      } catch (_) {
        return null;
      }
    }
  }
}

class _PropertyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final VoidCallback onTap;

  const _PropertyRow({
    required this.icon,
    required this.label,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String name;
  final Color color;

  const _TagChip({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

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
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Add Property button
class AddPropertyButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddPropertyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: AppColors.textSecondary.withOpacity(0.7)),
            const SizedBox(width: 12),
            Text(
              'Tambahkan properti',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
