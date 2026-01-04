import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a user-owned option for a property (tag, priority, etc.)
class UserPropertyOption extends Equatable {
  final String id;
  final String userId;
  final String propertyId;
  final String optionId;
  final String label;
  final Color? color;
  final String? icon;
  final int orderIndex;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPropertyOption({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.optionId,
    required this.label,
    this.color,
    this.icon,
    this.orderIndex = 0,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserPropertyOption copyWith({
    String? optionId,
    String? label,
    Color? color,
    String? icon,
    int? orderIndex,
    bool? isDefault,
  }) {
    return UserPropertyOption(
      id: id,
      userId: userId,
      propertyId: propertyId,
      optionId: optionId ?? this.optionId,
      label: label ?? this.label,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      orderIndex: orderIndex ?? this.orderIndex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        propertyId,
        optionId,
        label,
        color,
        icon,
        orderIndex,
        isDefault,
        createdAt,
        updatedAt,
      ];
}
