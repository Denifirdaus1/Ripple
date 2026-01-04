import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'property_type.dart';
import 'property_option.dart';

/// Defines a property's structure, type, and metadata.
/// This is the "schema" for a property - it defines what kind of property it is.
class PropertyDefinition extends Equatable {
  /// Unique identifier for this property definition
  final String id;
  
  /// Display name (e.g., "Tanggal", "Prioritas", "Tag")
  final String name;
  
  /// The type of this property (determines UI widget)
  final PropertyType type;
  
  /// Icon to display alongside the property
  final IconData icon;
  
  /// Optional description/help text
  final String? description;
  
  /// Available options (required for select/multiSelect types)
  final List<PropertyOption> options;
  
  /// Default value for new entities
  final dynamic defaultValue;
  
  /// Whether this property is required
  final bool isRequired;
  
  /// Whether this property is a system property (cannot be deleted by user)
  final bool isSystem;
  
  /// Display order in the property list
  final int order;
  
  /// Placeholder text for input
  final String? placeholder;

  const PropertyDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.description,
    this.options = const [],
    this.defaultValue,
    this.isRequired = false,
    this.isSystem = false,
    this.order = 0,
    this.placeholder,
  });

  /// Validates that the definition is complete
  bool get isValid {
    if (type.requiresOptions && options.isEmpty) {
      return false;
    }
    return name.isNotEmpty;
  }

  /// Creates a copy with updated values
  PropertyDefinition copyWith({
    String? id,
    String? name,
    PropertyType? type,
    IconData? icon,
    String? description,
    List<PropertyOption>? options,
    dynamic defaultValue,
    bool? isRequired,
    bool? isSystem,
    int? order,
    String? placeholder,
  }) {
    return PropertyDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      options: options ?? this.options,
      defaultValue: defaultValue ?? this.defaultValue,
      isRequired: isRequired ?? this.isRequired,
      isSystem: isSystem ?? this.isSystem,
      order: order ?? this.order,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        icon,
        description,
        options,
        defaultValue,
        isRequired,
        isSystem,
        order,
        placeholder,
      ];
}
