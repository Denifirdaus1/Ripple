import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';
import '../../../../features/todo/data/models/todo_model.dart';
import '../../../../features/todo/domain/entities/todo.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';
import '../../../../core/utils/logger.dart';

class NoteRepositoryImpl implements NoteRepository {
  final SupabaseClient _supabase;

  NoteRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<Note>> getNotesStream() {
    AppLogger.d('Subscribing to notes stream');
    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NoteModel.fromJson(json)).toList());
  }

  @override
  Future<Note> getNote(String id) async {
    try {
      AppLogger.d('Fetching note: $id');
      final response = await _supabase.from('notes').select().eq('id', id).single();
      return NoteModel.fromJson(response);
    } catch (e, s) {
      AppLogger.e('Failed to fetch note: $id', e, s);
      rethrow;
    }
  }

  @override
  Future<Note> saveNote(Note note) async {
    try {
      AppLogger.d('Saving note: ${note.title}');
      final model = NoteModel.fromEntity(note);
      final noteResponse = await _supabase.from('notes').upsert(model.toJson()).select().single();
      final savedNote = NoteModel.fromJson(noteResponse);

      // Sync Mentions
      await _syncMentions(savedNote);
      AppLogger.i('Note saved successfully');
      return savedNote;
    } catch (e, s) {
      AppLogger.e('Failed to save note', e, s);
      rethrow;
    }
  }

  Future<void> _syncMentions(Note note) async {
    try {
      // 1. Parse content to find mentions
      // Mentions are stored as LinkAttribute with 'todo://{id}' URL scheme
      final ops = note.content['ops'] as List<dynamic>? ?? [];
      final mentionsToInsert = <Map<String, dynamic>>[];

      for (int i = 0; i < ops.length; i++) {
        final op = ops[i] as Map<String, dynamic>;
        final attributes = op['attributes'] as Map<String, dynamic>?;
        
        // Check for link attribute with todo:// scheme
        if (attributes != null && attributes.containsKey('link')) {
          final link = attributes['link'] as String;
          if (link.startsWith('todo://')) {
            final todoId = link.replaceFirst('todo://', '');
            mentionsToInsert.add({
              'note_id': note.id,
              'todo_id': todoId,
              'block_index': i,
            });
          }
        }
      }

      // 2. Clear existing mentions for this note (Delete All, Insert New)
      await _supabase.from('note_mentions').delete().eq('note_id', note.id);

      // 3. Insert new mentions
      if (mentionsToInsert.isNotEmpty) {
        await _supabase.from('note_mentions').insert(mentionsToInsert);
        AppLogger.d('Synced ${mentionsToInsert.length} mentions for note: ${note.id}');
      }
    } catch (e, s) {
      AppLogger.e('Failed to sync mentions for note: ${note.id}', e, s);
      // Don't rethrow - mention sync failure shouldn't block note save
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      AppLogger.d('Deleting note: $id');
      // Mentions should cascade delete if FK is set up correctly, 
      // but explicit delete is safer if cascade isn't guaranteed.
      // Assuming Supabase FK has ON DELETE CASCADE.
      await _supabase.from('notes').delete().eq('id', id);
      AppLogger.i('Note deleted successfully');
    } catch (e, s) {
      AppLogger.e('Failed to delete note: $id', e, s);
      rethrow;
    }
  }

  @override
  Future<List<Todo>> searchTodos(String query) async {
    try {
      AppLogger.d('Searching todos with query: $query');
      
      // Build query - if empty, show recent todos; otherwise filter by title
      PostgrestFilterBuilder<List<Map<String, dynamic>>> request = 
          _supabase.from('todos').select();
      
      if (query.isNotEmpty) {
        request = request.ilike('title', '%$query%');
      }
      
      final response = await request
          .order('created_at', ascending: false)
          .limit(20);
      
      return (response as List).map((json) => TodoModel.fromJson(json)).toList();
    } catch (e, s) {
      AppLogger.e('Failed to search todos', e, s);
      rethrow;
    }
  }
}
