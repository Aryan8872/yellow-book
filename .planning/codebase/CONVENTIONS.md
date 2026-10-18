---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# Code Conventions

**Analysis Date:** 2026-10-07

## Code Style

### Dart/Flutter Conventions

- **Effective Dart:** Follow official Dart style guide
- **Flutter Lints:** Use `flutter_lints` package
- **File Naming:** snake_case for files (e.g., `auth_bloc.dart`)
- **Class Naming:** PascalCase for classes (e.g., `AuthBloc`)
- **Variable Naming:** camelCase for variables (e.g., `accessToken`)
- **Constant Naming:** camelCase with lowercase first letter or UPPER_CASE for globals
- **Private Members:** Prefix with underscore (e.g., `_isRefreshing`)

### Import Organization

```dart
// 1. Dart imports
import 'dart:async';

// 2. Package imports
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// 3. Relative imports (core first, then features)
import 'package:entertainer/core/storage/token_storage.dart';
import 'package:entertainer/features/auth/data/datasources/remote/auth_remote_datasource.dart';
```

## Architecture Patterns

### Clean Architecture

- **Domain Layer:** Pure Dart, no Flutter dependencies
- **Data Layer:** Can use external libraries (Dio, Floor)
- **Presentation Layer:** Flutter widgets and BLoC
- **Core Layer:** Shared utilities, no feature dependencies

### BLoC Pattern

- **Events:** Suffix with `Event` (e.g., `LoginEvent`)
- **States:** Suffix with `State` (e.g., `AuthState`)
- **BLoC:** Suffix with `Bloc` (e.g., `AuthBloc`)
- **Use Cases:** Suffix with `UseCase` (e.g., `LoginUseCase`)

### Repository Pattern

- **Interface:** `{Feature}Repository` in domain layer
- **Implementation:** `{Feature}RepositoryImpl` in data layer
- **Data Sources:** `{Feature}RemoteDatasource`, `{Feature}LocalDatasource`

## Code Generation

### Freezed

- Use for immutable data classes
- Annotate with `@freezed`
- Run `flutter pub run build_runner build` to generate

### Injectable

- Use `@injectable` or `@LazySingleton` annotations
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Register dependencies in `dependency_injection.dart`

### JSON Serialization

- Use `@JsonSerializable()` annotation
- Include `json_annotation` package
- Generate with build_runner

## File Structure

### Feature Module Template

```
feature_name/
├── data/
│   ├── datasources/
│   │   ├── remote_datasource.dart
│   │   └── local_datasource.dart
│   ├── models/
│   │   └── entity_model.dart
│   └── repositories/
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── entity.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
│       ├── action_usecase.dart
│       └── action_params.dart
└── presentation/
    ├── bloc/
    │   ├── feature_bloc.dart
    │   ├── feature_event.dart
    │   └── feature_state.dart
    ├── pages/
    │   └── feature_page.dart
    └── widgets/
        └── feature_widget.dart
```

## Naming Conventions

### BLoC

```dart
// Event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}

// State
class Authenticated extends AuthState {
  final User user;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ...
}
```

### Use Cases

```dart
// Use case
class LoginUseCase extends UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) {
    // ...
  }
}

// Params
class LoginParams {
  final String email;
  final String password;
}
```

### Repositories

```dart
// Interface (domain)
abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
}

// Implementation (data)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  
  AuthRepositoryImpl(this.remote);
  
  @override
  Future<Either<Failure, AuthResponse>> login(String email, String password) {
    // ...
  }
}
```

## Error Handling

### Either Pattern (dartz)

- Use `Either<Failure, Success>` for operations that can fail
- Left side: `Failure` object
- Right side: Success value

```dart
Future<Either<Failure, AuthResponse>> login(String email, String password) {
  try {
    final response = await remote.login(email, password);
    return Right(response);
  } catch (e) {
    return Left(ServerFailure());
  }
}
```

### Failure Types

- Define failure types in `core/errors/failure.dart`
- Examples: `ServerFailure`, `NetworkFailure`, `CacheFailure`

## State Management

### BLoC Usage

```dart
// In widget
BlocProvider<AuthBloc>(
  create: (context) => getIt<AuthBloc>(),
  child: Consumer<AuthBloc>(
    builder: (context, bloc, child) {
      // ...
    },
  ),
)

// Emit events
context.read<AuthBloc>().add(LoginRequested(email, password));

// Listen to states
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is Authenticated) {
      return HomeScreen();
    }
    return LoginScreen();
  },
)
```

## Dependency Injection

### Service Locator

```dart
// Register with annotations
@LazySingleton()
class TokenStorage {
  // ...
}

// Use in code
final storage = getIt<TokenStorage>();
```

### Constructor Injection

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
}
```

## Widget Organization

### Widget Composition

- Prefer composition over inheritance
- Extract reusable widgets to separate files
- Use `const` constructors where possible

### Widget Naming

- Screen widgets: `{Screen}Page` (e.g., `LoginPage`)
- Feature widgets: `{Feature}Widget` (e.g., `AuthForm`)
- Reusable widgets: descriptive names (e.g., `GlassContainer`)

## Comments and Documentation

### Public API Documentation

```dart
/// Authenticates a user with email and password.
///
/// Returns [Either] with [Failure] on error or [AuthResponse] on success.
Future<Either<Failure, AuthResponse>> login(
  String email,
  String password,
);
```

### Inline Comments

- Use for complex logic explanations
- Avoid obvious comments
- Keep comments up-to-date

## Constants

### String Constants

```dart
// In core/constants/ or feature-specific constants file
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const int timeoutSeconds = 15;
}
```

### Magic Numbers

- Avoid magic numbers
- Use named constants
- Document if necessary

## Testing Conventions

### Test File Naming

- Unit tests: `{file}_test.dart` in same directory
- Widget tests: `{widget}_test.dart`
- Integration tests: `integration_test/`

### Test Structure

```dart
group('AuthBloc', () {
  test('emits Authenticated when login succeeds', () async {
    // Arrange
    final bloc = AuthBloc(mockLoginUseCase);
    
    // Act
    bloc.add(LoginRequested('test@example.com', 'password'));
    
    // Assert
    expectLater(
      bloc.stream,
      emitsInOrder([AuthLoading(), Authenticated(mockUser)]),
    );
  });
});
```

## Git Conventions

### Commit Messages

- Use conventional commits
- Format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`

### Branch Naming

- Feature: `feature/feature-name`
- Fix: `fix/bug-description`
- Refactor: `refactor/refactor-description`

---
*Codebase analysis: 2026-10-07*
