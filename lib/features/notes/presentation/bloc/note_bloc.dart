import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/note_usecases.dart';

// --- Events ---
abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object> get props => [];
}

class NoteSubscriptionRequested extends NoteEvent {}

class NoteDeleted extends NoteEvent {
  final String id;
  const NoteDeleted(this.id);
  @override
  List<Object> get props => [id];
}

class _NoteListUpdated extends NoteEvent {
  final List<Note> notes;
  const _NoteListUpdated(this.notes);
  @override
  List<Object> get props => [notes];
}

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
    on<_NoteListUpdated>(_onListUpdated);
    on<NoteDeleted>(_onDeleted);
  }

  Future<void> _onSubscriptionRequested(
    NoteSubscriptionRequested event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.loading));
    await _notesSubscription?.cancel();
    _notesSubscription = _getNotesStream().listen(
      (notes) => add(_NoteListUpdated(notes)),
      onError: (_) {
        // Handle error
      }
    );
  }

  void _onListUpdated(
    _NoteListUpdated event,
    Emitter<NoteState> emit,
  ) {
    emit(state.copyWith(
      status: NoteStatus.success,
      notes: event.notes,
    ));
  }

  Future<void> _onDeleted(
    NoteDeleted event,
    Emitter<NoteState> emit,
  ) async {
    await _deleteNote(event.id);
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
