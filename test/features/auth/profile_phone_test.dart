import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/errors/failure.dart';
import 'package:entertainer/core/network/api_endpoints.dart';
import 'package:entertainer/core/usecase/usecase.dart';
import 'package:entertainer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/login_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/logout_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/register_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:entertainer/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockLoginUsecase extends Mock implements LoginUsecase {}

class _MockRegisterUsecase extends Mock implements RegisterUsecase {}

class _MockGetCurrentUserUsecase extends Mock
    implements GetCurrentUserUsecase {}

class _MockLogoutUsecase extends Mock implements LogoutUsecase {}

class _MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class _MockGoogleAuthUsecase extends Mock implements GoogleAuthUsecase {}

class _MockForgotPasswordUsecase extends Mock
    implements ForgotPasswordUsecase {}

class _MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

void main() {
  late _MockDio dio;
  late AuthRemoteDataSourceImpl dataSource;
  late _MockGetCurrentUserUsecase getCurrentUserUsecase;
  late _MockUpdateProfileUsecase updateProfileUsecase;

  setUpAll(() {
    registerFallbackValue(const UpdateProfileParams(name: 'fallback'));
  });

  setUp(() {
    dio = _MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio);
    getCurrentUserUsecase = _MockGetCurrentUserUsecase();
    updateProfileUsecase = _MockUpdateProfileUsecase();
  });

  test(
    'sends phone to the existing profile endpoint and parses the response',
    () async {
      when(() => dio.patch(ApiEndpoints.profile, data: any(named: 'data')))
          .thenAnswer(
            (_) async => Response<Map<String, dynamic>>(
              requestOptions: RequestOptions(path: ApiEndpoints.profile),
              data: {
                'success': true,
                'data': {
                  'id': 'user-1',
                  'email': 'user@example.com',
                  'name': 'Test User',
                  'phone': '+9779812345678',
                  'role': 'USER',
                  'isActive': true,
                  'isVerified': true,
                  'createdAt': '2026-01-01T00:00:00.000Z',
                },
              },
            ),
          );

      final result = await dataSource.updateProfile(
        const UpdateProfileParams(name: 'Test User', phone: '+9779812345678'),
      );

      final requestData =
          verify(
                () => dio.patch(
                  ApiEndpoints.profile,
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(requestData, {'name': 'Test User', 'phone': '+9779812345678'});
      expect(result.phone, '+9779812345678');
    },
  );

  blocTest<AuthBloc, AuthState>(
    'refreshes the shared signed-in user after a successful profile update',
    build: () {
      when(() => getCurrentUserUsecase.call(const NoParams()))
          .thenAnswer((_) async => Right(_signedInUser));
      when(() => updateProfileUsecase.call(any()))
          .thenAnswer((_) async => Right(_updatedUser));
      return _createAuthBloc(getCurrentUserUsecase, updateProfileUsecase);
    },
    act: (bloc) async {
      bloc.add(const CheckAuthStatusRequested());
      await bloc.stream.firstWhere((state) => state is AuthAuthenticated);
      bloc.add(
        const UpdateProfileRequested(
          name: 'Updated User',
          phone: '+9779812345678',
        ),
      );
    },
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthAuthenticated>(),
      isA<AuthProfileUpdating>(),
      isA<AuthAuthenticated>().having(
        (state) => state.user,
        'updated signed-in user',
        same(_updatedUser),
      ),
    ],
  );

  testWidgets('keeps the edit form open with values after a save failure', (
    tester,
  ) async {
    when(() => getCurrentUserUsecase.call(const NoParams()))
        .thenAnswer((_) async => Right(_signedInUser));
    when(() => updateProfileUsecase.call(any())).thenAnswer(
      (_) async => const Left(
        ValidationFailure.withDetails('Phone number is already in use'),
      ),
    );
    final bloc = _createAuthBloc(getCurrentUserUsecase, updateProfileUsecase);
    addTearDown(bloc.close);
    bloc.add(const CheckAuthStatusRequested());
    await bloc.stream.firstWhere((state) => state is AuthAuthenticated);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const EditProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    final phoneField = find.byType(TextFormField).at(1);
    await tester.enterText(phoneField, '9812345678');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsOneWidget);
    expect(find.text('Phone number is already in use'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(phoneField).controller!.text,
      '9812345678',
    );
  });

  blocTest<AuthBloc, AuthState>(
    'keeps the signed-in user and reports recoverable profile failures',
    build: () {
      when(() => getCurrentUserUsecase.call(const NoParams()))
          .thenAnswer((_) async => Right(_signedInUser));
      when(() => updateProfileUsecase.call(any())).thenAnswer(
        (_) async => const Left(
          ValidationFailure.withDetails('Phone number is already in use'),
        ),
      );
      return _createAuthBloc(getCurrentUserUsecase, updateProfileUsecase);
    },
    act: (bloc) async {
      bloc.add(const CheckAuthStatusRequested());
      await bloc.stream.firstWhere((state) => state is AuthAuthenticated);
      bloc.add(
        const UpdateProfileRequested(
          name: 'Test User',
          phone: '+9779812345678',
        ),
      );
    },
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthAuthenticated>().having(
        (state) => state.user,
        'signed-in user',
        same(_signedInUser),
      ),
      isA<AuthProfileUpdating>().having(
        (state) => state.user,
        'user while saving',
        same(_signedInUser),
      ),
      isA<AuthProfileUpdateFailure>()
          .having((state) => state.user, 'preserved user', same(_signedInUser))
          .having(
            (state) => state.message,
            'error message',
            'Phone number is already in use',
          ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'requires login after a confirmed unauthorized profile response',
    build: () {
      when(() => getCurrentUserUsecase.call(const NoParams()))
          .thenAnswer((_) async => Right(_signedInUser));
      when(() => updateProfileUsecase.call(any())).thenAnswer(
        (_) async => const Left(
          AuthFailure.withDetails('Unauthorized', statusCode: 401),
        ),
      );
      return _createAuthBloc(getCurrentUserUsecase, updateProfileUsecase);
    },
    act: (bloc) async {
      bloc.add(const CheckAuthStatusRequested());
      await bloc.stream.firstWhere((state) => state is AuthAuthenticated);
      bloc.add(
        const UpdateProfileRequested(
          name: 'Test User',
          phone: '+9779812345678',
        ),
      );
    },
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthAuthenticated>(),
      isA<AuthProfileUpdating>(),
      isA<AuthError>().having(
        (state) => state.message,
        'session expiry explanation',
        contains('session has expired or been revoked'),
      ),
    ],
  );
}

const _signedInUser = User(
  id: 'user-1',
  email: 'user@example.com',
  name: 'Test User',
  phone: '+9779812345678',
);

const _updatedUser = User(
  id: 'user-1',
  email: 'user@example.com',
  name: 'Updated User',
  phone: '+9779812345678',
);

AuthBloc _createAuthBloc(
  _MockGetCurrentUserUsecase getCurrentUserUsecase,
  _MockUpdateProfileUsecase updateProfileUsecase,
) {
  return AuthBloc(
    _MockLoginUsecase(),
    _MockRegisterUsecase(),
    getCurrentUserUsecase,
    _MockLogoutUsecase(),
    updateProfileUsecase,
    _MockGoogleAuthUsecase(),
    _MockForgotPasswordUsecase(),
    _MockResetPasswordUsecase(),
  );
}
