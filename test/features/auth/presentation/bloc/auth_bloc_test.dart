import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ripple/features/auth/domain/entities/user_entity.dart';
import 'package:ripple/features/auth/domain/usecases/auth_usecases.dart';
import 'package:ripple/features/auth/presentation/bloc/auth_bloc.dart';

class MockGetAuthStream extends Mock implements GetAuthStream {}
class MockSignOut extends Mock implements SignOut {}

void main() {
  late AuthBloc authBloc;
  late MockGetAuthStream mockGetAuthStream;
  late MockSignOut mockSignOut;

  const tUser = UserEntity(id: '123', email: 'test@example.com');

  setUp(() {
    mockGetAuthStream = MockGetAuthStream();
    mockSignOut = MockSignOut();
    authBloc = AuthBloc(
      getAuthStream: mockGetAuthStream,
      signOut: mockSignOut,
    );
  });

  // Cleanup
  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthUnknown', () {
      expect(authBloc.state, const AuthUnknown());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when AuthSubscriptionRequested receives user',
      build: () {
        when(() => mockGetAuthStream()).thenAnswer((_) => Stream.value(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSubscriptionRequested()),
      expect: () => [
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when AuthSubscriptionRequested receives empty user',
      build: () {
        when(() => mockGetAuthStream()).thenAnswer((_) => Stream.value(UserEntity.empty));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSubscriptionRequested()),
      expect: () => [
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'calls SignOut usecase when AuthLogoutRequested is added',
      build: () {
        when(() => mockSignOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      verify: (_) {
        verify(() => mockSignOut()).called(1);
      },
    );
  });
}
