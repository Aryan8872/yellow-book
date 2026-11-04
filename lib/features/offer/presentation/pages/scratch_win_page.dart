import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/offer/presentation/widgets/scratch_card_widget.dart';
import 'package:entertainer/features/offer/presentation/pages/reward_history_page.dart';

class ScratchWinPage extends StatefulWidget {
  /// Optional handler for when the page is embedded inside a tab shell.
  /// When null the page behaves like a normal pushed route.
  final VoidCallback? onBack;

  const ScratchWinPage({super.key, this.onBack});

  @override
  State<ScratchWinPage> createState() => _ScratchWinPageState();
}

class _ScratchWinPageState extends State<ScratchWinPage> {
  bool _isScratched = false;
  bool _isClaimed = false;
  bool _codeCopied = false;

  final String _couponCode = 'SCRATCH-WIN-NEPAL-2026';

  final List<({String user, String prize, String time})> _recentWinners = const [
    (user: 'Suman Shrestha', prize: 'Rs. 500 Dining Voucher', time: '2m ago'),
    (user: 'Pooja Thapa', prize: 'Rs. 250 Wallet Credit', time: '6m ago'),
    (user: 'Bikash Gurung', prize: 'Buy 1 Get 1 Himalayan Java', time: '11m ago'),
    (user: 'Anjali Sharma', prize: 'Rs. 1,000 Spa Retreat Pass', time: '18m ago'),
  ];

  void _scratchCard() {
    if (!_isScratched) {
      setState(() {
        _isScratched = true;
      });
    }
  }

  void _claimReward() {
    setState(() {
      _isClaimed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Congratulations! Rs. 250 credited to your OfferNepal Wallet!'),
        backgroundColor: AppTheme.emeraldJade,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyCoupon() {
    setState(() {
      _codeCopied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon code copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _codeCopied = false);
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }

    // Never pop the root route: doing so leaves Android with a black window.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: _handleBack,
        ),
        title: Text(
          'Scratch & Win',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.textPrimary),
            tooltip: 'Reward History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RewardHistoryPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, size: 16, color: AppTheme.amberFlame),
                  const SizedBox(width: 4),
                  Text(
                    'Perks Zone',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Plan Tier Access Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF131B2E).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.amberFlame.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'ELITE BENEFIT UNLOCKED',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.amberFlame,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.crimsonPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.loyalty_rounded, size: 18, color: AppTheme.crimsonPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Daily Fortune Scratch',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Exclusive perk for Elite Tier members. Keep your daily streak alive!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.emeraldJade,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isScratched ? '0 / 1 Card Available' : '1 / 1 Card Available',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.emeraldJade,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Resets at Midnight',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Interactive Finger-Gesture Scratch Physics Card
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 380,
                child: ScratchCardWidget(
                  thresholdPercent: 0.40,
                  onThresholdReached: () {
                    setState(() {
                      _isScratched = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldJade.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.redeem_rounded,
                                size: 28,
                                color: AppTheme.emeraldJade,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CONGRATULATIONS!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rs. 250 Credit!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.crimsonPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'OfferNepal Dining Voucher Valid Valley-wide',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // Partner Bonus Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_cafe_rounded,
                                size: 20,
                                color: AppTheme.amberFlame,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+20% Extra Off at Himalayan Java',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Partner bonus applied automatically',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Coupon Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSubtle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _couponCode,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: _copyCoupon,
                                child: Text(
                                  _codeCopied ? 'COPIED!' : 'COPY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.crimsonPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Claim Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isClaimed
                                ? AppTheme.emeraldJade
                                : AppTheme.crimsonPrimary,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isClaimed ? null : _claimReward,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isClaimed
                                    ? Icons.check_circle_rounded
                                    : Icons.account_balance_wallet_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isClaimed
                                    ? 'Claimed to Wallet'
                                    : 'Claim to Wallet & Redeem',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
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
            ),

            const SizedBox(height: 28),

            // 3. Today's Recent Winners Ticker
            Row(
              children: [
                const Icon(Icons.verified_rounded, size: 18, color: AppTheme.emeraldJade),
                const SizedBox(width: 6),
                Text(
                  'Live Winners Across Nepal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentWinners.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final win = _recentWinners[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldLightBg,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  win.user[0],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.emeraldJade,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  win.user,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  win.prize,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          win.time,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
