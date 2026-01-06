import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../todo/data/models/todo_model.dart';
import '../../../todo/domain/entities/todo.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/folder_item.dart';
import '../../domain/entities/folder_contents.dart';
import '../../domain/repositories/folder_repository.dart';
import '../models/folder_model.dart';
import '../models/folder_item_model.dart';

/// Supabase implementation of FolderRepository.
/// Uses batch fetching to avoid N+1 queries.
class FolderRepositoryImpl implements FolderRepository {
  final SupabaseClient _supabase;

  FolderRepositoryImpl({required SupabaseClient supabase})
    : _supabase = supabase;

  @override
  Stream<List<Folder>> getFoldersStream() {
    AppLogger.d('Starting folders stream');
    return _supabase
        .from('folders')
        .stream(primaryKey: ['id'])
        .order('order_index', ascending: true)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => FolderModel.fromJson(json)).toList());
  }

  @override
  Future<FolderContents> getFolderContents(String folderId) async {
    try {
      AppLogger.d('Fetching folder contents: $folderId');

      // Step 1: Get all folder_items for this folder
      final itemsResponse = await _supabase
          .from('folder_items')
          .select()
          .eq('folder_id', folderId)
          .order('order_index', ascending: true);

      if (itemsResponse.isEmpty) {
        return const FolderContents();
      }

      final items = itemsResponse
          .map((json) => FolderItemModel.fromJson(json))
          .toList();

      // Step 2: Separate IDs by type
      final noteIds = items
          .where((i) => i.entityType == 'note')
          .map((i) => i.entityId)
          .toList();
      final todoIds = items
          .where((i) => i.entityType == 'todo')
          .map((i) => i.entityId)
          .toList();

      // Step 3: Batch fetch notes and todos (avoid N+1!)
      final notes = await _batchFetchNotes(noteIds);
      final todos = await _batchFetchTodos(todoIds);

      AppLogger.i(
        'Folder contents loaded: ${notes.length} notes, ${todos.length} todos',
      );
      return FolderContents(notes: notes, todos: todos);
    } catch (e, s) {
      AppLogger.e('Failed to get folder contents', e, s);
      rethrow;
    }
  }

  @override
  Future<FolderContents> getInboxContents() async {
    try {
      AppLogger.d('Fetching inbox contents (items without folder)');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Anti-join: Get notes NOT in any folder
      final notesResponse = await _supabase.rpc('get_inbox_notes');

      // Anti-join: Get todos NOT in any folder
      final todosResponse = await _supabase.rpc('get_inbox_todos');

      final notes = (notesResponse as List)
          .map((json) => NoteModel.fromJson(json))
          .toList();
      final todos = (todosResponse as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();

      AppLogger.i(
        'Inbox contents loaded: ${notes.length} notes, ${todos.length} todos',
      );
      return FolderContents(notes: notes, todos: todos);
    } catch (e, s) {
      AppLogger.e('Failed to get inbox contents', e, s);
      // Fallback: use client-side filtering if RPC not available
      return _getInboxContentsFallback();
    }
  }

  /// Fallback method using client-side anti-join
  Future<FolderContents> _getInboxContentsFallback() async {
    AppLogger.d('Using fallback inbox query');

    // Get all folder_items
    final folderItemsResponse = await _supabase
        .from('folder_items')
        .select('entity_type, entity_id');

    final noteIdsInFolders = (folderItemsResponse as List)
        .where((item) => item['entity_type'] == 'note')
        .map((item) => item['entity_id'] as String)
        .toSet();

    final todoIdsInFolders = (folderItemsResponse)
        .where((item) => item['entity_type'] == 'todo')
        .map((item) => item['entity_id'] as String)
        .toSet();

    // Get all user's notes and todos
    final allNotesResponse = await _supabase.from('notes').select();
    final allTodosResponse = await _supabase.from('todos').select();

    // Filter out items that are in folders
    final inboxNotes = (allNotesResponse as List)
        .where((json) => !noteIdsInFolders.contains(json['id']))
        .map((json) => NoteModel.fromJson(json))
        .toList();

    final inboxTodos = (allTodosResponse as List)
        .where((json) => !todoIdsInFolders.contains(json['id']))
        .map((json) => TodoModel.fromJson(json))
        .toList();

    return FolderContents(notes: inboxNotes, todos: inboxTodos);
  }

  /// Batch fetch notes by IDs
  Future<List<Note>> _batchFetchNotes(List<String> ids) async {
    if (ids.isEmpty) return [];

    final response = await _supabase.from('notes').select().inFilter('id', ids);

    return (response as List).map((json) => NoteModel.fromJson(json)).toList();
  }

  /// Batch fetch todos by IDs
  Future<List<Todo>> _batchFetchTodos(List<String> ids) async {
    if (ids.isEmpty) return [];

    final response = await _supabase.from('todos').select().inFilter('id', ids);

    return (response as List).map((json) => TodoModel.fromJson(json)).toList();
  }

  @override
  Future<Folder> createFolder(Folder folder) async {
    try {
      AppLogger.d('Creating folder: ${folder.name}');
      final model = FolderModel.fromEntity(folder);
      final response = await _supabase
          .from('folders')
          .insert(model.toInsertJson())
          .select()
          .single();

      AppLogger.i('Folder created successfully');
      return FolderModel.fromJson(response);
    } catch (e, s) {
      AppLogger.e('Failed to create folder', e, s);
      rethrow;
    }
  }

  @override
  Future<Folder> updateFolder(Folder folder) async {
    try {
      AppLogger.d('Updating folder: ${folder.id}');
      final model = FolderModel.fromEntity(folder);
      final response = await _supabase
          .from('folders')
          .update(model.toJson())
          .eq('id', folder.id)
          .select()
          .single();

      AppLogger.i('Folder updated successfully');
      return FolderModel.fromJson(response);
    } catch (e, s) {
      AppLogger.e('Failed to update folder', e, s);
      rethrow;
    }
  }

  @override
  Future<void> deleteFolder(String folderId) async {
    try {
      AppLogger.d('Deleting folder: $folderId');
      await _supabase.from('folders').delete().eq('id', folderId);
      AppLogger.i('Folder deleted successfully');
    } catch (e, s) {
      AppLogger.e('Failed to delete folder', e, s);
      rethrow;
    }
  }

  @override
  Future<FolderItem> addItemToFolder(
    String folderId,
    String entityType,
    String entityId,
  ) async {
    try {
      AppLogger.d('Adding $entityType to folder: $folderId');
      final response = await _supabase
          .from('folder_items')
          .insert({
            'folder_id': folderId,
            'entity_type': entityType,
            'entity_id': entityId,
          })
          .select()
          .single();

      AppLogger.i('Item added to folder successfully');
      return FolderItemModel.fromJson(response);
    } catch (e, s) {
      AppLogger.e('Failed to add item to folder', e, s);
      rethrow;
    }
  }

  @override
  Future<void> removeItemFromFolder(
    String folderId,
    String entityType,
    String entityId,
  ) async {
    try {
      AppLogger.d('Removing $entityType from folder: $folderId');
      await _supabase
          .from('folder_items')
          .delete()
          .eq('folder_id', folderId)
          .eq('entity_type', entityType)
          .eq('entity_id', entityId);

      AppLogger.i('Item removed from folder successfully');
    } catch (e, s) {
      AppLogger.e('Failed to remove item from folder', e, s);
      rethrow;
    }
  }

  @override
  Future<void> moveFolder(String folderId, String? newParentId) async {
    try {
      AppLogger.d('Moving folder $folderId to parent: $newParentId');

      // Check for circular dependency
      if (newParentId != null) {
        final wouldLoop = await wouldCreateCircularDependency(
          folderId,
          newParentId,
        );
        if (wouldLoop) {
          throw Exception(
            'Cannot move folder: would create circular dependency',
          );
        }
      }

      await _supabase
          .from('folders')
          .update({
            'parent_folder_id': newParentId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', folderId);

      AppLogger.i('Folder moved successfully');
    } catch (e, s) {
      AppLogger.e('Failed to move folder', e, s);
      rethrow;
    }
  }

  @override
  Future<bool> wouldCreateCircularDependency(
    String folderId,
    String? newParentId,
  ) async {
    if (newParentId == null) return false;
    if (folderId == newParentId) return true;

    // Walk up the tree from newParentId to see if we hit folderId
    String? currentId = newParentId;
    final visited = <String>{};

    while (currentId != null) {
      if (currentId == folderId) return true;
      if (visited.contains(currentId)) return true; // Already a loop!
      visited.add(currentId);

      final response = await _supabase
          .from('folders')
          .select('parent_folder_id')
          .eq('id', currentId)
          .maybeSingle();

      currentId = response?['parent_folder_id'] as String?;
    }

    return false;
  }

  @override
  Future<Set<String>> getNoteIdsInFolders() async {
    try {
      final response = await _supabase
          .from('folder_items')
          .select('entity_id')
          .eq('entity_type', 'note');

      final noteIds = <String>{};
      for (final row in response) {
        final entityId = row['entity_id'] as String?;
        if (entityId != null) {
          noteIds.add(entityId);
        }
      }
      AppLogger.d('Found ${noteIds.length} notes in folders');
      return noteIds;
    } catch (e, s) {
      AppLogger.e('Failed to get note IDs in folders', e, s);
      return {};
    }
  }

  @override
  Future<Map<String, int>> getFolderNoteCounts() async {
    try {
      final response = await _supabase
          .from('folder_items')
          .select('folder_id')
          .eq('entity_type', 'note');

      final counts = <String, int>{};
      for (final row in response) {
        final folderId = row['folder_id'] as String?;
        if (folderId != null) {
          counts[folderId] = (counts[folderId] ?? 0) + 1;
        }
      }
      AppLogger.d('Folder note counts: $counts');
      return counts;
    } catch (e, s) {
      AppLogger.e('Failed to get folder note counts', e, s);
      return {};
    }
  }
}
