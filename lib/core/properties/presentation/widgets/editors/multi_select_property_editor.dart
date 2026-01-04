import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../domain/entities/entities.dart';

/// Multi-select picker for multiSelect properties (tags)
class MultiSelectPropertyEditor extends StatelessWidget {
  final PropertyDefinition definition;
  final List<String> values;
  final void Function(List<String>) onChanged;
  final List<PropertyOption> availableOptions;

  const MultiSelectPropertyEditor({
    super.key,
    required this.definition,
    this.values = const [],
    required this.onChanged,
    this.availableOptions = const [],
  });

  List<PropertyOption> get _options => 
      availableOptions.isNotEmpty ? availableOptions : definition.options;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showMultiSelectSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(definition.icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Text(
                definition.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: values.isEmpty
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
                      children: values.map((v) {
                        final option = _options.where((o) => o.id == v).firstOrNull;
                        return _buildChip(option?.label ?? v, option?.color);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showMultiSelectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _MultiSelectSheet(
        definition: definition,
        selectedValues: values,
        options: _options,
        onChanged: (newValues) {
          onChanged(newValues);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  final PropertyDefinition definition;
  final List<String> selectedValues;
  final List<PropertyOption> options;
  final void Function(List<String>) onChanged;

  const _MultiSelectSheet({
    required this.definition,
    required this.selectedValues,
    required this.options,
    required this.onChanged,
  });

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedValues);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih ${widget.definition.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => widget.onChanged(_selected),
                  child: const Text('Selesai'),
                ),
              ],
            ),
          ),
          
          // Options
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = _selected.contains(option.id);
                
                return ListTile(
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: option.color ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(option.label),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.rippleBlue)
                      : null,
                  onTap: () => _toggle(option.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
