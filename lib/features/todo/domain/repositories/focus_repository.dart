import '../entities/focus_session.dart';

abstract class FocusRepository {
  Future<void> saveSession(FocusSession session);
}
