import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/properties/properties.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_tag.dart';

/// Sandbox-style properties section for notes.
/// Shows only enabled properties with Add Property button.
class NotePropertiesSection extends StatelessWidget {
  /// List of enabled property IDs (e.g., ['date', 'tags', 'priority'])
  final List<String> enabledPropertyIds;
  
  /// Note data
  final DateTime? noteDate;
  final List<String> tags;
  final List<NoteTag> availableTags;
  final NotePriority? priority;
  
  /// Callbacks
  final VoidCallback onDateTap;
  final VoidCallback onTagsTap;
  final VoidCallback onPriorityTap;
  final void Function(String propertyId) onAddProperty;

  const NotePropertiesSection({
    super.key,
    this.enabledPropertyIds = const ['date'], // Default: only date
    this.noteDate,
    this.tags = const [],
    this.availableTags = const [],
    this.priority,
    required this.onDateTap,
    required this.onTagsTap,
    required this.onPriorityTap,
    required this.onAddProperty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Property (always visible if enabled)
        if (enabledPropertyIds.contains('date'))
          PropertyRow(
            definition: DefaultProperties.date,
            value: noteDate,
            onTap: onDateTap,
            valueWidget: Text(
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
        
        // Tags Property (if enabled)
        if (enabledPropertyIds.contains('tags'))
          PropertyRow(
            definition: DefaultProperties.tags,
            value: tags,
            onTap: onTagsTap,
            valueWidget: tags.isEmpty
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
        
        // Priority Property (if enabled)
        if (enabledPropertyIds.contains('priority'))
          PropertyRow(
            definition: DefaultProperties.priority,
            value: priority?.name,
            onTap: onPriorityTap,
            valueWidget: priority == null
                ? Text(
                    'Kosong',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  )
                : _PriorityChip(priority: priority!),
          ),
        
        // Add Property Button
        AddPropertyButton(
          onTap: () => _showAddPropertySheet(context),
        ),
      ],
    );
  }

  void _showAddPropertySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddPropertySheet(
        enabledPropertyIds: enabledPropertyIds,
        onPropertySelected: onAddProperty,
      ),
    );
  }

  NoteTag? _findTag(String name) {
    try {
      return availableTags.firstWhere((t) => t.name == name);
    } catch (_) {
      try {
        return NoteTag.defaults.firstWhere((t) => t.name == name);
      } catch (_) {
        return null;
      }
    }
  }
}

/// Tag chip widget
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

/// Priority chip widget
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
