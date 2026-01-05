import '../../domain/entities/folder_item.dart';

/// Data model for FolderItem with JSON serialization for Supabase.
class FolderItemModel extends FolderItem {
  const FolderItemModel({
    required super.id,
    required super.folderId,
    required super.entityType,
    required super.entityId,
    super.orderIndex,
    required super.addedAt,
  });

  /// Create from Supabase JSON response
  factory FolderItemModel.fromJson(Map<String, dynamic> json) {
    return FolderItemModel(
      id: json['id'] as String,
      folderId: json['folder_id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  /// Create from domain entity
  factory FolderItemModel.fromEntity(FolderItem item) {
    return FolderItemModel(
      id: item.id,
      folderId: item.folderId,
      entityType: item.entityType,
      entityId: item.entityId,
      orderIndex: item.orderIndex,
      addedAt: item.addedAt,
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folder_id': folderId,
      'entity_type': entityType,
      'entity_id': entityId,
      'order_index': orderIndex,
      'added_at': addedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id for auto-gen)
  Map<String, dynamic> toInsertJson() {
    return {
      'folder_id': folderId,
      'entity_type': entityType,
      'entity_id': entityId,
      'order_index': orderIndex,
    };
  }
}
