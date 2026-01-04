import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a single option for select/multiSelect property types
class PropertyOption extends Equatable {
  /// Unique identifier for the option
  final String id;
  
  /// Display label
  final String label;
  
  /// Optional color for visual distinction (e.g., for tags)
  final Color? color;
  
  /// Optional icon
  final IconData? icon;
  
  /// Order for display purposes
  final int order;

  const PropertyOption({
    required this.id,
    required this.label,
    this.color,
    this.icon,
    this.order = 0,
  });

  /// Creates a copy with updated values
  PropertyOption copyWith({
    String? id,
    String? label,
    Color? color,
    IconData? icon,
    int? order,
  }) {
    return PropertyOption(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, label, color, icon, order];
}
