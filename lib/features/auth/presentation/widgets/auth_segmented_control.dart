import 'package:flutter/material.dart';

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
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 2;

          return Stack(
            children: [
              // Sliding Active Tab Pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.fastOutSlowIn,
                alignment: isLoginMode
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: tabWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0053DB), Color(0xFF818CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                        blurRadius: 10,
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
                            color: isLoginMode
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: isLoginMode
                                ? FontWeight.bold
                                : FontWeight.w500,
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
                            color: !isLoginMode
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: !isLoginMode
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          child: const Text('Sign Up'),
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
