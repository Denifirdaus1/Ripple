import 'package:equatable/equatable.dart';

/// Represents a link between a folder and an entity (Note or Todo).
/// This is the junction table record.
class FolderItem extends Equatable {
  final String id;
  final String folderId;
  final String entityType; // 'note' or 'todo'
  final String entityId;
  final int orderIndex;
  final DateTime addedAt;

  const FolderItem({
    required this.id,
    required this.folderId,
    required this.entityType,
    required this.entityId,
    this.orderIndex = 0,
    required this.addedAt,
  });

  /// Check if this item is a note
  bool get isNote => entityType == 'note';

  /// Check if this item is a todo
  bool get isTodo => entityType == 'todo';

  FolderItem copyWith({
    String? id,
    String? folderId,
    String? entityType,
    String? entityId,
    int? orderIndex,
    DateTime? addedAt,
  }) {
    return FolderItem(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      orderIndex: orderIndex ?? this.orderIndex,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        folderId,
        entityType,
        entityId,
        orderIndex,
        addedAt,
      ];
}
