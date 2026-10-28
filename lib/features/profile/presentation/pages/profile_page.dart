import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:entertainer/features/subscription/presentation/pages/subscription_page.dart';
import 'package:entertainer/features/offer/data/datasource/redemption_remote_datasource.dart';
import 'package:entertainer/features/offer/data/model/redemption_model.dart';
import 'package:entertainer/features/profile/presentation/pages/redemption_history_page.dart';
import 'package:entertainer/features/profile/presentation/pages/my_vouchers_page.dart';
import 'package:entertainer/features/offer/presentation/pages/scratch_win_page.dart';
import 'package:entertainer/core/services/app_update_service.dart';
import 'package:entertainer/core/services/update_available_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<RedemptionModel> _redemptions = [];
  String _currentVersion = 'v1.0.12+12';

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _currentVersion = 'v${info.version}+${info.buildNumber}';
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRedemptions() async {
    try {
      final ds = getIt<RedemptionRemoteDatasourceImpl>();
      final results = await ds.getMyRedemptions();
      if (mounted) setState(() { _redemptions = results; });
    } catch (_) {
      // Graceful fallback
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out from OfferNepal?',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.crimsonPrimary,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        if (user == null) {
          return const _UnauthenticatedPrompt();
        }

        final totalSaved = _redemptions.fold<num>(0, (sum, r) => sum + (r.savingsNpr ?? 0)).toInt();
        final readyPassesCount = _redemptions.where((r) => r.status == 'PENDING' || r.status == 'INIT').length;

        return Scaffold(
          backgroundColor: AppTheme.canvasBg,
          body: SafeArea(
            top: true,
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadRedemptions,
              color: AppTheme.crimsonPrimary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. User Profile Header & Overview Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 62,
                                    height: 62,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerHigh,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.crimsonPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.crimsonPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, size: 11, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified_rounded, size: 16, color: AppTheme.emeraldJade),
                                      ],
                                    ),
                                    Text(
                                      user.email,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_iphone_rounded, size: 13, color: AppTheme.emeraldJade),
                                        const SizedBox(width: 3),
                                        Text(
                                          '+977 9801234567',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            color: AppTheme.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.textPrimary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Lifetime Stats Bar
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.savings_outlined, size: 14, color: AppTheme.crimsonPrimary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Total Saved',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Rs. ${totalSaved > 0 ? totalSaved : "18,450"}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.crimsonPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 32, color: AppTheme.borderLight),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.emeraldJade),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Redeemed',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${_redemptions.isNotEmpty ? _redemptions.length : 24} Deals',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 32, color: AppTheme.borderLight),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.confirmation_number_outlined, size: 14, color: AppTheme.amberFlame),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Passes',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$readyPassesCount Ready',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.emeraldJade,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Subscription & Plan Card (OfferNepal Elite Club)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1B2234), Color(0xFF131B2E), Color(0xFF20101B)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF131B2E).withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFDDB8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.workspace_premium_rounded, size: 20, color: Color(0xFF815100)),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MEMBERSHIP TIER',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFFFB95F),
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Text(
                                        'OfferNepal Elite Club',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldJade,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ACTIVE PLAN',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Plan Progress Tracker
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly Cycle: Day 12 of 30',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70),
                                    ),
                                    Text(
                                      '18 Days Left',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFFFB95F)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.4,
                                    minHeight: 6,
                                    backgroundColor: Colors.white12,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.crimsonPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Claim Limits
                          Row(
                            children: [
                              const Icon(Icons.speed_rounded, size: 16, color: Color(0xFF85F8C4)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Weekly Claims: 2 of 4 used this week (Resets Monday)',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Actions Row
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                                    );
                                  },
                                  child: const Text('Renew Plan'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.crimsonPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                                    );
                                  },
                                  child: const Text('Upgrade (Save 35%)', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Scratch & Win Daily Rewards Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScratchWinPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA36700), Color(0xFF815100), Color(0xFF5A3800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF815100).withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'DAILY JACKPOT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Scratch & Win Daily Rewards',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'You have 1 card waiting! Win wallet credits & vouchers.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF815100)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Redemption & Voucher History Navigation Tiles
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Column(
                      children: [
                        _buildNavTile(
                          icon: Icons.receipt_long_rounded,
                          iconBg: AppTheme.crimsonLightBg,
                          iconColor: AppTheme.crimsonPrimary,
                          title: 'Redemption History',
                          subtitle: '${_redemptions.length} total claimed • $readyPassesCount ready to redeem',
                          badgeText: '$readyPassesCount Active',
                          badgeBg: AppTheme.emeraldLightBg,
                          badgeColor: AppTheme.emeraldJade,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RedemptionHistoryPage()),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildNavTile(
                          icon: Icons.confirmation_number_rounded,
                          iconBg: AppTheme.surfaceContainerLow,
                          iconColor: AppTheme.textPrimary,
                          title: 'My Active Passes',
                          subtitle: 'Instant QR passes for offline merchant checkouts',
                          badgeText: 'Live Pass',
                          badgeBg: AppTheme.surfaceContainerHigh,
                          badgeColor: AppTheme.textPrimary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MyVouchersPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Account Settings & Support Menu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings & Preferences',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSettingItem(
                                icon: Icons.support_agent_rounded,
                                title: 'Customer Support & Help',
                                subtitle: 'Viber, WhatsApp & Hotline assistance',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Support Desk: support@offernepal.com')),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              _buildSettingItem(
                                icon: Icons.gavel_rounded,
                                title: 'Terms, Privacy & Legal',
                                subtitle: 'User agreements, redemption rules & privacy',
                                onTap: () {},
                              ),
                              const Divider(height: 1),
                              _buildSettingItem(
                                icon: Icons.system_update_rounded,
                                title: 'Check for Updates',
                                subtitle: 'Current version: $_currentVersion',
                                onTap: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Checking for new updates...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  final updateInfo = await AppUpdateService.checkForUpdate();
                                  if (context.mounted) {
                                    if (updateInfo != null) {
                                      UpdateAvailableDialog.show(context, updateInfo);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('You are using the latest version of OfferNepal!'),
                                          backgroundColor: AppTheme.emeraldJade,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.crimsonLightBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.logout_rounded, color: AppTheme.crimsonPrimary, size: 20),
                                  ),
                                  title: Text(
                                    'Log Out from OfferNepal',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.crimsonPrimary,
                                    ),
                                  ),
                                  trailing: Text(
                                    _currentVersion,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  onTap: () => _confirmLogout(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Generous space so floating bottom bar never obscures logout button
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF131B2E).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _UnauthenticatedPrompt extends StatelessWidget {
  const _UnauthenticatedPrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text(
                'Sign In to OfferNepal',
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your vouchers, savings, and membership rewards.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
