// dart:ui removed — no BackdropFilter used in nav bar (performance)
import 'package:flutter/material.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/core/services/app_update_service.dart';
import 'package:entertainer/core/services/update_available_dialog.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'account_page.dart';

class MainShellScreen extends StatefulWidget {
  final User user;

  const MainShellScreen({super.key, required this.user});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  final List<({IconData icon, IconData activeIcon, String label})> _navItems = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Discover'),
    (icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Explore'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      const SearchPage(),
      AccountPage(user: widget.user),
    ];

    // Check for in-app updates automatically on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppUpdate();
    });
  }

  Future<void> _checkAppUpdate() async {
    final updateInfo = await AppUpdateService.checkForUpdate();
    if (updateInfo != null && mounted) {
      UpdateAvailableDialog.show(context, updateInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFD3E4FE),
      // RepaintBoundary isolates page content so nav animation doesn't
      // invalidate the page layer and vice versa
      body: RepaintBoundary(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: RepaintBoundary(
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0053DB).withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              // No BackdropFilter — replaced with high-opacity solid color
              // to avoid forcing an off-screen compositing pass each frame
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1.5,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth / _navItems.length;
                      final pillWidth = itemWidth - 4;

                      return Stack(
                        children: [
                          // 1. Sliding Glass Gradient Indicator Pill
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.fastEaseInToSlowEaseOut,
                            left: _currentIndex * itemWidth + 2,
                            top: 2,
                            bottom: 2,
                            width: pillWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0053DB).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 2. Interactive Navigation Buttons Row
                          Row(
                            children: List.generate(_navItems.length, (index) {
                              final item = _navItems[index];
                              final isSelected = _currentIndex == index;

                              return Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (_currentIndex != index) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(26),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black54,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedCrossFade(
                                              duration: const Duration(milliseconds: 220),
                                              crossFadeState: isSelected
                                                  ? CrossFadeState.showFirst
                                                  : CrossFadeState.showSecond,
                                              firstChild: Icon(
                                                item.activeIcon,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              secondChild: Icon(
                                                item.icon,
                                                color: Colors.black54,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(item.label),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
