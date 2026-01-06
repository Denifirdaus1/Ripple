import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ripple_page_header.dart';
import '../bloc/note_bloc.dart';
import '../widgets/note_card.dart';
import '../../../folder/presentation/widgets/folder_card.dart';
import '../../../folder/presentation/widgets/create_folder_bottom_sheet.dart';
import '../../../folder/presentation/bloc/folder_bloc.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            RipplePageHeader(
              title: 'Notes',
              action: IconButton(
                icon: const Icon(PhosphorIconsRegular.folderPlus),
                tooltip: 'Create Folder',
                onPressed: () {
                  CreateFolderBottomSheet.show(context);
                },
              ),
            ),
            Expanded(child: _NotesListView()),
          ],
        ),
      ),
    );
  }
}

/// Combined list view showing folders first, then notes
class _NotesListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, folderState) {
        return BlocBuilder<NoteBloc, NoteState>(
          builder: (context, noteState) {
            if (noteState.status == NoteStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final folders = folderState.folders;
            // Filter out notes that are already in folders
            final notes = noteState.notes
                .where((n) => !folderState.isNoteInFolder(n.id))
                .toList();
            final hasContent = folders.isNotEmpty || notes.isNotEmpty;

            if (!hasContent) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIconsRegular.noteBlank,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada notes',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + untuk membuat note baru',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Sort notes: favorites first, then by createdAt
            final sortedNotes = List.of(notes)
              ..sort((a, b) {
                if (a.isFavorite && !b.isFavorite) return -1;
                if (!a.isFavorite && b.isFavorite) return 1;
                return b.createdAt.compareTo(a.createdAt);
              });

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Folders section
                if (folders.isNotEmpty) ...[
                  _SectionHeader(title: 'Folders', count: folders.length),
                  const SizedBox(height: 8),
                  ...folders.map(
                    (folder) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FolderCard(
                        folder: folder,
                        noteCount: folderState.folderNoteCounts[folder.id] ?? 0,
                        onTap: () {
                          context.push('/notes/folder/${folder.id}');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Notes section
                if (sortedNotes.isNotEmpty) ...[
                  _SectionHeader(title: 'Notes', count: sortedNotes.length),
                  const SizedBox(height: 8),
                  ...sortedNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NoteCard(
                        note: note,
                        onTap: () {
                          context.push('/notes/editor/${note.id}');
                        },
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

/// Section header with title and count badge
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
