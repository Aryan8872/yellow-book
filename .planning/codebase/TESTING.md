---
last_mapped_commit: f6310e9fedcdac500a2a7c1adbdb2aa4a2d82305
last_mapped_at: 2026-10-07
---

# Testing

**Analysis Date:** 2026-10-07

## Testing Framework

- **flutter_test** - Flutter's testing framework
- **mockito** - Mocking library (not currently in dependencies)
- **bloc_test** - BLoC testing utilities (not currently in dependencies)

## Test Structure

### Test Directory

```
test/
├── unit/                    # Unit tests (not present)
├── widget/                  # Widget tests (not present)
└── integration/             # Integration tests (not present)
```

### Current State

- **test/** directory exists but appears empty
- No test files found in the codebase
- No testing utilities configured

## Testing Strategy (Recommended)

### Unit Tests

**What to Test:**
- Use cases (domain layer)
- Repository implementations
- Data source transformations
- Utility functions
- Business logic

**Example Structure:**

```
test/unit/features/auth/
├── usecases/
│   └── login_usecase_test.dart
├── repositories/
│   └── auth_repository_impl_test.dart
└── datasources/
    └── auth_remote_datasource_test.dart
```

### Widget Tests

**What to Test:**
- Widget rendering
- User interactions
- State changes
- Navigation
- Form validation

**Example Structure:**

```
test/widget/features/auth/
├── pages/
│   ├── login_page_test.dart
│   └── register_page_test.dart
└── widgets/
    ├── auth_form_test.dart
    └── custom_text_field_test.dart
```

### Integration Tests

**What to Test:**
- Full user flows
- API integration
- Database operations
- Navigation flows
- Authentication flows

**Example Structure:**

```
integration_test/
├── auth_flow_test.dart
├── home_flow_test.dart
└── offer_redemption_flow_test.dart
```

## BLoC Testing

### Recommended Setup

Add dependencies:

```yaml
dev_dependencies:
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
```

### Example BLoC Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late AuthBloc authBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    authBloc = AuthBloc(mockLoginUseCase);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login succeeds',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => Right(mockUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested('test@example.com', 'password')),
      expect: () => [AuthLoading(), Authenticated(mockUser)],
    );
  });
}
```

## Widget Testing

### Example Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('Login page renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(mockLoginUseCase),
          child: LoginPage(),
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });
}
```

## Mocking

### Recommended Libraries

- **mocktail** - Modern mocking library (type-safe)
- **mockito** - Traditional mocking (if needed)

### Example Mock

```dart
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  test('login calls repository', () async {
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => Right(mockResponse));

    final useCase = LoginUseCase(mockRepository);
    await useCase(LoginParams('email', 'password'));

    verify(() => mockRepository.login('email', 'password')).called(1);
  });
}
```

## Test Coverage

### Current State

- No test coverage data available
- No coverage tool configured

### Recommended Setup

Add dependencies:

```yaml
dev_dependencies:
  coverage: ^1.6.0
```

Run coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Golden Tests

### Purpose

- Visual regression testing
- UI consistency verification
- Theme validation

### Example

```dart
testWidgets('Login page golden test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoginPage(),
    ),
  );

  await expectLater(
    find.byType(LoginPage),
    matchesGoldenFile('goldens/login_page.png'),
  );
});
```

## Integration Testing

### Current State

- No integration tests present
- `integration_test/` directory not present

### Recommended Setup

Create integration test directory:

```bash
mkdir -p integration_test
```

### Example Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:entertainer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full auth flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to login
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Enter credentials
    await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password');

    // Submit
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify home screen
    expect(find.text('Home'), findsOneWidget);
  });
}
```

## Testing Best Practices

### General Guidelines

- Write tests before or alongside code (TDD recommended)
- Keep tests independent and isolated
- Use descriptive test names
- Test behavior, not implementation
- Mock external dependencies
- Keep tests fast (unit tests should be <100ms)

### BLoC Testing

- Test all event-to-state transitions
- Test error states
- Test loading states
- Mock use cases

### Widget Testing

- Test widget rendering
- Test user interactions
- Test state changes
- Test accessibility
- Use `pumpAndSettle()` for async operations

### Integration Testing

- Test critical user flows
- Test API integration
- Test navigation
- Test persistence
- Run on real devices/emulators

## Current Gaps

### Missing Test Infrastructure

- No test files present
- No mocking libraries configured
- No BLoC testing utilities
- No integration test setup
- No coverage reporting

### Recommended Actions

1. Add testing dependencies to `pubspec.yaml`
2. Create test directory structure
3. Add basic unit tests for use cases
4. Add widget tests for critical screens
5. Add integration tests for auth flow
6. Set up coverage reporting
7. Configure CI to run tests

## Test Configuration

### Recommended pubspec.yaml Additions

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
  integration_test:
    sdk: flutter
  coverage: ^1.6.0
  flutter_driver:
    sdk: flutter
```

---
*Codebase analysis: 2026-10-07*
