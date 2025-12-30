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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Editor with empty ID implies new note
          context.push('/notes/editor/new');
        },
        child: const Icon(Icons.add),
      ),
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

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.notes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = state.notes[index];
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
