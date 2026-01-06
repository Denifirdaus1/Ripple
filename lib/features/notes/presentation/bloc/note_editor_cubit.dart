import 'dart:async';
import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/todo/domain/entities/todo.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_tag.dart';
import '../../data/models/note_tag_model.dart';
import '../../domain/usecases/note_usecases.dart';

enum NoteEditorStatus { initial, loading, success, failure, saving }

class NoteEditorState extends Equatable {
  final NoteEditorStatus status;
  final Note note;
  final List<Todo> mentionSearchResults;
  final bool isMentionSearchLoading;
  final List<NoteTag> availableTags;
  final bool isDeleted;

  const NoteEditorState({
    this.status = NoteEditorStatus.initial,
    required this.note,
    this.mentionSearchResults = const [],
    this.isMentionSearchLoading = false,
    this.availableTags = const [],
    this.isDeleted = false,
  });

  factory NoteEditorState.initial() {
    return NoteEditorState(note: Note.empty);
  }

  /// Get enabled property IDs directly from note entity
  List<String> get enabledPropertyIds => note.enabledProperties;

  NoteEditorState copyWith({
    NoteEditorStatus? status,
    Note? note,
    List<Todo>? mentionSearchResults,
    bool? isMentionSearchLoading,
    List<NoteTag>? availableTags,
    bool? isDeleted,
  }) {
    return NoteEditorState(
      status: status ?? this.status,
      note: note ?? this.note,
      mentionSearchResults: mentionSearchResults ?? this.mentionSearchResults,
      isMentionSearchLoading:
          isMentionSearchLoading ?? this.isMentionSearchLoading,
      availableTags: availableTags ?? this.availableTags,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object> get props => [
    status,
    note,
    mentionSearchResults,
    isMentionSearchLoading,
    availableTags,
    isDeleted,
  ];
}

class NoteEditorCubit extends Cubit<NoteEditorState> {
  final SaveNote _saveNote;
  final GetNote _getNote;
  final SearchMentions _searchMentions;

  Timer? _debounceTimer;

  NoteEditorCubit({
    required SaveNote saveNote,
    required GetNote getNote,
    required SearchMentions searchMentions,
  }) : _saveNote = saveNote,
       _getNote = getNote,
       _searchMentions = searchMentions,
       super(NoteEditorState.initial());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  void loadNote(Note note) {
    emit(state.copyWith(status: NoteEditorStatus.success, note: note));
  }

  Future<void> loadNoteById(String id) async {
    if (id == 'new') {
      // New note: auto-fill date with today
      final newNote = Note.empty.copyWith(noteDate: DateTime.now());
      emit(state.copyWith(status: NoteEditorStatus.success, note: newNote));
      loadTags(); // Load available tags
      return;
    }

    emit(state.copyWith(status: NoteEditorStatus.loading));
    try {
      final note = await _getNote(id);
      emit(state.copyWith(status: NoteEditorStatus.success, note: note));
      loadTags(); // Load available tags
    } catch (e) {
      emit(state.copyWith(status: NoteEditorStatus.failure));
    }
  }

  /// Triggers a save after a debounce duration.
  /// Used for auto-saving while typing.
  void onTextChanged(Map<String, dynamic> contentDelta, String title) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Reduced debounce to 500ms for faster saves
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      save(contentDelta, title, isAutoSave: true);
    });
  }

  Future<void> save(
    Map<String, dynamic> contentDelta,
    String title, {
    bool isAutoSave = false,
  }) async {
    // Skip if note was deleted
    if (state.isDeleted) {
      developer.log(
        'Skipping save - note was deleted',
        name: 'NoteEditorCubit',
      );
      return;
    }

    // If it's an auto-save, we don't want to show a loading spinner or block UI
    if (!isAutoSave) {
      emit(state.copyWith(status: NoteEditorStatus.saving));
    }

    try {
      var updatedNote = state.note.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: contentDelta,
        updatedAt: DateTime.now(),
      );

      if (updatedNote.userId.isEmpty) {
        final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
        updatedNote = updatedNote.copyWith(userId: userId);
      }

      final savedNote = await _saveNote(updatedNote);

      emit(state.copyWith(status: NoteEditorStatus.success, note: savedNote));
    } catch (e) {
      if (!isAutoSave) {
        emit(state.copyWith(status: NoteEditorStatus.failure));
      }
      // For auto-save, we might want to log error silently or set a 'dirty' flag
    }
  }

  Future<void> searchMentions(String query) async {
    emit(state.copyWith(isMentionSearchLoading: true));
    try {
      // Empty query will load recent todos from repository
      final results = await _searchMentions.searchTodos(query);
      emit(
        state.copyWith(
          mentionSearchResults: results,
          isMentionSearchLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isMentionSearchLoading: false));
    }
  }

  void clearMentions() {
    emit(state.copyWith(mentionSearchResults: []));
  }

  /// Force auto-save the current note state (called after property updates)
  Future<void> forceAutoSave() async {
    if (state.isDeleted) return;

    try {
      var noteToSave = state.note;
      // Ensure title is not empty
      if (noteToSave.title.isEmpty) {
        noteToSave = noteToSave.copyWith(title: 'Untitled');
      }
      noteToSave = noteToSave.copyWith(updatedAt: DateTime.now());

      if (noteToSave.userId.isEmpty) {
        final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
        noteToSave = noteToSave.copyWith(userId: userId);
      }

      final savedNote = await _saveNote(noteToSave);
      emit(state.copyWith(note: savedNote));
    } catch (e) {
      developer.log('forceAutoSave failed: $e', name: 'NoteEditorCubit');
    }
  }

  // --- Property Update Methods ---

  /// Update note date property
  void updateDate(DateTime? date) {
    emit(
      state.copyWith(
        note: state.note.copyWith(noteDate: date, clearNoteDate: date == null),
      ),
    );
  }

  /// Update note tags property
  void updateTags(List<String> tags) {
    emit(state.copyWith(note: state.note.copyWith(tags: tags)));
  }

  /// Add a single tag
  void addTag(String tag) {
    if (tag.isEmpty || state.note.tags.contains(tag)) return;
    emit(
      state.copyWith(
        note: state.note.copyWith(tags: [...state.note.tags, tag]),
      ),
    );
  }

  /// Remove a single tag
  void removeTag(String tag) {
    emit(
      state.copyWith(
        note: state.note.copyWith(
          tags: state.note.tags.where((t) => t != tag).toList(),
        ),
      ),
    );
  }

  /// Update note priority property
  void updatePriority(NotePriority? priority) {
    emit(
      state.copyWith(
        note: state.note.copyWith(
          priority: priority,
          clearPriority: priority == null,
        ),
      ),
    );
  }

  /// Update note status
  void updateStatus(NoteWorkStatus? status) {
    emit(
      state.copyWith(
        note: state.note.copyWith(status: status, clearStatus: status == null),
      ),
    );
  }

  /// Update note description
  void updateDescription(String? description) {
    final desc = description?.isEmpty == true ? null : description;
    emit(
      state.copyWith(
        note: state.note.copyWith(
          description: desc,
          clearDescription: desc == null,
        ),
      ),
    );
  }

  /// Toggle favorite status
  void toggleFavorite() {
    emit(
      state.copyWith(
        note: state.note.copyWith(isFavorite: !state.note.isFavorite),
      ),
    );
  }

  /// Delete this note
  Future<void> deleteNote() async {
    // Cancel any pending auto-save
    _debounceTimer?.cancel();

    emit(state.copyWith(status: NoteEditorStatus.loading));

    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', state.note.id);
      emit(state.copyWith(status: NoteEditorStatus.success, isDeleted: true));
    } catch (e) {
      emit(state.copyWith(status: NoteEditorStatus.failure));
    }
  }

  /// Enable a property on this note (persisted to database)
  void enableProperty(String propertyId) {
    developer.log(
      'enableProperty called: $propertyId',
      name: 'NoteEditorCubit',
    );
    developer.log(
      'Current enabledPropertyIds: ${state.note.enabledProperties}',
      name: 'NoteEditorCubit',
    );

    if (state.note.enabledProperties.contains(propertyId)) {
      developer.log(
        'Property already enabled, skipping',
        name: 'NoteEditorCubit',
      );
      return;
    }

    final newEnabled = [...state.note.enabledProperties, propertyId];
    developer.log(
      'New enabledProperties: $newEnabled',
      name: 'NoteEditorCubit',
    );

    emit(
      state.copyWith(note: state.note.copyWith(enabledProperties: newEnabled)),
    );

    developer.log(
      'After emit enabledPropertyIds: ${state.note.enabledProperties}',
      name: 'NoteEditorCubit',
    );
  }

  /// Disable a property on this note (persisted to database)
  void disableProperty(String propertyId) {
    // Don't allow disabling 'date' - it's always required
    if (propertyId == 'date') return;

    final newEnabled = state.note.enabledProperties
        .where((p) => p != propertyId)
        .toList();

    emit(
      state.copyWith(note: state.note.copyWith(enabledProperties: newEnabled)),
    );
  }

  /// Load available tags for current user
  Future<void> loadTags() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('user_tags')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final tags = (response as List)
          .map((json) => NoteTagModel.fromJson(json))
          .toList();

      emit(state.copyWith(availableTags: tags));
    } catch (e) {
      // Silently fail - defaults will still be available
    }
  }

  /// Create a new tag with custom color
  Future<void> createTag(String name, String colorHex) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('user_tags')
          .insert({'user_id': userId, 'name': name, 'color_hex': colorHex})
          .select()
          .single();

      final newTag = NoteTagModel.fromJson(response);
      emit(state.copyWith(availableTags: [newTag, ...state.availableTags]));
    } catch (e) {
      // Tag might already exist, silently fail
    }
  }
}
