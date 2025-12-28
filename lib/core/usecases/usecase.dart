import 'package:equatable/equatable.dart';

/// Base UseCase abstract class
/// [T] is the return type of the use case
/// [Params] is the parameters required by the use case
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Use this when a use case doesn't require any parameters
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
