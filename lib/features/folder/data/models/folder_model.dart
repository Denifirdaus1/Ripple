import '../../domain/entities/folder.dart';

/// Data model for Folder with JSON serialization for Supabase.
class FolderModel extends Folder {
  const FolderModel({
    required super.id,
    required super.userId,
    required super.name,
    super.parentFolderId,
    super.icon,
    super.color,
    super.orderIndex,
    super.isSystem,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Supabase JSON response
  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      parentFolderId: json['parent_folder_id'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      isSystem: json['is_system'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Create from domain entity
  factory FolderModel.fromEntity(Folder folder) {
    return FolderModel(
      id: folder.id,
      userId: folder.userId,
      name: folder.name,
      parentFolderId: folder.parentFolderId,
      icon: folder.icon,
      color: folder.color,
      orderIndex: folder.orderIndex,
      isSystem: folder.isSystem,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'parent_folder_id': parentFolderId,
      'icon': icon,
      'color': color,
      'order_index': orderIndex,
      'is_system': isSystem,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id for auto-gen)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    if (id.isEmpty) {
      json.remove('id');
    }
    return json;
  }
}
