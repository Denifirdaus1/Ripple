import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import '../../property_registry.dart';
import 'property_row.dart';

/// A section displaying multiple properties for an entity.
/// Automatically renders appropriate UI for each property type.
class PropertySection extends StatelessWidget {
  /// List of property IDs to display
  final List<String> propertyIds;
  
  /// Current property values
  final PropertyValueMap values;
  
  /// Callback when a property value changes
  final void Function(String propertyId, dynamic value)? onValueChanged;
  
  /// Callback when a property row is tapped
  final void Function(String propertyId)? onPropertyTap;
  
  /// Custom value widgets for specific properties
  final Map<String, Widget>? customValueWidgets;
  
  /// Whether to show dividers between properties
  final bool showDividers;

  const PropertySection({
    super.key,
    required this.propertyIds,
    required this.values,
    this.onValueChanged,
    this.onPropertyTap,
    this.customValueWidgets,
    this.showDividers = false,
  });

  @override
  Widget build(BuildContext context) {
    final registry = PropertyRegistry();
    final definitions = propertyIds
        .map((id) => registry.get(id))
        .whereType<PropertyDefinition>()
        .toList();

    if (definitions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < definitions.length; i++) ...[
          PropertyRow(
            definition: definitions[i],
            value: values.getValue(definitions[i].id),
            valueWidget: customValueWidgets?[definitions[i].id],
            onTap: onPropertyTap != null 
                ? () => onPropertyTap!(definitions[i].id)
                : null,
          ),
          if (showDividers && i < definitions.length - 1)
            const Divider(height: 1),
        ],
      ],
    );
  }
}

/// Button to add a new property to an entity
class AddPropertyButton extends StatelessWidget {
  /// Callback when button is tapped
  final VoidCallback? onTap;
  
  /// Label text
  final String label;

  const AddPropertyButton({
    super.key,
    this.onTap,
    this.label = 'Tambah properti',
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
            Icon(
              Icons.add,
              size: 18,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
