import '../entities/folder.dart';
import '../entities/folder_item.dart';
import '../entities/folder_contents.dart';
import '../repositories/folder_repository.dart';

// ============================================
// Stream Use Cases
// ============================================

/// Get real-time stream of all folders
class GetFoldersStream {
  final FolderRepository repository;
  GetFoldersStream(this.repository);
  Stream<List<Folder>> call() => repository.getFoldersStream();
}

// ============================================
// Query Use Cases
// ============================================

/// Get hydrated contents of a folder
class GetFolderContents {
  final FolderRepository repository;
  GetFolderContents(this.repository);
  Future<FolderContents> call(String folderId) =>
      repository.getFolderContents(folderId);
}

/// Get items not in any folder (Inbox)
class GetInboxContents {
  final FolderRepository repository;
  GetInboxContents(this.repository);
  Future<FolderContents> call() => repository.getInboxContents();
}

// ============================================
// Mutation Use Cases
// ============================================

/// Create a new folder
class CreateFolder {
  final FolderRepository repository;
  CreateFolder(this.repository);
  Future<Folder> call(Folder folder) => repository.createFolder(folder);
}

/// Update an existing folder
class UpdateFolder {
  final FolderRepository repository;
  UpdateFolder(this.repository);
  Future<Folder> call(Folder folder) => repository.updateFolder(folder);
}

/// Delete a folder
class DeleteFolder {
  final FolderRepository repository;
  DeleteFolder(this.repository);
  Future<void> call(String folderId) => repository.deleteFolder(folderId);
}

/// Add item to folder
class AddItemToFolder {
  final FolderRepository repository;
  AddItemToFolder(this.repository);
  Future<FolderItem> call(String folderId, String entityType, String entityId) =>
      repository.addItemToFolder(folderId, entityType, entityId);
}

/// Remove item from folder
class RemoveItemFromFolder {
  final FolderRepository repository;
  RemoveItemFromFolder(this.repository);
  Future<void> call(String folderId, String entityType, String entityId) =>
      repository.removeItemFromFolder(folderId, entityType, entityId);
}

/// Move folder to new parent
class MoveFolder {
  final FolderRepository repository;
  MoveFolder(this.repository);
  Future<void> call(String folderId, String? newParentId) =>
      repository.moveFolder(folderId, newParentId);
}
