import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/focus_repository.dart';
import '../models/focus_session_model.dart';

class FocusRepositoryImpl implements FocusRepository {
  final SupabaseClient _supabase;

  FocusRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<void> saveSession(FocusSession session) async {
    final model = FocusSessionModel.fromEntity(session);
    await _supabase.from('focus_sessions').insert(model.toJson());
  }
}
