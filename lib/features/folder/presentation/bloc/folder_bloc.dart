import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/folder_contents.dart';
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
  final String? error;

  const FolderState({
    this.status = FolderStatus.initial,
    this.folders = const [],
    this.selectedFolderId,
    this.selectedContents,
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

  FolderState copyWith({
    FolderStatus? status,
    List<Folder>? folders,
    String? selectedFolderId,
    FolderContents? selectedContents,
    String? error,
    bool clearSelectedFolderId = false,
  }) {
    return FolderState(
      status: status ?? this.status,
      folders: folders ?? this.folders,
      selectedFolderId:
          clearSelectedFolderId ? null : (selectedFolderId ?? this.selectedFolderId),
      selectedContents: selectedContents ?? this.selectedContents,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, folders, selectedFolderId, selectedContents, error];
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
  })  : _getFoldersStream = getFoldersStream,
        _getFolderContents = getFolderContents,
        _getInboxContents = getInboxContents,
        _createFolder = createFolder,
        _updateFolder = updateFolder,
        _deleteFolder = deleteFolder,
        _addItemToFolder = addItemToFolder,
        _removeItemFromFolder = removeItemFromFolder,
        _moveFolder = moveFolder,
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
    AppLogger.d('Folder subscription requested');
    emit(state.copyWith(status: FolderStatus.loading));
    await _foldersSubscription?.cancel();
    _foldersSubscription = _getFoldersStream().listen(
      (folders) => add(_FolderListUpdated(folders)),
      onError: (e, s) {
        AppLogger.e('Folder stream error', e, s);
        emit(state.copyWith(status: FolderStatus.failure, error: e.toString()));
      },
    );
  }

  void _onFolderListUpdated(
    _FolderListUpdated event,
    Emitter<FolderState> emit,
  ) {
    AppLogger.d('Folder list updated: ${event.folders.length} folders');
    emit(state.copyWith(status: FolderStatus.success, folders: event.folders));
  }

  Future<void> _onContentsRequested(
    FolderContentsRequested event,
    Emitter<FolderState> emit,
  ) async {
    try {
      AppLogger.d('Loading folder contents: ${event.folderId}');
      final contents = await _getFolderContents(event.folderId);
      emit(state.copyWith(
        selectedFolderId: event.folderId,
        selectedContents: contents,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to load folder contents', e, s);
    }
  }

  Future<void> _onInboxContentsRequested(
    InboxContentsRequested event,
    Emitter<FolderState> emit,
  ) async {
    try {
      AppLogger.d('Loading inbox contents');
      final contents = await _getInboxContents();
      emit(state.copyWith(
        selectedContents: contents,
        clearSelectedFolderId: true,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to load inbox contents', e, s);
    }
  }

  Future<void> _onCreated(
    FolderCreated event,
    Emitter<FolderState> emit,
  ) async {
    try {
      AppLogger.d('Creating folder: ${event.name}');
      final folder = Folder(
        id: '',
        userId: '', // Will be set by repository
        name: event.name,
        parentFolderId: event.parentFolderId,
        icon: event.icon,
        color: event.color,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _createFolder(folder);
      // Stream will automatically update the list
    } catch (e, s) {
      AppLogger.e('Failed to create folder', e, s);
    }
  }

  Future<void> _onRenamed(
    FolderRenamed event,
    Emitter<FolderState> emit,
  ) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == event.folderId);
      final updated = folder.copyWith(name: event.newName, updatedAt: DateTime.now());
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
      await _addItemToFolder(event.folderId, event.entityType, event.entityId);
      // Refresh selected folder contents if it's the target folder
      if (state.selectedFolderId == event.folderId) {
        add(FolderContentsRequested(event.folderId));
      }
    } catch (e, s) {
      AppLogger.e('Failed to add item to folder', e, s);
    }
  }

  Future<void> _onItemRemoved(
    FolderItemRemoved event,
    Emitter<FolderState> emit,
  ) async {
    try {
      await _removeItemFromFolder(event.folderId, event.entityType, event.entityId);
      // Refresh selected folder contents
      if (state.selectedFolderId == event.folderId) {
        add(FolderContentsRequested(event.folderId));
      }
    } catch (e, s) {
      AppLogger.e('Failed to remove item from folder', e, s);
    }
  }

  Future<void> _onMoved(
    FolderMoved event,
    Emitter<FolderState> emit,
  ) async {
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

  void _onSelected(
    FolderSelected event,
    Emitter<FolderState> emit,
  ) {
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
