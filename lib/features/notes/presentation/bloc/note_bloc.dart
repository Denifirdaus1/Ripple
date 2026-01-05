import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/note_usecases.dart';

// --- Events ---
abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object> get props => [];
}

class NoteSubscriptionRequested extends NoteEvent {}

class NoteSaved extends NoteEvent {
  final Note note;
  const NoteSaved(this.note);
  @override
  List<Object> get props => [note];
}

class NoteDeleted extends NoteEvent {
  final String noteId;
  const NoteDeleted(this.noteId);
  @override
  List<Object> get props => [noteId];
}

/// Event to remove note from UI list only (already deleted from DB)
class NoteRemovedFromList extends NoteEvent {
  final String noteId;
  const NoteRemovedFromList(this.noteId);
  @override
  List<Object> get props => [noteId];
}

class _NoteListUpdated extends NoteEvent {
  final List<Note> notes;
  const _NoteListUpdated(this.notes);
  @override
  List<Object> get props => [notes];
}

/// Event to clear all notes data (triggered on logout)
class NoteClearRequested extends NoteEvent {}

// --- States ---
enum NoteStatus { initial, loading, success, failure }

class NoteState extends Equatable {
  final NoteStatus status;
  final List<Note> notes;

  const NoteState({
    this.status = NoteStatus.initial,
    this.notes = const [],
  });

  NoteState copyWith({
    NoteStatus? status,
    List<Note>? notes,
  }) {
    return NoteState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object> get props => [status, notes];
}

// --- BLoC ---
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetNotesStream _getNotesStream;
  final DeleteNote _deleteNote;
  StreamSubscription<List<Note>>? _notesSubscription;

  NoteBloc({
    required GetNotesStream getNotesStream,
    required DeleteNote deleteNote,
  })  : _getNotesStream = getNotesStream,
        _deleteNote = deleteNote,
        super(const NoteState()) {
    on<NoteSubscriptionRequested>(_onSubscriptionRequested);
    on<_NoteListUpdated>(_onNoteListUpdated);
    on<NoteSaved>(_onNoteSaved); 
    on<NoteDeleted>(_onDeleted);
    on<NoteRemovedFromList>(_onRemovedFromList);
    on<NoteClearRequested>(_onClearRequested);
  }

  Future<void> _onSubscriptionRequested(
    NoteSubscriptionRequested event,
    Emitter<NoteState> emit,
  ) async {
    AppLogger.d('Note Subscription Requested');
    emit(state.copyWith(status: NoteStatus.loading));
    await _notesSubscription?.cancel();
    _notesSubscription = _getNotesStream().listen(
      (notes) => add(_NoteListUpdated(notes)),
      onError: (e, s) {
        AppLogger.e('Note Stream Error', e, s);
        emit(state.copyWith(status: NoteStatus.failure));
      }
    );
  }

  void _onNoteListUpdated(
    _NoteListUpdated event,
    Emitter<NoteState> emit,
  ) {
    AppLogger.d('Note list updated from stream: ${event.notes.length}');
    emit(state.copyWith(status: NoteStatus.success, notes: event.notes));
  }

  Future<void> _onNoteSaved(
    NoteSaved event,
    Emitter<NoteState> emit,
  ) async {
      // Manual optimistic/wait update
      // We assume the note passed here is ALREADY saved by the editor
      AppLogger.d('NoteSaved event received: ${event.note.title}');
      
      final currentNotes = List<Note>.from(state.notes);
      final index = currentNotes.indexWhere((n) => n.id == event.note.id);
      
      if (index >= 0) {
        currentNotes[index] = event.note;
      } else {
        currentNotes.add(event.note);
      }
      
      emit(state.copyWith(status: NoteStatus.success, notes: currentNotes));
  }

  Future<void> _onDeleted(
    NoteDeleted event,
    Emitter<NoteState> emit,
  ) async {
    try {
      AppLogger.d('Deleting note: ${event.noteId}');
      await _deleteNote(event.noteId);
      
      final currentNotes = List<Note>.from(state.notes)
        ..removeWhere((n) => n.id == event.noteId);
        
      AppLogger.i('Note deleted successfully');
      emit(state.copyWith(status: NoteStatus.success, notes: currentNotes));
    } catch (e, s) {
      AppLogger.e('Failed to delete note in Bloc', e, s);
      // Optional: Emit failure state or show snackbar via listener
    }
  }

  /// Removes note from state list only (DB delete already done elsewhere)
  void _onRemovedFromList(
    NoteRemovedFromList event,
    Emitter<NoteState> emit,
  ) {
    AppLogger.d('Removing note from list: ${event.noteId}');
    final currentNotes = List<Note>.from(state.notes)
      ..removeWhere((n) => n.id == event.noteId);
    emit(state.copyWith(status: NoteStatus.success, notes: currentNotes));
  }

  /// Clears all notes data and cancels subscription (triggered on logout)
  void _onClearRequested(
    NoteClearRequested event,
    Emitter<NoteState> emit,
  ) {
    AppLogger.d('Clearing notes data');
    _notesSubscription?.cancel();
    _notesSubscription = null;
    emit(const NoteState());
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
