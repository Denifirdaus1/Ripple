import 'package:equatable/equatable.dart';

/// Represents which properties are enabled on an entity (note, todo, etc.)
class EntityProperty extends Equatable {
  final String id;
  final String entityType;
  final String entityId;
  final String propertyId;
  final String userId;
  final DateTime createdAt;

  const EntityProperty({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.propertyId,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        propertyId,
        userId,
        createdAt,
      ];
}
