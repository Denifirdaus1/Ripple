import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/folder.dart';
import '../bloc/folder_bloc.dart';
import '../../../notes/presentation/widgets/note_card.dart';

/// Page to view and manage notes within a folder
class FolderDetailPage extends StatefulWidget {
  final String folderId;

  const FolderDetailPage({super.key, required this.folderId});

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load folder contents when page opens
    context.read<FolderBloc>().add(FolderContentsRequested(widget.folderId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, folderState) {
        // Find the folder
        final folder = folderState.folders.cast<Folder?>().firstWhere(
          (f) => f?.id == widget.folderId,
          orElse: () => null,
        );

        if (folder == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Folder tidak ditemukan'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(
              child: Text('Folder tidak ditemukan atau telah dihapus'),
            ),
          );
        }

        return _FolderDetailView(folder: folder);
      },
    );
  }
}

class _FolderDetailView extends StatelessWidget {
  final Folder folder;

  const _FolderDetailView({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Icon(Icons.folder_rounded, color: _getFolderColor(), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                folder.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) async {
              switch (value) {
                case 'rename':
                  _showRenameDialog(context);
                  break;
                case 'delete':
                  _confirmDelete(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Hapus Folder', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, folderState) {
          // Show loading indicator while fetching contents
          if (folderState.isLoadingContents) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get folder contents
          final contents = folderState.selectedContents;
          final notes = contents?.notes ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.folderOpen,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Folder kosong',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pindahkan notes ke folder ini dari menu note',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteCard(
                note: note,
                onTap: () {
                  context.push('/notes/editor/${note.id}').then((_) {
                    // Refresh folder contents after returning from editor
                    context.read<FolderBloc>().add(
                      FolderContentsRequested(folder.id),
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getFolderColor() {
    if (folder.color != null && folder.color!.isNotEmpty) {
      try {
        if (folder.color!.startsWith('#')) {
          return Color(
            int.parse(folder.color!.substring(1), radix: 16) + 0xFF000000,
          );
        }
      } catch (_) {}
    }
    return AppColors.rippleBlue;
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama folder'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<FolderBloc>().add(
                  FolderRenamed(folder.id, newName),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Folder?'),
        content: const Text(
          'Notes di dalam folder ini tidak akan terhapus, hanya dipindahkan keluar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<FolderBloc>().add(FolderDeleted(folder.id));
              Navigator.pop(ctx);
              context.pop(); // Go back to notes page
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
