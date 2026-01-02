import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/todo/domain/entities/todo.dart';
import '../../../../core/injection/injection_container.dart'; // Correct path
import '../bloc/note_editor_cubit.dart';
import '../bloc/note_bloc.dart';

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
  StreamSubscription<DocChange>? _editorChangeSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<NoteEditorCubit>();
    _editorChangeSubscription = _controller.document.changes.listen((event) {
      if (!mounted) return;
      final content = _controller.document.toDelta().toJson();
      final title = _titleController.text.trim();
      cubit.onTextChanged({'ops': content}, title);
    });
  }

  @override
  void dispose() {
    _editorChangeSubscription?.cancel();
    _controller.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onNoteLoaded(NoteEditorState state) {
    _titleController.text = state.note.title;
    if (state.note.content.isNotEmpty && state.note.content.containsKey('ops')) {
      try {
        final ops = (state.note.content['ops'] as List).cast<Map<String, dynamic>>();
        _controller.document = Document.fromJson(ops);
      } catch (e) {
        // Fallback to empty if parse invalid
      }
    }
  }
  
  void _insertMention(BuildContext context) async {
    final Todo? todo = await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<NoteEditorCubit>(),
        child: const _MentionDialog(),
      ),
    );

    if (todo != null && mounted) {
      final index = _controller.selection.baseOffset;
      
      // Insert Text with Link Attribute
      // Format: "@TodoTitle"
      final text = '@${todo.title}';
      
      _controller.document.insert(index, text);
      // Apply Attribute to "@TodoTitle"
      _controller.formatText(index, text.length, LinkAttribute('todo://${todo.id}'));
      // Insert space after without link
      _controller.document.insert(index + text.length, ' ');
    }
  }

  void _handleLinkTap(String url) {
     if (url.startsWith('todo://')) {
       final todoId = url.replaceFirst('todo://', '');
       // Navigate to Todo Edit? 
       // For now, simpler to just show snackbar or log. 
       // We haven't implemented Deep Linking to Todo Edit Sheet yet.
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Mentioned Todo ID: $todoId')),
       );
     }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteEditorCubit, NoteEditorState>(
      listenWhen: (previous, current) =>
          previous.status == NoteEditorStatus.loading &&
          current.status == NoteEditorStatus.success, // Or any success update
      listener: (context, state) {
        if (state.status == NoteEditorStatus.success) {
           // Notify NoteBloc to update the list manually
           try {
             context.read<NoteBloc>().add(NoteSaved(state.note));
           } catch (e) {
             // Bloc might not be in context if opened directly or structure differs.
           }
        }
        _onNoteLoaded(state);
      },
      child: BlocBuilder<NoteEditorCubit, NoteEditorState>(
        builder: (context, state) {
          if (state.status == NoteEditorStatus.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) async {
              // Auto-save on exit
              if (didPop) return;
              // If we wanted to block pop, we'd do logic here.
              // But for simple auto-save, we can just trigger it.
              // Ideally, we trigger save and let it happen in background? 
              // Or wait? Waiting on pop is tricky without async gaps.
              // Since we return true, the pop happens immediately.
              // We should trigger the save call before popping or fire-and-forget.
              final cubit = context.read<NoteEditorCubit>();
              final content = _controller.document.toDelta().toJson();
              final title = _titleController.text.trim();
              cubit.save({'ops': content}, title, isAutoSave: true);
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Manual back button handling to ensure save
                    final cubit = context.read<NoteEditorCubit>();
                    final content = _controller.document.toDelta().toJson();
                    final title = _titleController.text.trim();
                    cubit.save({'ops': content}, title, isAutoSave: true);
                    context.pop();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.alternate_email),
                    onPressed: () => _insertMention(context),
                    tooltip: 'Mention Todo',
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _titleController,
                      onChanged: (val) {
                         final cubit = context.read<NoteEditorCubit>();
                         final content = _controller.document.toDelta().toJson();
                         cubit.onTextChanged({'ops': content}, val);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  QuillSimpleToolbar(
                    controller: _controller,
                    config: const QuillSimpleToolbarConfig(
                      showSearchButton: false, 
                      showInlineCode: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showFontFamily: false,
                      showFontSize: false,
                      toolbarSectionSpacing: 0,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: QuillEditor.basic(
                        controller: _controller,
                        focusNode: _editorFocusNode,
                        config: QuillEditorConfig(
                          placeholder: 'Start typing...',
                          onLaunchUrl: (url) {
                            _handleLinkTap(url);
                          },
                        ),
                      ),
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

class _MentionDialog extends StatefulWidget {
  const _MentionDialog();

  @override
  State<_MentionDialog> createState() => _MentionDialogState();
}

class _MentionDialogState extends State<_MentionDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, BuildContext context) {
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
        decoration: const InputDecoration(hintText: 'Search Todos...'),
        onChanged: (val) => _onSearchChanged(val, context),
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
              return const Center(child: Text('No results'));
            }
            return ListView.builder(
              itemCount: state.mentionSearchResults.length,
              itemBuilder: (context, index) {
                final todo = state.mentionSearchResults[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.isCompleted ? 'Completed' : 'Active'),
                  onTap: () {
                    // Get Editor Controller from parent or we need to pass it? 
                    // Wait, we can't access _controller from here directly.
                    // We need to pass the controller or return the result.
                    Navigator.of(context).pop(todo); 
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
