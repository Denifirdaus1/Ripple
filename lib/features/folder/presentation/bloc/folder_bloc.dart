import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/folder_contents.dart';
import '../../domain/errors/folder_exceptions.dart';
import '../../domain/usecases/folder_usecases.dart';

// ============================================
// EVENTS
// ============================================

abstract class FolderEvent extends Equatable {
  const FolderEvent();
  @override
  List<Object?> get props => [];
}

/// Start listening to folders stream
class FolderSubscriptionRequested extends FolderEvent {}

/// Internal event when folder list updates from stream
class _FolderListUpdated extends FolderEvent {
  final List<Folder> folders;
  const _FolderListUpdated(this.folders);
  @override
  List<Object?> get props => [folders];
}

/// Load contents of a specific folder
class FolderContentsRequested extends FolderEvent {
  final String folderId;
  const FolderContentsRequested(this.folderId);
  @override
  List<Object?> get props => [folderId];
}

/// Load inbox contents (items without folder)
class InboxContentsRequested extends FolderEvent {}

/// Create a new folder
class FolderCreated extends FolderEvent {
  final String name;
  final String? parentFolderId;
  final String? icon;
  final String? color;
  const FolderCreated({
    required this.name,
    this.parentFolderId,
    this.icon,
    this.color,
  });
  @override
  List<Object?> get props => [name, parentFolderId, icon, color];
}

/// Rename a folder
class FolderRenamed extends FolderEvent {
  final String folderId;
  final String newName;
  const FolderRenamed(this.folderId, this.newName);
  @override
  List<Object?> get props => [folderId, newName];
}

/// Delete a folder
class FolderDeleted extends FolderEvent {
  final String folderId;
  const FolderDeleted(this.folderId);
  @override
  List<Object?> get props => [folderId];
}

/// Add item to folder
class FolderItemAdded extends FolderEvent {
  final String folderId;
  final String entityType;
  final String entityId;
  const FolderItemAdded(this.folderId, this.entityType, this.entityId);
  @override
  List<Object?> get props => [folderId, entityType, entityId];
}

/// Remove item from folder
class FolderItemRemoved extends FolderEvent {
  final String folderId;
  final String entityType;
  final String entityId;
  const FolderItemRemoved(this.folderId, this.entityType, this.entityId);
  @override
  List<Object?> get props => [folderId, entityType, entityId];
}

/// Move folder to new parent
class FolderMoved extends FolderEvent {
  final String folderId;
  final String? newParentId;
  const FolderMoved(this.folderId, this.newParentId);
  @override
  List<Object?> get props => [folderId, newParentId];
}

/// Clear all folder data (on logout)
class FolderClearRequested extends FolderEvent {}

/// Select a folder to view its contents
class FolderSelected extends FolderEvent {
  final String? folderId; // null = Inbox
  const FolderSelected(this.folderId);
  @override
  List<Object?> get props => [folderId];
}

// ============================================
// STATE
// ============================================

enum FolderStatus { initial, loading, success, failure }

class FolderState extends Equatable {
  final FolderStatus status;
  final List<Folder> folders;
  final String? selectedFolderId; // null = Inbox
  final FolderContents? selectedContents;
  final bool isLoadingContents; // Loading state for folder contents
  final Set<String>
  noteIdsInFolders; // Note IDs that are assigned to any folder
  final Map<String, int> folderNoteCounts; // Note count per folder
  final String? error;

  const FolderState({
    this.status = FolderStatus.initial,
    this.folders = const [],
    this.selectedFolderId,
    this.selectedContents,
    this.isLoadingContents = false,
    this.noteIdsInFolders = const {},
    this.folderNoteCounts = const {},
    this.error,
  });

  /// Get root folders (no parent)
  List<Folder> get rootFolders =>
      folders.where((f) => f.parentFolderId == null).toList();

  /// Get children of a folder
  List<Folder> getChildren(String parentId) =>
      folders.where((f) => f.parentFolderId == parentId).toList();

  /// Get selected folder entity
  Folder? get selectedFolder {
    if (selectedFolderId == null) return null;
    try {
      return folders.firstWhere((f) => f.id == selectedFolderId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a note is in any folder
  bool isNoteInFolder(String noteId) => noteIdsInFolders.contains(noteId);

  FolderState copyWith({
    FolderStatus? status,
    List<Folder>? folders,
    String? selectedFolderId,
    FolderContents? selectedContents,
    bool? isLoadingContents,
    Set<String>? noteIdsInFolders,
    Map<String, int>? folderNoteCounts,
    String? error,
    bool clearSelectedFolderId = false,
  }) {
    return FolderState(
      status: status ?? this.status,
      folders: folders ?? this.folders,
      selectedFolderId: clearSelectedFolderId
          ? null
          : (selectedFolderId ?? this.selectedFolderId),
      selectedContents: selectedContents ?? this.selectedContents,
      isLoadingContents: isLoadingContents ?? this.isLoadingContents,
      noteIdsInFolders: noteIdsInFolders ?? this.noteIdsInFolders,
      folderNoteCounts: folderNoteCounts ?? this.folderNoteCounts,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    folders,
    selectedFolderId,
    selectedContents,
    isLoadingContents,
    noteIdsInFolders,
    folderNoteCounts,
    error,
  ];
}

// ============================================
// BLOC
// ============================================

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final GetFoldersStream _getFoldersStream;
  final GetFolderContents _getFolderContents;
  final GetInboxContents _getInboxContents;
  final CreateFolder _createFolder;
  final UpdateFolder _updateFolder;
  final DeleteFolder _deleteFolder;
  final AddItemToFolder _addItemToFolder;
  final RemoveItemFromFolder _removeItemFromFolder;
  final MoveFolder _moveFolder;
  final GetNoteIdsInFolders _getNoteIdsInFolders;
  final GetFolderNoteCounts _getFolderNoteCounts;

  StreamSubscription<List<Folder>>? _foldersSubscription;

  FolderBloc({
    required GetFoldersStream getFoldersStream,
    required GetFolderContents getFolderContents,
    required GetInboxContents getInboxContents,
    required CreateFolder createFolder,
    required UpdateFolder updateFolder,
    required DeleteFolder deleteFolder,
    required AddItemToFolder addItemToFolder,
    required RemoveItemFromFolder removeItemFromFolder,
    required MoveFolder moveFolder,
    required GetNoteIdsInFolders getNoteIdsInFolders,
    required GetFolderNoteCounts getFolderNoteCounts,
  }) : _getFoldersStream = getFoldersStream,
       _getFolderContents = getFolderContents,
       _getInboxContents = getInboxContents,
       _createFolder = createFolder,
       _updateFolder = updateFolder,
       _deleteFolder = deleteFolder,
       _addItemToFolder = addItemToFolder,
       _removeItemFromFolder = removeItemFromFolder,
       _moveFolder = moveFolder,
       _getNoteIdsInFolders = getNoteIdsInFolders,
       _getFolderNoteCounts = getFolderNoteCounts,
       super(const FolderState()) {
    on<FolderSubscriptionRequested>(_onSubscriptionRequested);
    on<_FolderListUpdated>(_onFolderListUpdated);
    on<FolderContentsRequested>(_onContentsRequested);
    on<InboxContentsRequested>(_onInboxContentsRequested);
    on<FolderCreated>(_onCreated);
    on<FolderRenamed>(_onRenamed);
    on<FolderDeleted>(_onDeleted);
    on<FolderItemAdded>(_onItemAdded);
    on<FolderItemRemoved>(_onItemRemoved);
    on<FolderMoved>(_onMoved);
    on<FolderClearRequested>(_onClearRequested);
    on<FolderSelected>(_onSelected);
  }

  Future<void> _onSubscriptionRequested(
    FolderSubscriptionRequested event,
    Emitter<FolderState> emit,
  ) async {
    AppLogger.d('[FolderBloc] Subscription requested');
    emit(state.copyWith(status: FolderStatus.loading));
    await _foldersSubscription?.cancel();
    _foldersSubscription = _getFoldersStream().listen(
      (folders) => add(_FolderListUpdated(folders)),
      onError: (e, s) {
        AppLogger.e('[FolderBloc] Stream error', e, s);
        final error = FolderErrorHandler.handle(e, s);
        emit(
          state.copyWith(status: FolderStatus.failure, error: error.message),
        );
      },
    );
  }

  Future<void> _onFolderListUpdated(
    _FolderListUpdated event,
    Emitter<FolderState> emit,
  ) async {
    AppLogger.d('Folder list updated: ${event.folders.length} folders');
    // Also refresh noteIdsInFolders and folderNoteCounts
    final noteIds = await _getNoteIdsInFolders();
    final counts = await _getFolderNoteCounts();
    emit(
      state.copyWith(
        status: FolderStatus.success,
        folders: event.folders,
        noteIdsInFolders: noteIds,
        folderNoteCounts: counts,
      ),
    );
  }

  Future<void> _onContentsRequested(
    FolderContentsRequested event,
    Emitter<FolderState> emit,
  ) async {
    try {
      // Set loading state
      emit(
        state.copyWith(
          isLoadingContents: true,
          selectedFolderId: event.folderId,
        ),
      );

      AppLogger.d('[FolderBloc] Loading folder contents: ${event.folderId}');
      final contents = await _getFolderContents(event.folderId);
      AppLogger.i('[FolderBloc] Contents loaded: ${contents.totalCount} items');
      emit(
        state.copyWith(
          selectedFolderId: event.folderId,
          selectedContents: contents,
          isLoadingContents: false,
        ),
      );
    } catch (e, s) {
      AppLogger.e('[FolderBloc] Failed to load folder contents', e, s);
      final error = FolderErrorHandler.handle(e, s);
      emit(
        state.copyWith(
          status: FolderStatus.failure,
          error: error.message,
          isLoadingContents: false,
        ),
      );
    }
  }

  Future<void> _onInboxContentsRequested(
    InboxContentsRequested event,
    Emitter<FolderState> emit,
  ) async {
    try {
      AppLogger.d('Loading inbox contents');
      final contents = await _getInboxContents();
      emit(
        state.copyWith(selectedContents: contents, clearSelectedFolderId: true),
      );
    } catch (e, s) {
      AppLogger.e('Failed to load inbox contents', e, s);
    }
  }

  Future<void> _onCreated(
    FolderCreated event,
    Emitter<FolderState> emit,
  ) async {
    try {
      // Validate name
      if (event.name.trim().isEmpty) {
        throw FolderInvalidNameException();
      }

      AppLogger.d('[FolderBloc] Creating folder: ${event.name}');

      // Create temp folder for optimistic update
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final optimisticFolder = Folder(
        id: tempId,
        userId: '',
        name: event.name.trim(),
        parentFolderId: event.parentFolderId,
        icon: event.icon,
        color: event.color,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Optimistic update - immediately show new folder
      emit(state.copyWith(folders: [...state.folders, optimisticFolder]));

      // Create actual folder
      final folder = Folder(
        id: '',
        userId: '',
        name: event.name.trim(),
        parentFolderId: event.parentFolderId,
        icon: event.icon,
        color: event.color,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _createFolder(folder);
      AppLogger.i('[FolderBloc] Folder created successfully');

      // Force re-subscribe to get the real folder with ID
      add(FolderSubscriptionRequested());
    } catch (e, s) {
      AppLogger.e('[FolderBloc] Failed to create folder', e, s);
      final error = FolderErrorHandler.handle(e, s);
      emit(state.copyWith(error: error.message));
    }
  }

  Future<void> _onRenamed(
    FolderRenamed event,
    Emitter<FolderState> emit,
  ) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == event.folderId);
      final updated = folder.copyWith(
        name: event.newName,
        updatedAt: DateTime.now(),
      );
      await _updateFolder(updated);
    } catch (e, s) {
      AppLogger.e('Failed to rename folder', e, s);
    }
  }

  Future<void> _onDeleted(
    FolderDeleted event,
    Emitter<FolderState> emit,
  ) async {
    try {
      AppLogger.d('Deleting folder: ${event.folderId}');
      await _deleteFolder(event.folderId);
      // If deleted folder was selected, clear selection
      if (state.selectedFolderId == event.folderId) {
        emit(state.copyWith(clearSelectedFolderId: true));
      }
    } catch (e, s) {
      AppLogger.e('Failed to delete folder', e, s);
    }
  }

  Future<void> _onItemAdded(
    FolderItemAdded event,
    Emitter<FolderState> emit,
  ) async {
    try {
      AppLogger.d(
        '[FolderBloc] Adding ${event.entityType} to folder: ${event.folderId}',
      );
      await _addItemToFolder(event.folderId, event.entityType, event.entityId);
      AppLogger.i('[FolderBloc] Item added successfully');

      // Refresh noteIdsInFolders and folderNoteCounts for real-time updates
      final noteIds = await _getNoteIdsInFolders();
      final counts = await _getFolderNoteCounts();
      emit(state.copyWith(noteIdsInFolders: noteIds, folderNoteCounts: counts));

      // Refresh selected folder contents if it's the target folder
      if (state.selectedFolderId == event.folderId) {
        add(FolderContentsRequested(event.folderId));
      }
    } catch (e, s) {
      AppLogger.e('[FolderBloc] Failed to add item to folder', e, s);
      final error = FolderErrorHandler.handle(e, s);
      emit(state.copyWith(error: error.message));
    }
  }

  Future<void> _onItemRemoved(
    FolderItemRemoved event,
    Emitter<FolderState> emit,
  ) async {
    try {
      await _removeItemFromFolder(
        event.folderId,
        event.entityType,
        event.entityId,
      );

      // Refresh noteIdsInFolders and folderNoteCounts for real-time updates
      final noteIds = await _getNoteIdsInFolders();
      final counts = await _getFolderNoteCounts();
      emit(state.copyWith(noteIdsInFolders: noteIds, folderNoteCounts: counts));

      // Refresh selected folder contents
      if (state.selectedFolderId == event.folderId) {
        add(FolderContentsRequested(event.folderId));
      }
    } catch (e, s) {
      AppLogger.e('Failed to remove item from folder', e, s);
    }
  }

  Future<void> _onMoved(FolderMoved event, Emitter<FolderState> emit) async {
    try {
      await _moveFolder(event.folderId, event.newParentId);
    } catch (e, s) {
      AppLogger.e('Failed to move folder', e, s);
    }
  }

  void _onClearRequested(
    FolderClearRequested event,
    Emitter<FolderState> emit,
  ) {
    AppLogger.d('Clearing folder data');
    _foldersSubscription?.cancel();
    _foldersSubscription = null;
    emit(const FolderState());
  }

  void _onSelected(FolderSelected event, Emitter<FolderState> emit) {
    if (event.folderId == null) {
      add(InboxContentsRequested());
    } else {
      add(FolderContentsRequested(event.folderId!));
    }
  }

  @override
  Future<void> close() {
    _foldersSubscription?.cancel();
    return super.close();
  }
}
