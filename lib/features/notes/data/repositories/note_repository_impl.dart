import 'package:supabase_flutter/supabase_flutter.dart';
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
      // Assumption: Mentions are stored in Delta attributes as {'mention': 'todo_id'}
      final ops = note.content['ops'] as List<dynamic>? ?? [];
      final mentionsToInsert = <Map<String, dynamic>>[];

      for (int i = 0; i < ops.length; i++) {
        final op = ops[i] as Map<String, dynamic>;
        final attributes = op['attributes'] as Map<String, dynamic>?;
        
        if (attributes != null && attributes.containsKey('mention')) {
          final todoId = attributes['mention'] as String;
          mentionsToInsert.add({
            'note_id': note.id,
            'todo_id': todoId,
            'block_index': i,
            // 'created_at': DateTime.now().toUtc().toIso8601String(), // DB default
          });
        }
      }

      // 2. Clear existing mentions for this note (Simple strategy: Delete All, Insert New)
      // This handles removals correctly if user deleted a mention from text.
      await _supabase.from('note_mentions').delete().eq('note_id', note.id);

      // 3. Insert new mentions
      if (mentionsToInsert.isNotEmpty) {
        await _supabase.from('note_mentions').insert(mentionsToInsert);
      }
    } catch (e, s) {
      AppLogger.e('Failed to sync mentions for note: ${note.id}', e, s);
      // We might not want to rethrow here to avoid failing the whole save if sync fails?
      // For now, let's rethrow to be safe.
      rethrow;
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
      final response = await _supabase
          .from('todos')
          .select()
          .ilike('title', '%$query%') // Case insensitive search
          .limit(10);
      
      return (response as List).map((json) => TodoModel.fromJson(json)).toList();
    } catch (e, s) {
      AppLogger.e('Failed to search todos', e, s);
      rethrow;
    }
  }
}
