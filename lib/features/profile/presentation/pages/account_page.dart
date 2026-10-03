import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';
import 'package:entertainer/core/services/app_update_service.dart';
import 'package:entertainer/core/services/update_available_dialog.dart';

class AccountPage extends StatelessWidget {
  final User user;

  const AccountPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.canvasBg,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // 1. Header Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'My Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Profile Summary Card (Screenshot 3 Profile Selector Style)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppTheme.softCardShadow,
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppTheme.darkAnchor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.name.isNotEmpty ? user.name : 'Valued VIP Member',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.pastelCanary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "GOLD VIP",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.darkAnchor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded, size: 14, color: AppTheme.savingsGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Verified Membership",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: AppTheme.savingsGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: AppTheme.borderSubtle),
                    const SizedBox(height: 16),

                    // Metrics Strip (NPR 28,450 / 14 Redemptions / Dec 2026)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Total Saved", "NPR 28,450", AppTheme.textPrimary),
                        Container(width: 1, height: 32, color: AppTheme.borderSubtle),
                        _buildStatItem("Redemptions", "14 Used", AppTheme.textPrimary),
                        Container(width: 1, height: 32, color: AppTheme.borderSubtle),
                        _buildStatItem("Valid Until", "Dec 2026", AppTheme.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Analytics / Savings Dark Plate (Directly from Screenshot 3 Analytics Tile)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkAnchor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Savings Breakdown",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.north_east_rounded, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        // Left Donut Ring Simulation
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.pastelPeriwinkle, width: 9),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "70%",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  "Dining",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white60,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Metrics
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDonutLegend(AppTheme.pastelPeriwinkle, "Dining Savings", "NPR 19,800"),
                              const SizedBox(height: 8),
                              _buildDonutLegend(AppTheme.pastelMint, "Wellness & Spa", "NPR 6,250"),
                              const SizedBox(height: 8),
                              _buildDonutLegend(AppTheme.pastelCanary, "Retail & Tech", "NPR 2,400"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Membership & Pass Settings
              _buildSectionHeader('Membership & Pass'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppTheme.softCardShadow,
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.card_membership_rounded,
                      title: 'Annual All-Access Pass',
                      subtitle: 'Active • 248 Days Remaining',
                      badge: 'ACTIVE',
                      badgeColor: AppTheme.pastelMint,
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.borderSubtle),
                    _buildSettingsTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Family Sharing Pool',
                      subtitle: '2 of 3 Sub-Accounts Linked',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Preferences & Security
              _buildSectionHeader('Preferences & Security'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppTheme.softCardShadow,
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Push Notifications',
                      subtitle: 'New offers, savings alerts & expiration',
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.borderSubtle),
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Merchant PIN Security',
                      subtitle: 'Hardware-verified dual redemption validation',
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.borderSubtle),
                    _buildSettingsTile(
                      icon: Icons.system_update_rounded,
                      title: 'Check for Updates',
                      subtitle: 'OfferNepal v1.0.10+10',
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
                                backgroundColor: AppTheme.savingsGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 6. Log Out Button (Screenshot 3 Crisp Black Action Plate)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.errorRed,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonutLegend(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: valueColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppTheme.darkPill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
        onTap: onTap,
      ),
    );
  }
}
