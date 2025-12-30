import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  static const empty = UserEntity(id: '', email: '');

  bool get isEmpty => this == UserEntity.empty;
  bool get isNotEmpty => this != UserEntity.empty;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  String get displayNameOrEmail => displayName != null && displayName!.isNotEmpty ? displayName! : email;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
