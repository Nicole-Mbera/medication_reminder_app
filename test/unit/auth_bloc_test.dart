import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medremind/logic/auth/auth_bloc.dart';
import 'package:medremind/logic/auth/auth_event.dart';
import 'package:medremind/logic/auth/auth_state.dart';
import 'package:medremind/data/repositories/auth_repository.dart';
import 'package:medremind/data/models/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  final testUser = UserModel(
    uid: 'user_123',
    email: 'test@medremind.com',
    fullName: 'Test Patient',
    phoneNumber: '555-0192',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc Unit Tests', () {
    test('initial state is AuthInitial', () {
      expect(AuthBloc(authRepository: mockAuthRepository).state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when AppStarted is added and user is logged in',
      build: () {
        when(() => mockAuthRepository.currentUser).thenReturn(testUser);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [AuthAuthenticated(user: testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(
          () => mockAuthRepository.signInWithEmail(
            email: 'test@medremind.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          email: 'test@medremind.com',
          password: 'password123',
        ),
      ),
      expect: () => [AuthLoading(), AuthAuthenticated(user: testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with exception',
      build: () {
        when(
          () => mockAuthRepository.signInWithEmail(
            email: 'bad@email.com',
            password: 'wrong',
          ),
        ).thenThrow(Exception('Invalid email or password.'));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'bad@email.com', password: 'wrong'),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Invalid email or password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      build: () {
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );
  });
}
