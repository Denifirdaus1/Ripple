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
  final NoteWorkStatus? status;
  final String? description;
  
  /// Callbacks
  final VoidCallback onDateTap;
  final VoidCallback onTagsTap;
  final VoidCallback onPriorityTap;
  final VoidCallback onStatusTap;
  final ValueChanged<String> onDescriptionChanged;
  final void Function(String propertyId) onAddProperty;

  const NotePropertiesSection({
    super.key,
    this.enabledPropertyIds = const ['date'], // Default: only date
    this.noteDate,
    this.tags = const [],
    this.availableTags = const [],
    this.priority,
    this.status,
    this.description,
    required this.onDateTap,
    required this.onTagsTap,
    required this.onPriorityTap,
    required this.onStatusTap,
    required this.onDescriptionChanged,
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
        
        // Status Property (if enabled)
        if (enabledPropertyIds.contains('status'))
          PropertyRow(
            definition: DefaultProperties.status,
            value: status?.name,
            onTap: onStatusTap,
            valueWidget: status == null
                ? Text(
                    'Kosong',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  )
                : _StatusChip(status: status!),
          ),
        
        // Description Property (if enabled)
        if (enabledPropertyIds.contains('description'))
          PropertyRow(
            definition: DefaultProperties.description,
            value: description,
            onTap: null,
            valueWidget: _DescriptionField(
              value: description,
              onChanged: onDescriptionChanged,
            ),
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

/// Priority chip widget - shrink-wrap width
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
        ),
      ],
    );
  }
}

/// Status chip widget with dot indicator - shrink-wrap width
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Description display widget - plain text, no form styling
class _DescriptionField extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _DescriptionField({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late TextEditingController _controller;
  bool _isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setState(() => _isEditing = false);
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(_DescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show plain text when not editing, tappable to edit
    if (!_isEditing) {
      return GestureDetector(
        onTap: () {
          setState(() => _isEditing = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNode.requestFocus();
          });
        },
        child: Text(
          widget.value?.isNotEmpty == true ? widget.value! : 'Tambahkan deskripsi...',
          style: TextStyle(
            color: widget.value?.isNotEmpty == true 
                ? AppColors.textPrimary 
                : AppColors.textSecondary.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      );
    }

    // Editing mode - invisible text field, no indicators
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      cursorColor: AppColors.textPrimary,
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        fillColor: Colors.transparent,
        filled: true,
      ),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      maxLines: null,
      onSubmitted: (value) {
        setState(() => _isEditing = false);
        widget.onChanged(value);
      },
    );
  }
}
