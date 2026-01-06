import '../entities/folder.dart';
import '../entities/folder_item.dart';
import '../entities/folder_contents.dart';

/// Repository interface for folder operations.
/// Implementations handle the actual data source (Supabase).
abstract class FolderRepository {
  /// Get real-time stream of all folders for current user
  Stream<List<Folder>> getFoldersStream();

  /// Get hydrated contents of a specific folder (Notes + Todos)
  /// Uses batch fetching to avoid N+1 queries
  Future<FolderContents> getFolderContents(String folderId);

  /// Get items that are NOT in any folder (Inbox)
  /// Uses anti-join query pattern
  Future<FolderContents> getInboxContents();

  /// Create a new folder
  Future<Folder> createFolder(Folder folder);

  /// Update an existing folder
  Future<Folder> updateFolder(Folder folder);

  /// Delete a folder (items return to Inbox)
  Future<void> deleteFolder(String folderId);

  /// Add an item (Note or Todo) to a folder
  Future<FolderItem> addItemToFolder(
    String folderId,
    String entityType,
    String entityId,
  );

  /// Remove an item from a folder (item goes back to Inbox)
  Future<void> removeItemFromFolder(
    String folderId,
    String entityType,
    String entityId,
  );

  /// Move a folder to a new parent (or root if parentId is null)
  Future<void> moveFolder(String folderId, String? newParentId);

  /// Check if moving folder would create circular dependency
  Future<bool> wouldCreateCircularDependency(
    String folderId,
    String? newParentId,
  );

  /// Get all note IDs that are assigned to any folder
  Future<Set<String>> getNoteIdsInFolders();

  /// Get note counts per folder
  Future<Map<String, int>> getFolderNoteCounts();
}
