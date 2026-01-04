import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/note_tag.dart';

/// Bottom sheet for selecting and managing tags
class TagSelectorSheet extends StatefulWidget {
  final List<String> selectedTags;
  final List<NoteTag> availableTags;
  final Function(String) onTagSelected;
  final Function(String) onTagRemoved;
  final Function(String name, String colorHex) onTagCreated;

  const TagSelectorSheet({
    super.key,
    required this.selectedTags,
    required this.availableTags,
    required this.onTagSelected,
    required this.onTagRemoved,
    required this.onTagCreated,
  });

  @override
  State<TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<TagSelectorSheet> {
  final TextEditingController _controller = TextEditingController();
  String _selectedColor = '#4A5568'; // Default gray

  // Preset colors for tags
  static const List<String> _presetColors = [
    '#4A5568', // Gray
    '#D69E2E', // Yellow/Gold
    '#C53030', // Red
    '#2B6CB0', // Blue
    '#38A169', // Green
    '#805AD5', // Purple
    '#DD6B20', // Orange
    '#319795', // Teal
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<NoteTag> get _allTags {
    // Combine defaults with user tags, avoiding duplicates
    final userTagNames = widget.availableTags.map((t) => t.name).toSet();
    final defaults = NoteTag.defaults.where((d) => !userTagNames.contains(d.name)).toList();
    return [...defaults, ...widget.availableTags];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Tag',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Selected tags
            if (widget.selectedTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.selectedTags.map((tag) {
                      final tagDef = _findTag(tag);
                      return _SelectedTagChip(
                        name: tag,
                        color: tagDef?.color ?? Colors.grey,
                        onRemove: () => widget.onTagRemoved(tag),
                      );
                    }).toList(),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Instruction
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pilih opsi atau buat opsi',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Available tags list
            ...(_allTags.map((tag) => _TagOption(
              tag: tag,
              isSelected: widget.selectedTags.contains(tag.name),
              onTap: () {
                if (widget.selectedTags.contains(tag.name)) {
                  widget.onTagRemoved(tag.name);
                } else {
                  widget.onTagSelected(tag.name);
                }
              },
            ))),
            
            const Divider(),
            
            // Create new tag
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buat tag baru',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Nama tag...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _createTag,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Color picker
                  Wrap(
                    spacing: 8,
                    children: _presetColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _hexToColor(color),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: _hexToColor(color), blurRadius: 4)]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createTag() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    
    widget.onTagCreated(name, _selectedColor);
    widget.onTagSelected(name);
    _controller.clear();
  }

  NoteTag? _findTag(String name) {
    try {
      return _allTags.firstWhere((t) => t.name == name);
    } catch (_) {
      return null;
    }
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class _SelectedTagChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onRemove;

  const _SelectedTagChip({
    required this.name,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}

class _TagOption extends StatelessWidget {
  final NoteTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagOption({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tag.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag.name,
                style: TextStyle(
                  color: tag.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, size: 18, color: AppColors.rippleBlue),
            const SizedBox(width: 8),
            const Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
