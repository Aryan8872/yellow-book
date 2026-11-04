import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Clean flat segmented switcher for Sign In vs Create Account.
/// No neon gradients, no gaudy shadows, crisp 10px borders.
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
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(true),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: isLoginMode ? AppTheme.cardSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isLoginMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign In',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: isLoginMode ? FontWeight.w800 : FontWeight.w600,
                    color: isLoginMode ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: !isLoginMode ? AppTheme.cardSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isLoginMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Create Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: !isLoginMode ? FontWeight.w800 : FontWeight.w600,
                    color: !isLoginMode ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
