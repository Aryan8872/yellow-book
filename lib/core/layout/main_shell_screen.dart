import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/widgets/offline_banner.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/home/presentation/pages/home_page.dart';
import 'package:entertainer/features/search/presentation/pages/search_page.dart';
import 'package:entertainer/features/profile/presentation/pages/profile_page.dart';
import 'package:entertainer/features/offer/presentation/pages/favourites_page.dart';
import 'package:entertainer/features/offer/presentation/bloc/favourites_bloc.dart';
import 'package:entertainer/core/services/app_update_service.dart';
import 'package:entertainer/core/services/update_available_dialog.dart';

/// Global App Shell Layout container (`MainShellScreen`)
/// Implements a curved-notch bottom navigation bar with a floating center FAB:
/// - White/frosted BottomAppBar with CircularNotchedRectangle cutout
/// - 4 side tabs: Home | Explore | [notch spacer] | Saved | Profile
/// - Center floating FAB with OfferNepal logo
/// - Active indicator dot below the active tab icon
class MainShellScreen extends StatefulWidget {
  final User user;

  const MainShellScreen({super.key, required this.user});

  /// Static helper allowing child widgets (e.g. HomePage header, Favourites empty state)
  /// to switch tabs within the persistent shell without losing bottom navigation.
  static void switchTab(BuildContext context, int tabIndex) {
    final state = context.findAncestorStateOfType<_MainShellScreenState>();
    if (state != null) {
      state._onTabTapped(tabIndex);
    }
  }

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  // 0=Home, 1=Explore, 2=Center(FAB), 3=Saved, 4=Profile
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      const SearchPage(),
      const SizedBox(), // placeholder for center FAB tab
      const FavouritesPage(),
      const ProfilePage(),
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

  /// Map logical tab index to page widget index (skip center slot 2)
  int get _pageIndex {
    if (_currentIndex < 2) return _currentIndex;
    if (_currentIndex == 2) return 0; // FAB → home or flash deals
    return _currentIndex - 1; // 3→2 (Saved), 4→3 (Profile)
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center FAB tapped — navigate to Explore/search as a flash deals hub
      setState(() => _currentIndex = 1);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.canvasBg,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _OfferNepalFAB(
        isActive: _currentIndex == 2,
        onTap: () => _onTabTapped(2),
      ),
      bottomNavigationBar: _NotchedNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        bottomInset: bottomInset,
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RepaintBoundary(
              child: IndexedStack(
                index: _pageIndex,
                children: [
                  _pages[0], // Home
                  _pages[1], // Explore
                  _pages[3], // Saved
                  _pages[4], // Profile
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Action Button ──────────────────────────────────────────────────

class _OfferNepalFAB extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _OfferNepalFAB({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE11D48), Color(0xFFBE0037)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.40),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.22),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: isActive ? 3.0 : 2.0,
          ),
        ),
        child: Semantics(
          label: 'OfferNepal Deals',
          button: true,
          child: Center(
            child: ClipOval(
              child: Image.asset(
                'assets/logo.jpeg',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Notched Bottom Navigation Bar ──────────────────────────────────────────

class _NotchedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomInset;

  const _NotchedNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 7.0,
      color: Colors.white,
      elevation: 0,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                // Tab 0: Home
                _NavTab(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                // Tab 1: Explore
                _NavTab(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Explore',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                // Center notch spacer
                const Expanded(child: SizedBox()),
                // Tab 3: Saved
                _NavTab(
                  icon: Icons.bookmark_border_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'Saved',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                // Tab 4: Profile
                _NavTab(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Individual Nav Tab ──────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFBE0037);
    const inactiveColor = Color(0xFF8C8FA5);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
