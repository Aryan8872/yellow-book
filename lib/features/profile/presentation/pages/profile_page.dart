import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/offer/data/datasource/redemption_remote_datasource.dart';
import 'package:entertainer/features/offer/data/model/redemption_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<RedemptionModel> _redemptions = [];
  bool _loadingRedemptions = true;

  @override
  void initState() {
    super.initState();
    _loadRedemptions();
  }

  Future<void> _loadRedemptions() async {
    try {
      final ds = getIt<RedemptionRemoteDatasourceImpl>();
      final results = await ds.getMyRedemptions();
      if (mounted) setState(() { _redemptions = results; _loadingRedemptions = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingRedemptions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        if (user == null) {
          return const _UnauthenticatedPrompt();
        }

        return Scaffold(
          backgroundColor: AppTheme.canvasBg,
          body: CustomScrollView(
            slivers: [
              // ── Profile Header SliverAppBar ────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Avatar
                            Container(
                              width: 68, height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22, fontWeight: FontWeight.w900,
                                color: Colors.white, letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              user.email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                    onPressed: () => _confirmLogout(context),
                    tooltip: 'Sign out',
                  ),
                ],
              ),

              // ── Stats Row ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Redemptions',
                        value: '${_redemptions.length}',
                        icon: Icons.confirmation_num_outlined,
                        color: const Color(0xFF667EEA),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Total Saved',
                        value: _redemptions.isEmpty ? 'NPR 0' :
                          'NPR ${_redemptions.fold<int>(0, (sum, r) => sum)}',
                        icon: Icons.savings_outlined,
                        color: AppTheme.savingsGreen,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Section Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    children: [
                      Text(
                        'Redemption History',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18, fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary, letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      if (_redemptions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.darkPill.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_redemptions.length} total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Redemption List ────────────────────────────────────────
              if (_loadingRedemptions)
                const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.darkPill),
                  )),
                )
              else if (_redemptions.isEmpty)
                SliverToBoxAdapter(child: _EmptyHistory())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, index == _redemptions.length - 1 ? 100 : 12),
                      child: _RedemptionCard(redemption: _redemptions[index]),
                    ),
                    childCount: _redemptions.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign out?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        content: Text('You will need to sign in again to access your account.',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD93025), foregroundColor: Colors.white, elevation: 0),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary,
                  )),
                  Text(label, style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedemptionCard extends StatelessWidget {
  final RedemptionModel redemption;
  const _RedemptionCard({required this.redemption});

  Color get _statusColor {
    switch (redemption.status.toUpperCase()) {
      case 'REDEEMED': return AppTheme.savingsGreen;
      case 'INIT': return const Color(0xFFE5A93C);
      case 'EXPIRED': return const Color(0xFFD93025);
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              redemption.status.toUpperCase() == 'REDEEMED'
                  ? Icons.check_circle_rounded
                  : Icons.confirmation_num_outlined,
              color: _statusColor, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.offerTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                if (redemption.merchantName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    redemption.merchantName!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDate(redemption.redeemedAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              redemption.status.toUpperCase() == 'REDEEMED' ? 'Used' :
                redemption.status[0].toUpperCase() + redemption.status.substring(1).toLowerCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.confirmation_num_outlined, size: 36, color: Color(0xFF667EEA)),
            ),
            const SizedBox(height: 16),
            Text('No redemptions yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              )),
            const SizedBox(height: 6),
            Text('Start redeeming offers to see your history here',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
              )),
          ],
        ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, size: 44, color: Color(0xFF667EEA)),
            ),
            const SizedBox(height: 20),
            Text('Sign in to view your profile',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              )),
            const SizedBox(height: 8),
            Text('See your redemption history and saved offers',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPill, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('Sign In', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
