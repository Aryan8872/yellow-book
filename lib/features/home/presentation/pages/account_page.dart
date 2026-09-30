import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:entertainer/core/widgets/glass_container.dart';
import 'package:entertainer/features/auth/domain/entities/user.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_event.dart';
import 'package:entertainer/features/auth/presentation/bloc/auth_state.dart';
import 'package:entertainer/features/auth/presentation/pages/login_page.dart';

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
        backgroundColor: const Color(0xFFD3E4FE),
        body: Stack(
          children: [
            // Ambient soft background glows
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF346EF6).withValues(alpha: 0.15),
                ),
              ),
            ),

            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // App Bar Title
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 1. VIP Membership Glass Banner Card
                  GlassContainer(
                    borderRadius: 24,
                    blur: 18,
                    padding: const EdgeInsets.all(20),
                    color: Colors.white.withValues(alpha: 0.78),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 34,
                                backgroundColor: Color(0xFFEAF1FF),
                                child: Icon(Icons.person_rounded, size: 38, color: Color(0xFF0053DB)),
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
                                          user.fullName.isNotEmpty ? user.fullName : 'Valued VIP Member',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF0053DB), Color(0xFF346EF6)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "GOLD VIP",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                                      SizedBox(width: 4),
                                      Text(
                                        "Verified Membership",
                                        style: TextStyle(fontSize: 11.5, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFD3E4FE)),
                        const SizedBox(height: 14),

                        // Lifetime Savings Metric (Retention Psychology)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("Total Savings", "\$680.00", const Color(0xFF10B981)),
                            Container(width: 1, height: 32, color: const Color(0xFFD3E4FE)),
                            _buildStatItem("Redemptions", "14 Used", const Color(0xFF0053DB)),
                            Container(width: 1, height: 32, color: const Color(0xFFD3E4FE)),
                            _buildStatItem("Active Tier", "2026 Pass", const Color(0xFF818CF8)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Subscription Details Section
                  _buildSectionHeader('Subscription & Family Sharing'),
                  GlassContainer(
                    borderRadius: 20,
                    blur: 14,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    color: Colors.white.withValues(alpha: 0.72),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.card_membership_rounded,
                          title: 'Annual Pass (GCC & Nepal)',
                          subtitle: 'Active until Dec 31, 2026',
                          badge: 'ACTIVE',
                          badgeColor: const Color(0xFF10B981),
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFE2E8F0)),
                        _buildSettingsTile(
                          icon: Icons.people_outline_rounded,
                          title: 'Family Sharing Pool',
                          subtitle: '2 of 3 Sub-Accounts Linked',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Preferences & Security Section
                  _buildSectionHeader('Security & Preferences'),
                  GlassContainer(
                    borderRadius: 20,
                    blur: 14,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    color: Colors.white.withValues(alpha: 0.72),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Push Notifications',
                          subtitle: 'Alerts on trending offers & expiry',
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFE2E8F0)),
                        _buildSettingsTile(
                          icon: Icons.shield_outlined,
                          title: 'Security & Merchant PIN',
                          subtitle: '256-Bit TLS verified transactions',
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFE2E8F0)),
                        _buildSettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          subtitle: 'Update account credentials',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 4. Logout Action
                  GlassContainer(
                    borderRadius: 18,
                    blur: 12,
                    padding: EdgeInsets.zero,
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.2),
                    onTap: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out of Account',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // clearance for floating navbar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF346EF6).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF0053DB), size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.black87,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: (badgeColor ?? const Color(0xFF346EF6)).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor ?? const Color(0xFF346EF6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12.5, color: Colors.black54),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
    );
  }
}
