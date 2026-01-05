import 'package:equatable/equatable.dart';

/// Represents a folder that can contain Notes and Todos.
/// Folders can be nested (parent_folder_id) to create hierarchy.
class Folder extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? parentFolderId;
  final String? icon;
  final String? color;
  final int orderIndex;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Folder({
    required this.id,
    required this.userId,
    required this.name,
    this.parentFolderId,
    this.icon,
    this.color,
    this.orderIndex = 0,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an empty folder for new folder creation
  factory Folder.empty() => Folder(
        id: '',
        userId: '',
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Folder copyWith({
    String? id,
    String? userId,
    String? name,
    String? parentFolderId,
    String? icon,
    String? color,
    int? orderIndex,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        parentFolderId,
        icon,
        color,
        orderIndex,
        isSystem,
        createdAt,
        updatedAt,
      ];
}
