import '../repositories/focus_repository.dart';
import '../entities/focus_session.dart';

class SaveFocusSession {
  final FocusRepository repository;
  SaveFocusSession(this.repository);
  Future<void> call(FocusSession session) => repository.saveSession(session);
}
