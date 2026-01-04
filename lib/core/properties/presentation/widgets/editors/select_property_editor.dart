import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../domain/entities/entities.dart';

/// Single select picker for select properties
class SelectPropertyEditor extends StatelessWidget {
  final PropertyDefinition definition;
  final String? value;
  final void Function(String?) onChanged;
  final bool showClearButton;

  const SelectPropertyEditor({
    super.key,
    required this.definition,
    this.value,
    required this.onChanged,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedOption = definition.options.where((o) => o.id == value).firstOrNull;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(definition.icon, color: AppColors.textSecondary),
      title: Text(definition.name),
      subtitle: selectedOption != null
          ? _buildOptionChip(selectedOption)
          : Text(
              definition.placeholder ?? 'Pilih ${definition.name.toLowerCase()}',
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
            ),
      trailing: showClearButton && value != null
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => onChanged(null),
            )
          : null,
      onTap: () => _showSelectSheet(context),
    );
  }

  Widget _buildOptionChip(PropertyOption option) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: option.color?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        option.label,
        style: TextStyle(
          color: option.color ?? AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showSelectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SelectOptionsSheet(
        definition: definition,
        selectedValue: value,
        onSelected: (selected) {
          onChanged(selected);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SelectOptionsSheet extends StatelessWidget {
  final PropertyDefinition definition;
  final String? selectedValue;
  final void Function(String) onSelected;

  const _SelectOptionsSheet({
    required this.definition,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        
        // Title
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Pilih ${definition.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Options
        ...definition.options.map((option) => ListTile(
          leading: option.color != null
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: option.color,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          title: Text(option.label),
          trailing: selectedValue == option.id
              ? const Icon(Icons.check, color: AppColors.rippleBlue)
              : null,
          onTap: () => onSelected(option.id),
        )),
        
        const SizedBox(height: 16),
      ],
    );
  }
}
