import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ripple_page_header.dart';
import '../bloc/note_bloc.dart';
import '../widgets/note_card.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const RipplePageHeader(title: 'Notes'),
            Expanded(
              child: BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  if (state.status == NoteStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state.notes.isEmpty) {
                     return Center(
                      child: Text(
                        'No notes yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  // Sort: favorites first, then by createdAt (newest first)
                  final sortedNotes = List.of(state.notes)
                    ..sort((a, b) {
                      // Favorites first
                      if (a.isFavorite && !b.isFavorite) return -1;
                      if (!a.isFavorite && b.isFavorite) return 1;
                      // Then by createdAt (newest first)
                      return b.createdAt.compareTo(a.createdAt);
                    });

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sortedNotes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = sortedNotes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          context.push('/notes/editor/${note.id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
