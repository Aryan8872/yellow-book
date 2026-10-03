import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/slide_to_confirm_button.dart';
import 'package:entertainer/features/home/presentation/widgets/tactile_wallet_deck.dart';
import 'digital_voucher_code_page.dart';

/// Interactive Cashout / Dual-Key Redeem Stepper Page
/// Replicates Screenshot 2 (Right):
/// - Pitch-black header plate with big editable denomination: `–` `200€` `+`
/// - "Available Earnings / Savings" sub-pill
/// - Selected Venue plate with dropdown selector
/// - 2-Column Denomination Pills Grid (`25, 50, 75, 100, 150, 200...`)
/// - "Slide to Cashout / Redeem >>>" slider knob
class NeoCashoutRedeemPage extends StatefulWidget {
  final WalletVoucherItem? initialVoucher;

  const NeoCashoutRedeemPage({super.key, this.initialVoucher});

  @override
  State<NeoCashoutRedeemPage> createState() => _NeoCashoutRedeemPageState();
}

class _NeoCashoutRedeemPageState extends State<NeoCashoutRedeemPage> {
  final List<int> _denominations = [25, 50, 75, 100, 150, 200, 250, 500];
  late int _selectedAmount;
  late WalletVoucherItem _voucher;

  @override
  void initState() {
    super.initState();
    _voucher = widget.initialVoucher ??
        const WalletVoucherItem(
          id: 'v_ps',
          category: 'Gaming',
          brandName: 'Playstation Store',
          discountValue: 'NPR 500',
          cardColor: AppTheme.pastelPeriwinkle,
          icon: Icons.sports_esports_rounded,
          voucherCode: 'HQCRJ-D3WB8-G2HA5-GH8LY-MQ6Q7',
          description: 'Buy 1 Game Pass Get 1 Free',
          terms: 'Valid on digital downloads',
          savingsNpr: 500,
        );
    _selectedAmount = 200;
  }

  void _adjustAmount(int delta) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedAmount = (_selectedAmount + delta).clamp(25, 5000);
    });
  }

  void _onSlideConfirmed() {
    // Navigate to Digital Voucher Pass
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DigitalVoucherCodePage(voucher: _voucher),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkAnchor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Nav Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Redeem Pass',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Big Stepper: [ – ]  200€  [ + ]
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus Button
                GestureDetector(
                  onTap: () => _adjustAmount(-25),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 24),

                // Amount
                Text(
                  "$_selectedAmount €",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(width: 24),

                // Plus Button
                GestureDetector(
                  onTap: () => _adjustAmount(25),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Sub Pill: "2.358 € Available Earnings"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "NPR 28,450 Available Savings",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // White Card Plate
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
                ),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selected Brand Header with Dropdown Indicator
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _voucher.cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_voucher.icon, color: AppTheme.darkAnchor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _voucher.brandName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Text(
                                _voucher.category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.unfold_more_rounded, color: AppTheme.textSecondary, size: 20),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Denomination Grid (2 columns: 25, 50, 75, 100...)
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _denominations.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                        itemBuilder: (context, index) {
                          final amount = _denominations[index];
                          final isSelected = _selectedAmount == amount;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedAmount = amount);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.darkAnchor : AppTheme.surfaceSubtle,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? AppTheme.darkAnchor : AppTheme.borderSubtle,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "$amount",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tactile Slide to Confirm
                    SlideToConfirmButton(
                      text: "Slide to Cashout / Redeem",
                      onConfirmed: _onSlideConfirmed,
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
