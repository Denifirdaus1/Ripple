import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../property_registry.dart';
import '../../domain/entities/property_definition.dart';

/// Bottom sheet for adding a new property to an entity
class AddPropertySheet extends StatelessWidget {
  final List<String> enabledPropertyIds;
  final void Function(String propertyId) onPropertySelected;

  const AddPropertySheet({
    super.key,
    required this.enabledPropertyIds,
    required this.onPropertySelected,
  });

  @override
  Widget build(BuildContext context) {
    final registry = PropertyRegistry();
    final allProperties = registry.all;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tambah Properti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Property list
          ...allProperties.map((prop) => _PropertyItem(
            definition: prop,
            isEnabled: enabledPropertyIds.contains(prop.id),
            onTap: enabledPropertyIds.contains(prop.id)
                ? null
                : () {
                    onPropertySelected(prop.id);
                    Navigator.pop(context);
                  },
          )),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PropertyItem extends StatelessWidget {
  final PropertyDefinition definition;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _PropertyItem({
    required this.definition,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        definition.icon,
        color: isEnabled ? Colors.grey : AppColors.textSecondary,
      ),
      title: Text(
        definition.name,
        style: TextStyle(
          color: isEnabled ? Colors.grey : AppColors.textPrimary,
        ),
      ),
      trailing: isEnabled
          ? const Icon(Icons.check, color: Colors.grey, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
