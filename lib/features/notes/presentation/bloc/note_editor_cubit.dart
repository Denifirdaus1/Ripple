import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/todo/domain/entities/todo.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/note_usecases.dart';

enum NoteEditorStatus { initial, loading, success, failure, saving }

class NoteEditorState extends Equatable {
  final NoteEditorStatus status;
  final Note note;
  final List<Todo> mentionSearchResults;
  final bool isMentionSearchLoading;

  const NoteEditorState({
    this.status = NoteEditorStatus.initial,
    required this.note,
    this.mentionSearchResults = const [],
    this.isMentionSearchLoading = false,
  });

  factory NoteEditorState.initial() {
    return NoteEditorState(note: Note.empty);
  }

  NoteEditorState copyWith({
    NoteEditorStatus? status,
    Note? note,
    List<Todo>? mentionSearchResults,
    bool? isMentionSearchLoading,
  }) {
    return NoteEditorState(
      status: status ?? this.status,
      note: note ?? this.note,
      mentionSearchResults: mentionSearchResults ?? this.mentionSearchResults,
      isMentionSearchLoading: isMentionSearchLoading ?? this.isMentionSearchLoading,
    );
  }

  @override
  List<Object> get props => [status, note, mentionSearchResults, isMentionSearchLoading];
}

class NoteEditorCubit extends Cubit<NoteEditorState> {
  final SaveNote _saveNote;
  final GetNote _getNote;
  final SearchMentions _searchMentions;

  NoteEditorCubit({
    required SaveNote saveNote,
    required GetNote getNote,
    required SearchMentions searchMentions,
  })  : _saveNote = saveNote,
        _getNote = getNote,
        _searchMentions = searchMentions,
        super(NoteEditorState.initial());

  void loadNote(Note note) {
    emit(state.copyWith(
      status: NoteEditorStatus.success,
      note: note,
    ));
  }

  Future<void> loadNoteById(String id) async {
    if (id == 'new') {
      emit(state.copyWith(status: NoteEditorStatus.success, note: Note.empty));
      return;
    }
    
    emit(state.copyWith(status: NoteEditorStatus.loading));
    try {
      final note = await _getNote(id);
      emit(state.copyWith(status: NoteEditorStatus.success, note: note));
    } catch (e) {
      emit(state.copyWith(status: NoteEditorStatus.failure));
    }
  }

  Future<void> save(Map<String, dynamic> contentDelta, String title) async {
    emit(state.copyWith(status: NoteEditorStatus.saving));
    try {
      var updatedNote = state.note.copyWith(
        title: title,
        content: contentDelta,
        updatedAt: DateTime.now(),
      );
      
      if (updatedNote.userId.isEmpty) {
         final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
         updatedNote = updatedNote.copyWith(userId: userId);
      }
      
      await _saveNote(updatedNote);
      
      emit(state.copyWith(status: NoteEditorStatus.success, note: updatedNote));
    } catch (e) {
      emit(state.copyWith(status: NoteEditorStatus.failure));
    }
  }

  Future<void> searchMentions(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(mentionSearchResults: []));
      return;
    }
    
    emit(state.copyWith(isMentionSearchLoading: true));
    try {
      final results = await _searchMentions.searchTodos(query);
      emit(state.copyWith(
        mentionSearchResults: results,
        isMentionSearchLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isMentionSearchLoading: false));
    }
  }
  
  void clearMentions() {
    emit(state.copyWith(mentionSearchResults: []));
  }
}
