import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/presentation/pages/claimed_reward_detail_page.dart';
import 'package:entertainer/features/offer/presentation/pages/scratch_win_page.dart';

class RewardHistoryItem {
  final String id;
  final String title;
  final String merchantName;
  final String branchLocation;
  final String categoryTag;
  final String code;
  final String pin;
  final String valueText;
  final String expiryText;
  final String sourceTier;
  final String status; // 'active', 'redeemed', 'wallet'
  final String imageUrl;

  const RewardHistoryItem({
    required this.id,
    required this.title,
    required this.merchantName,
    required this.branchLocation,
    required this.categoryTag,
    required this.code,
    required this.pin,
    required this.valueText,
    required this.expiryText,
    required this.sourceTier,
    required this.status,
    required this.imageUrl,
  });
}

/// Clean, flat, production-grade Reward History Page.
/// Replicates the structural layout from mobile_app_ui_html/reward_history_page_ui.html
/// without any AI gradient artifacts or tacky visuals.
class RewardHistoryPage extends StatefulWidget {
  const RewardHistoryPage({super.key});

  @override
  State<RewardHistoryPage> createState() => _RewardHistoryPageState();
}

class _RewardHistoryPageState extends State<RewardHistoryPage> {
  String _selectedFilter = 'all';

  final List<RewardHistoryItem> _rewards = const [
    RewardHistoryItem(
      id: 'rwd-01',
      title: 'Flat Rs. 500 Off on Fine Dining',
      merchantName: 'Trisara Garden & Lounge',
      branchLocation: 'Lazimpat, Kathmandu',
      categoryTag: 'DINING VOUCHER',
      code: 'TRI-SCR-500X',
      pin: '849201',
      valueText: 'Rs. 500',
      expiryText: 'Valid till 15 Nov 2026 (6 days left)',
      sourceTier: 'Won from Scratch & Win • Gold Tier',
      status: 'active',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&auto=format&fit=crop&q=60',
    ),
    RewardHistoryItem(
      id: 'rwd-02',
      title: 'Rs. 250 Khalti / eSewa Instant Balance',
      merchantName: 'OfferNepal Wallet Balance',
      branchLocation: 'Digital Wallet Credit',
      categoryTag: 'WALLET CASHBACK',
      code: 'KHLT-250-CBK',
      pin: '419082',
      valueText: 'Rs. 250',
      expiryText: 'Transferred to Wallet on 28 Oct',
      sourceTier: 'Won from Scratch & Win • Daily Streak',
      status: 'wallet',
      imageUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=500&auto=format&fit=crop&q=60',
    ),
    RewardHistoryItem(
      id: 'rwd-03',
      title: 'Buy 1 Get 1 Free Bakery & Pastry Pass',
      merchantName: 'Himalayan Java Coffee',
      branchLocation: 'Mandala St, Thamel',
      categoryTag: 'CAFE PERK',
      code: 'JAVA-B1G1-NOV',
      pin: '109384',
      valueText: 'B1G1 Free',
      expiryText: 'Valid till 20 Nov 2026',
      sourceTier: 'Won from Scratch & Win • Elite Tier',
      status: 'active',
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500&auto=format&fit=crop&q=60',
    ),
    RewardHistoryItem(
      id: 'rwd-04',
      title: 'Flat Rs. 1,000 Off Full Body Ayurvedic Spa',
      merchantName: 'Tranquility Spa Nepal',
      branchLocation: 'Kupondole, Lalitpur',
      categoryTag: 'WELLNESS VOUCHER',
      code: 'TRQ-SPA-1000',
      pin: '772910',
      valueText: 'Rs. 1,000',
      expiryText: 'Redeemed on 24 Oct 2026',
      sourceTier: 'Won from Scratch & Win • Weekly Draw',
      status: 'redeemed',
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500&auto=format&fit=crop&q=60',
    ),
  ];

  List<RewardHistoryItem> get _filteredRewards {
    if (_selectedFilter == 'all') return _rewards;
    if (_selectedFilter == 'active') {
      return _rewards.where((r) => r.status == 'active').toList();
    }
    if (_selectedFilter == 'wallet') {
      return _rewards.where((r) => r.status == 'wallet').toList();
    }
    if (_selectedFilter == 'redeemed') {
      return _rewards.where((r) => r.status == 'redeemed').toList();
    }
    return _rewards;
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher code $code copied!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reward History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppTheme.textMuted),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All scratch rewards are valid for merchant redemption or wallet balance.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // 1. Stats Summary Card (Clean Flat Design matching sample HTML)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL CLAIMED VALUE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. 4,850',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScratchWinPage()),
                        );
                      },
                      icon: const Icon(Icons.celebration_rounded, size: 16),
                      label: Text(
                        'Play Daily',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldJade.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_rounded, size: 18, color: AppTheme.emeraldJade),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2 Available',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Active Rewards',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.amberFlame.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.stars_rounded, size: 18, color: AppTheme.amberFlame),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '14 Won',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Lifetime Scratch',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Filter Tabs Rail
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'All (${_rewards.length})'),
                _buildFilterChip('active', 'Active (2)'),
                _buildFilterChip('wallet', 'Wallet Credit (1)'),
                _buildFilterChip('redeemed', 'Redeemed (1)'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Reward Items List
          ..._filteredRewards.map((reward) => _buildRewardCard(reward)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceDark : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.surfaceDark : AppTheme.borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard(RewardHistoryItem reward) {
    final isActive = reward.status == 'active';
    final isWallet = reward.status == 'wallet';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClaimedRewardDetailPage(reward: reward),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reward.categoryTag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.crimsonPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.emeraldJade.withValues(alpha: 0.12)
                        : (isWallet ? AppTheme.amberFlame.withValues(alpha: 0.12) : AppTheme.surfaceSubtle),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.emeraldJade
                              : (isWallet ? AppTheme.amberFlame : AppTheme.textMuted),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isActive ? 'Active' : (isWallet ? 'Credited' : 'Redeemed'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isActive
                              ? AppTheme.emeraldJade
                              : (isWallet ? AppTheme.amberFlame : AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              reward.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              reward.sourceTier,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            // Code & Copy Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reward.code,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copyCode(reward.code),
                    child: Row(
                      children: [
                        const Icon(Icons.copy_rounded, size: 14, color: AppTheme.crimsonPrimary),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.crimsonPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Expiry & Details Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      reward.expiryText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.textPrimary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

