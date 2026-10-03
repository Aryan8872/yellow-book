import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/core/services/app_update_service.dart';
import 'package:entertainer/core/services/update_available_dialog.dart';
import 'package:entertainer/features/home/presentation/pages/home_page.dart';
import 'package:entertainer/features/search/presentation/pages/search_page.dart';
import 'package:entertainer/features/profile/presentation/pages/account_page.dart';

/// Global App Shell Layout container (`MainShellScreen`)
/// Implements the floating minimalist black capsule dock from Screenshot 3:
/// - Crisp pitch-black capsule pill (#111116)
/// - 3 tabs: Home, Explore, Profile
/// - Smooth animated white highlight pill for active state
class MainShellScreen extends StatefulWidget {
  final User user;

  const MainShellScreen({super.key, required this.user});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  final List<({IconData icon, IconData activeIcon, String label})> _navItems = const [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
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
      backgroundColor: AppTheme.canvasBg,
      body: RepaintBoundary(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.darkPill,
              borderRadius: BorderRadius.circular(34),
              boxShadow: AppTheme.floatingDockShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentIndex != index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? Colors.white : Colors.white54,
                            size: 21,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 10.5,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
