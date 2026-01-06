import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/todo/domain/entities/todo.dart';
import '../../../../core/injection/injection_container.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_tag.dart';
import '../bloc/note_editor_cubit.dart';
import '../bloc/note_bloc.dart';
import '../widgets/note_properties_section.dart';
import '../../../../core/toolbar/toolbar.dart';
import '../widgets/tag_selector_sheet.dart';
import '../../../../core/properties/properties.dart';
import '../../../folder/presentation/widgets/move_to_folder_sheet.dart';

class NoteEditorPage extends StatelessWidget {
  final String noteId;

  const NoteEditorPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NoteEditorCubit>()..loadNoteById(noteId),
      child: const _NoteEditorView(),
    );
  }
}

class _NoteEditorView extends StatefulWidget {
  const _NoteEditorView();

  @override
  State<_NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<_NoteEditorView> {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  StreamSubscription<DocChange>? _editorChangeSubscription;
  bool _isEditorFocused = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<NoteEditorCubit>();

    // Listen to editor changes for auto-save
    _editorChangeSubscription = _controller.document.changes.listen((event) {
      if (!mounted) return;
      final content = _controller.document.toDelta().toJson();
      final title = _titleController.text.trim();
      cubit.onTextChanged({'ops': content}, title);
    });

    // Track editor focus for showing toolbar
    _editorFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isEditorFocused = _editorFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    // Cancel pending auto-save and do immediate save
    _editorChangeSubscription?.cancel();
    _editorFocusNode.removeListener(_onFocusChange);
    _saveImmediately(); // Save before disposing
    _controller.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _saveImmediately() {
    try {
      final cubit = context.read<NoteEditorCubit>();
      // Skip save if note was deleted
      if (cubit.state.isDeleted) {
        debugPrint('[NoteEditor] Skipping save - note was deleted');
        return;
      }
      final content = _controller.document.toDelta().toJson();
      final title = _titleController.text.trim();
      if (title.isNotEmpty || content.isNotEmpty) {
        cubit.save({'ops': content}, title, isAutoSave: true);
      }
    } catch (_) {
      // Cubit might already be disposed
    }
  }

  void _onNoteLoaded(NoteEditorState state) {
    _titleController.text = state.note.title;
    if (state.note.content.isNotEmpty &&
        state.note.content.containsKey('ops')) {
      try {
        final ops = (state.note.content['ops'] as List)
            .cast<Map<String, dynamic>>();
        _controller.document = Document.fromJson(ops);
      } catch (e) {
        // Fallback to empty if parse invalid
      }
    }
  }

  Future<void> _saveAndPop() async {
    final cubit = context.read<NoteEditorCubit>();
    final content = _controller.document.toDelta().toJson();
    final title = _titleController.text.trim();

    // Await save completion before popping
    await cubit.save({'ops': content}, title, isAutoSave: true);

    // Notify NoteBloc to update list immediately
    if (mounted) {
      try {
        context.read<NoteBloc>().add(NoteSaved(cubit.state.note));
      } catch (_) {
        // NoteBloc might not be available
      }
      context.pop();
    }
  }

  void _insertMention() async {
    final Todo? todo = await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<NoteEditorCubit>(),
        child: const _MentionDialog(),
      ),
    );

    if (todo != null && mounted) {
      final index = _controller.selection.baseOffset;
      final text = '@${todo.title}';

      _controller.document.insert(index, text);
      _controller.formatText(
        index,
        text.length,
        LinkAttribute('todo://${todo.id}'),
      );
      _controller.document.insert(index + text.length, ' ');
    }
  }

  Future<void> _handleImageUpload() async {
    final service = sl<ImageUploadService>();
    try {
      final url = await service.pickAndUploadImage(source: ImageSource.gallery);
      if (url != null) {
        final index = _controller.selection.baseOffset;
        final length = _controller.selection.extentOffset - index;
        _controller.replaceText(index, length, BlockEmbed.image(url), null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _handleLinkTap(String url) {
    if (url.startsWith('todo://')) {
      final todoId = url.replaceFirst('todo://', '');
      context.push('/todos/detail/$todoId');
    }
  }

  void _showDatePicker() async {
    final cubit = context.read<NoteEditorCubit>();
    final initial = cubit.state.note.noteDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      cubit.updateDate(picked);
      cubit.forceAutoSave();
    }
  }

  void _showPriorityPicker() {
    final cubit = context.read<NoteEditorCubit>();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text('Tinggi'),
              onTap: () {
                cubit.updatePriority(NotePriority.high);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: const Text('Sedang'),
              onTap: () {
                cubit.updatePriority(NotePriority.medium);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.blue),
              title: const Text('Rendah'),
              onTap: () {
                cubit.updatePriority(NotePriority.low);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.close, color: AppColors.textSecondary),
              title: const Text('Hapus Prioritas'),
              onTap: () {
                cubit.updatePriority(null);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTagsEditor() {
    final cubit = context.read<NoteEditorCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<NoteEditorCubit, NoteEditorState>(
          builder: (context, state) => TagSelectorSheet(
            selectedTags: state.note.tags,
            availableTags: state.availableTags,
            onTagSelected: (tag) => cubit.addTag(tag),
            onTagRemoved: (tag) => cubit.removeTag(tag),
            onTagCreated: (name, color) => cubit.createTag(name, color),
          ),
        ),
      ),
    ).then((_) => cubit.forceAutoSave());
  }

  void _showStatusPicker() {
    final cubit = context.read<NoteEditorCubit>();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B7280),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Belum Dimulai'),
              onTap: () {
                cubit.updateStatus(NoteWorkStatus.notStarted);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Sedang Berjalan'),
              onTap: () {
                cubit.updateStatus(NoteWorkStatus.inProgress);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Selesai'),
              onTap: () {
                cubit.updateStatus(NoteWorkStatus.done);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.close, color: AppColors.textSecondary),
              title: const Text('Hapus Status'),
              onTap: () {
                cubit.updateStatus(null);
                cubit.forceAutoSave();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteEditorCubit, NoteEditorState>(
      listenWhen: (previous, current) =>
          current.status == NoteEditorStatus.success &&
          previous.status != current.status,
      listener: (context, state) {
        // Skip NoteSaved if note was deleted
        if (state.note.id.isNotEmpty && !state.isDeleted) {
          try {
            context.read<NoteBloc>().add(NoteSaved(state.note));
          } catch (e) {
            // Bloc might not be in context
          }
        }
        _onNoteLoaded(state);
      },
      child: BlocBuilder<NoteEditorCubit, NoteEditorState>(
        builder: (context, state) {
          if (state.status == NoteEditorStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return PopScope(
            canPop: false, // Block automatic pop to handle save first
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final cubit = context.read<NoteEditorCubit>();

              // Skip save and NoteSaved if note was deleted
              if (!cubit.state.isDeleted) {
                // Save and notify NoteBloc before popping
                final content = _controller.document.toDelta().toJson();
                final title = _titleController.text.trim();

                await cubit.save({'ops': content}, title, isAutoSave: true);

                // Notify NoteBloc to update list immediately
                if (context.mounted) {
                  try {
                    context.read<NoteBloc>().add(NoteSaved(cubit.state.note));
                  } catch (_) {}
                }
              }

              // Manual pop after save completes (or skip if deleted)
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _saveAndPop,
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textPrimary,
                    ),
                    onSelected: (value) async {
                      debugPrint('[NoteEditor] PopupMenu selected: $value');
                      final cubit = context.read<NoteEditorCubit>();

                      switch (value) {
                        case 'favorite':
                          debugPrint('[NoteEditor] Toggling favorite');
                          cubit.toggleFavorite();
                          break;
                        case 'delete':
                          debugPrint('[NoteEditor] Delete requested');
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Note'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus note ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          debugPrint('[NoteEditor] Delete confirm: $confirm');
                          if (confirm == true && context.mounted) {
                            final noteId = cubit.state.note.id;
                            await cubit.deleteNote();
                            if (context.mounted) {
                              // Notify NoteBloc to update list immediately (optimistic)
                              try {
                                context.read<NoteBloc>().add(
                                  NoteRemovedFromList(noteId),
                                );
                              } catch (_) {}
                              Navigator.of(context).pop();
                            }
                          }
                          break;
                        case 'move_folder':
                          debugPrint('[NoteEditor] Move to folder requested');
                          final noteId = cubit.state.note.id;
                          if (noteId.isNotEmpty && context.mounted) {
                            await MoveToFolderSheet.show(
                              context,
                              entityType: 'note',
                              entityId: noteId,
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (_) {
                      debugPrint('[NoteEditor] Building popup menu items');
                      final isFavorite = context
                          .read<NoteEditorCubit>()
                          .state
                          .note
                          .isFavorite;
                      debugPrint('[NoteEditor] isFavorite: $isFavorite');

                      return [
                        PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(
                                isFavorite ? Icons.star : Icons.star_outline,
                                size: 20,
                                color: isFavorite
                                    ? Colors.amber
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isFavorite
                                    ? 'Hapus dari Favorit'
                                    : 'Tambah ke Favorit',
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'move_folder',
                          child: Row(
                            children: [
                              Icon(
                                Icons.drive_file_move_rounded,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              const Text('Pindahkan ke Folder'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field - Bold, Clean
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              onChanged: (val) {
                                final cubit = context.read<NoteEditorCubit>();
                                final content = _controller.document
                                    .toDelta()
                                    .toJson();
                                cubit.onTextChanged({'ops': content}, val);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Judul',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Properties Section
                          NotePropertiesSection(
                            enabledPropertyIds: state.enabledPropertyIds,
                            noteDate: state.note.noteDate,
                            tags: state.note.tags,
                            availableTags: state.availableTags,
                            priority: state.note.priority,
                            status: state.note.status,
                            description: state.note.description,
                            onDateTap: _showDatePicker,
                            onTagsTap: _showTagsEditor,
                            onPriorityTap: _showPriorityPicker,
                            onStatusTap: _showStatusPicker,
                            onDescriptionChanged: (value) {
                              context.read<NoteEditorCubit>().updateDescription(
                                value,
                              );
                            },
                            onAddProperty: (propertyId) {
                              context.read<NoteEditorCubit>().enableProperty(
                                propertyId,
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Editor Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: QuillEditor.basic(
                              controller: _controller,
                              focusNode: _editorFocusNode,
                              config: QuillEditorConfig(
                                placeholder: 'Catat sesuatu',
                                expands:
                                    false, // Allow content to determine height
                                padding: const EdgeInsets.only(
                                  bottom: 300,
                                ), // Safe space for scroll
                                embedBuilders:
                                    FlutterQuillEmbeds.editorBuilders(),
                                onLaunchUrl: (url) {
                                  _handleLinkTap(url);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Keyboard Toolbar (shows when editor focused)
                  if (_isEditorFocused)
                    ExtensibleToolbar(
                      toolContext: ToolContext(
                        buildContext: context,
                        quillController: _controller,
                        onMentionTap: _insertMention,
                        onImageTap: _handleImageUpload,
                        onHideKeyboard: () {
                          _editorFocusNode.unfocus();
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Mention Dialog ---

class _MentionDialog extends StatefulWidget {
  const _MentionDialog();

  @override
  State<_MentionDialog> createState() => _MentionDialogState();
}

class _MentionDialogState extends State<_MentionDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteEditorCubit>().searchMentions('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<NoteEditorCubit>().searchMentions(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: _searchController,
        decoration: const InputDecoration(hintText: 'Cari Todos...'),
        onChanged: _onSearchChanged,
        autofocus: true,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: BlocBuilder<NoteEditorCubit, NoteEditorState>(
          builder: (context, state) {
            if (state.isMentionSearchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.mentionSearchResults.isEmpty) {
              return const Center(child: Text('Tidak ada hasil'));
            }
            return ListView.builder(
              itemCount: state.mentionSearchResults.length,
              itemBuilder: (context, index) {
                final todo = state.mentionSearchResults[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.isCompleted ? 'Selesai' : 'Aktif'),
                  onTap: () => Navigator.of(context).pop(todo),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
