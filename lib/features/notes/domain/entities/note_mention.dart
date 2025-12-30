import 'package:equatable/equatable.dart';

class NoteMention extends Equatable {
  final String id;
  final String noteId;
  final String todoId;
  final int blockIndex;
  final DateTime createdAt;

  const NoteMention({
    required this.id,
    required this.noteId,
    required this.todoId,
    required this.blockIndex,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, noteId, todoId, blockIndex, createdAt];
}
