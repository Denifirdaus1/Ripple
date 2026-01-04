import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../domain/entities/entities.dart';

/// Date picker widget for date/datetime properties
class DatePropertyEditor extends StatelessWidget {
  final PropertyDefinition definition;
  final DateTime? value;
  final void Function(DateTime?) onChanged;
  final bool showClearButton;

  const DatePropertyEditor({
    super.key,
    required this.definition,
    this.value,
    required this.onChanged,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(definition.icon, color: AppColors.textSecondary),
      title: Text(definition.name),
      subtitle: Text(
        value != null 
            ? _formatDate(value!) 
            : definition.placeholder ?? 'Pilih tanggal',
        style: TextStyle(
          color: value != null 
              ? AppColors.textPrimary 
              : AppColors.textSecondary.withOpacity(0.5),
        ),
      ),
      trailing: showClearButton && value != null
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => onChanged(null),
            )
          : null,
      onTap: () => _showDatePicker(context),
    );
  }

  String _formatDate(DateTime date) {
    if (definition.type == PropertyType.datetime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (definition.type == PropertyType.datetime) {
        // Also pick time
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? now),
        );
        if (time != null) {
          onChanged(DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
        }
      } else {
        onChanged(picked);
      }
    }
  }
}
