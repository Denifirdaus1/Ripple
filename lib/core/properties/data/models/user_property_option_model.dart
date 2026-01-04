import 'package:flutter/material.dart';
import '../../domain/entities/user_property_option.dart';

/// Model for UserPropertyOption with JSON serialization
class UserPropertyOptionModel extends UserPropertyOption {
  const UserPropertyOptionModel({
    required super.id,
    required super.userId,
    required super.propertyId,
    required super.optionId,
    required super.label,
    super.color,
    super.icon,
    super.orderIndex,
    super.isDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserPropertyOptionModel.fromJson(Map<String, dynamic> json) {
    return UserPropertyOptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      propertyId: json['property_id'] as String,
      optionId: json['option_id'] as String,
      label: json['label'] as String,
      color: json['color'] != null ? _parseColor(json['color'] as String) : null,
      icon: json['icon'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'option_id': optionId,
      'label': label,
      'color': color != null ? _colorToHex(color!) : null,
      'icon': icon,
      'order_index': orderIndex,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For insert (without id and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'property_id': propertyId,
      'option_id': optionId,
      'label': label,
      'color': color != null ? _colorToHex(color!) : null,
      'icon': icon,
      'order_index': orderIndex,
      'is_default': isDefault,
    };
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
