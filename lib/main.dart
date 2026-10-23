import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'core/di/service_loader.dart';
import 'core/layout/main_shell_screen.dart';
import 'core/services/push_notification_service.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'firebase_options.dart';

import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Custom error widget instead of gray/black screen on uncaught build errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    developer.log('Flutter Error caught: ${details.exception}', error: details.exception, stackTrace: details.stack);
    return Scaffold(
      backgroundColor: const Color(0xFFEDEBF8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111116)),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF787A8D)),
              ),
            ],
          ),
        ),
      ),
    );
  };

  try {
    // Initialize Firebase using generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialise FCM push notifications after Firebase is ready
    await PushNotificationService().init();
  } catch (e, st) {
    developer.log('Firebase initialization error (proceeding with fallback): $e', error: e, stackTrace: st);
  }

  try {
    await configureDependencies();
    // Initialize token storage from secure storage
    await getIt<TokenStorage>().init();
  } catch (e, st) {
    developer.log('configureDependencies error: $e', error: e, stackTrace: st);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() async {
    // Handle initial link when app is cold-launched
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      // Handle error silently
    }

    // Handle incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    // Handle password reset deep link: offernepal://reset/{token}
    if (uri.path.startsWith('/reset/')) {
      final token = uri.pathSegments.last;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(token: token),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) {
        final bloc = getIt<AuthBloc>();
        if (getIt<TokenStorage>().hasAccess()) {
          bloc.add(const CheckAuthStatusRequested());
        }
        return bloc;
      },
      child: MaterialApp(
        title: 'OfferNepal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    // If no token exists at all, immediately display LoginPage
    if (!getIt<TokenStorage>().hasAccess()) {
      return const LoginPage();
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Can handle global side effects if any
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return MainShellScreen(user: state.user);
        } else if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.canvasBg,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPeriwinkle),
              ),
            ),
          );
        }
        // AuthInitial or AuthError fallback
        return const LoginPage();
      },
    );
  }
}
