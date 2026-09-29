import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/ambient_background.dart';
import '../widgets/animated_auth_button.dart';
import '../widgets/auth_segmented_control.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // Text Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus Nodes for smooth keyboard traversal
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // Mode: true = Login Mode, false = Register Mode
  bool _isLoginMode = true;

  // Error States
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _formGeneralError;

  // Staggered Animation Controller
  late AnimationController _animationController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _formFade;
  late Animation<double> _formScale;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _formScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();

    _animationController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _formGeneralError = null;
    });
  }

  void _setMode(bool isLogin) {
    if (_isLoginMode == isLogin) return;
    FocusScope.of(context).unfocus();
    _clearErrors();
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    setState(() {
      _isLoginMode = isLogin;
    });
  }

  bool _validateForm() {
    _clearErrors();
    bool isValid = true;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isLoginMode) {
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();

      if (fullName.isEmpty) {
        _fullNameError = 'Required';
        _formGeneralError = 'Please enter your full name';
        isValid = false;
      }

      if (phone.isEmpty) {
        _phoneError = 'Required';
        _formGeneralError ??= 'Please enter your phone number';
        isValid = false;
      }
    }

    if (email.isEmpty) {
      _emailError = 'Required';
      _formGeneralError ??= 'Please enter your email address';
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _emailError = 'Invalid';
      _formGeneralError ??= 'Please enter a valid email address';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Required';
      _formGeneralError ??= 'Please enter your password';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Too short';
      _formGeneralError ??= 'Password must be at least 6 characters';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (_validateForm()) {
      final bloc = context.read<AuthBloc>();
      if (_isLoginMode) {
        bloc.add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
      } else {
        bloc.add(
          RegisterRequested(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    final user = state.user;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Welcome, ${user.fullName.isNotEmpty ? user.fullName : user.email}!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AuthError) {
                    setState(() {
                      _formGeneralError = state.message;
                    });
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Brand Logo & Title
                      FadeTransition(
                        opacity: _headerFade,
                        child: SlideTransition(
                          position: _headerSlide,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                                child: ClipOval(
                                    child: Image.asset('assets/logo.jpeg',width:120 ,height:120 ,
                                      fit: BoxFit.cover,
                                    )
                                ),
                              ),
                              const SizedBox(height: 18),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  _isLoginMode ? 'Welcome Back' : 'Create Account',
                                  key: ValueKey<bool>(_isLoginMode),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  _isLoginMode
                                      ? 'Sign in to access your OfferNepal rewards'
                                      : 'Join us to unlock exclusive discounts & offers',
                                  key: ValueKey<bool>(_isLoginMode),
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Glassmorphic Card Container
                      FadeTransition(
                        opacity: _formFade,
                        child: ScaleTransition(
                          scale: _formScale,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEAF1FF),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Top Segmented Switcher Pill
                                    AuthSegmentedControl(
                                      isLoginMode: _isLoginMode,
                                      onModeChanged: _setMode,
                                    ),
                                    const SizedBox(height: 20),

                                    // Form Level Error Banner (Zero Layout Shift on Inputs)
                                    AnimatedCrossFade(
                                      duration: const Duration(milliseconds: 250),
                                      crossFadeState: _formGeneralError != null
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                      firstChild: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Color(0xFFF87171),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _formGeneralError ?? '',
                                                style: const TextStyle(
                                                  color: Color(0xFFF87171),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      secondChild: const SizedBox.shrink(),
                                    ),

                                    // Fixed-Height Inputs with Smooth Transitions
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOutCubic,
                                      child: Column(
                                        children: [
                                          if (!_isLoginMode) ...[
                                            CustomTextField(
                                              key: const ValueKey('full_name_field'),
                                              controller: _fullNameController,
                                              labelText: 'Full Name',
                                              hintText: 'John Doe',
                                              prefixIcon: Icons.person_outline_rounded,
                                              errorText: _fullNameError,
                                              focusNode: _fullNameFocus,
                                              nextFocusNode: _emailFocus,
                                              onChanged: (_) {
                                                if (_fullNameError != null) {
                                                  setState(() => _fullNameError = null);
                                                }
                                              },
                                            ),
                                          ],

                                          CustomTextField(
                                            key: const ValueKey('email_field'),
                                            controller: _emailController,
                                            labelText: 'Email Address',
                                            hintText: 'name@example.com',
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                            errorText: _emailError,
                                            focusNode: _emailFocus,
                                            nextFocusNode:
                                                _isLoginMode ? _passwordFocus : _phoneFocus,
                                            onChanged: (_) {
                                              if (_emailError != null) {
                                                setState(() => _emailError = null);
                                              }
                                            },
                                          ),

                                          if (!_isLoginMode) ...[
                                            CustomTextField(
                                              key: const ValueKey('phone_field'),
                                              controller: _phoneController,
                                              labelText: 'Phone Number',
                                              hintText: '+1 234 567 8900',
                                              prefixIcon: Icons.phone_outlined,
                                              keyboardType: TextInputType.phone,
                                              errorText: _phoneError,
                                              focusNode: _phoneFocus,
                                              nextFocusNode: _passwordFocus,
                                              onChanged: (_) {
                                                if (_phoneError != null) {
                                                  setState(() => _phoneError = null);
                                                }
                                              },
                                            ),
                                          ],

                                          CustomTextField(
                                            key: const ValueKey('password_field'),
                                            controller: _passwordController,
                                            labelText: 'Password',
                                            hintText: '••••••••',
                                            prefixIcon: Icons.lock_outline_rounded,
                                            isPassword: true,
                                            errorText: _passwordError,
                                            focusNode: _passwordFocus,
                                            textInputAction: TextInputAction.done,
                                            onFieldSubmitted: (_) => _submitForm(),
                                            onChanged: (_) {
                                              if (_passwordError != null) {
                                                setState(() => _passwordError = null);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (_isLoginMode)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            // Forgot password handling
                                          },
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: Color( 0xFF346EF6),

                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 16),

                                    // Action Button
                                    AnimatedAuthButton(
                                      text: _isLoginMode ? 'Sign In' : 'Create Account',
                                      isLoading: isLoading,
                                      onPressed: _submitForm,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Privacy & Trust Footer
                      FadeTransition(
                        opacity: _formFade,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Color(0xFF346EF6),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Secured with 256-bit encryption',
                              style: TextStyle(
                                color: Color(0xFF346EF6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
