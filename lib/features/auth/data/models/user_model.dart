import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromSupabase(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['full_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  // To convert back to Entity usually just polymorphism is enough, 
  // but explicitly:
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
