import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';

class AuthSegmentedControl extends StatelessWidget {
  final bool isLoginMode;
  final ValueChanged<bool> onModeChanged;

  const AuthSegmentedControl({
    super.key,
    required this.isLoginMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 4) / 2;

          return Stack(
            children: [
              // Sliding Active Tab Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: isLoginMode
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: tabWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.darkPill,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkPill.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Titles
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onModeChanged(true),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isLoginMode ? Colors.white : AppTheme.textSecondary,
                            fontWeight: isLoginMode ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onModeChanged(false),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: !isLoginMode ? Colors.white : AppTheme.textSecondary,
                            fontWeight: !isLoginMode ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
