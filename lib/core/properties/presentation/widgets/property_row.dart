import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../domain/entities/entities.dart';

/// A single row displaying a property name and its value.
/// Tappable to edit the property value.
class PropertyRow extends StatelessWidget {
  /// The property definition
  final PropertyDefinition definition;
  
  /// The current value (can be null)
  final dynamic value;
  
  /// Callback when row is tapped
  final VoidCallback? onTap;
  
  /// Custom widget to display the value (overrides default rendering)
  final Widget? valueWidget;

  const PropertyRow({
    super.key,
    required this.definition,
    this.value,
    this.onTap,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Icon(
              definition.icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            
            // Label
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
            
            // Value
            Expanded(
              child: valueWidget ?? _buildDefaultValue(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultValue() {
    final hasValue = _hasValue();
    
    return Text(
      hasValue ? _formatValue() : 'Kosong',
      style: TextStyle(
        color: hasValue 
            ? AppColors.textPrimary 
            : AppColors.textSecondary.withOpacity(0.5),
        fontSize: 14,
      ),
    );
  }

  bool _hasValue() {
    if (value == null) return false;
    if (value is String) return (value as String).isNotEmpty;
    if (value is List) return (value as List).isNotEmpty;
    return true;
  }

  String _formatValue() {
    switch (definition.type) {
      case PropertyType.date:
        if (value is DateTime) {
          final dt = value as DateTime;
          return '${dt.day}/${dt.month}/${dt.year}';
        }
        return value.toString();
        
      case PropertyType.datetime:
        if (value is DateTime) {
          final dt = value as DateTime;
          return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        }
        return value.toString();
        
      case PropertyType.select:
        // Find option label
        final option = definition.options.where((o) => o.id == value).firstOrNull;
        return option?.label ?? value.toString();
        
      case PropertyType.multiSelect:
        if (value is List) {
          final labels = (value as List).map((v) {
            final option = definition.options.where((o) => o.id == v).firstOrNull;
            return option?.label ?? v.toString();
          }).toList();
          return labels.join(', ');
        }
        return value.toString();
        
      case PropertyType.checkbox:
        return (value == true) ? 'Ya' : 'Tidak';
        
      default:
        return value.toString();
    }
  }
}
