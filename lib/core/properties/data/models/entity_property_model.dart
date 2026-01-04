import '../../domain/entities/entity_property.dart';

/// Model for EntityProperty with JSON serialization
class EntityPropertyModel extends EntityProperty {
  const EntityPropertyModel({
    required super.id,
    required super.entityType,
    required super.entityId,
    required super.propertyId,
    required super.userId,
    required super.createdAt,
  });

  factory EntityPropertyModel.fromJson(Map<String, dynamic> json) {
    return EntityPropertyModel(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      propertyId: json['property_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'property_id': propertyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// For insert (without id and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'property_id': propertyId,
      'user_id': userId,
    };
  }
}
