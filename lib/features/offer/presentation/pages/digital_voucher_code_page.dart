import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/features/home/presentation/widgets/tactile_wallet_deck.dart';

/// Full-Sheet Pastel Voucher Redemption View
/// Replicates Screenshot 1 (Right):
/// - Monochromatic full-screen pastel sheet matching the selected card color
/// - Minimalist brand header + category
/// - 180s live countdown pill
/// - Massive monospaced coupon code (readable across a counter)
/// - "Copy" pill button with clipboard haptic feedback
/// - "How to redeem?" guide & Merchant PIN trigger
class DigitalVoucherCodePage extends StatefulWidget {
  final WalletVoucherItem voucher;

  const DigitalVoucherCodePage({super.key, required this.voucher});

  @override
  State<DigitalVoucherCodePage> createState() => _DigitalVoucherCodePageState();
}

class _DigitalVoucherCodePageState extends State<DigitalVoucherCodePage> {
  int _secondsRemaining = 180;
  Timer? _timer;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.voucher.voucherCode));
    HapticFeedback.mediumImpact();
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Voucher code copied to clipboard!',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.darkPill,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final voucher = widget.voucher;
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppTheme.darkAnchor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar with back button
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
                    'Voucher Pass',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 48), // balance spacing
                ],
              ),
            ),

            const SizedBox(height: 10),

            // The Full Pastel Voucher Canvas Sheet
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: voucher.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Handle Notch
                    Center(
                      child: Container(
                        width: 42,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: AppTheme.darkAnchor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header: Icon, Category, Brand, Value
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(voucher.icon, color: AppTheme.darkAnchor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher.category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkAnchor.withValues(alpha: 0.65),
                                ),
                              ),
                              Text(
                                voucher.brandName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.darkAnchor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          voucher.discountValue,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.darkAnchor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // 180s Countdown Live Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.darkAnchor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.darkAnchor),
                          const SizedBox(width: 6),
                          Text(
                            "Digital Code • Expires in $minutes:$seconds",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkAnchor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Huge Monospaced Alphanumeric Code Display (1:1 with Screenshot 1)
                    Expanded(
                      child: Center(
                        child: Text(
                          _formatVoucherCode(voucher.voucherCode),
                          textAlign: TextAlign.left,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.darkAnchor,
                            letterSpacing: 2.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),

                    // Estimated Savings Confirmation
                    Center(
                      child: Text(
                        "Estimated Savings: NPR ${voucher.savingsNpr}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkAnchor.withValues(alpha: 0.75),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bottom Action Dock: Copy Button + "How to redeem?"
                    Row(
                      children: [
                        // Copy Pill
                        GestureDetector(
                          onTap: _copyToClipboard,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.darkPill,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.darkPill.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _copied ? "Copied!" : "Copy",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // How to redeem? Ghost Pill
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showHowToRedeemDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.darkAnchor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "How to redeem?",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppTheme.darkAnchor,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.darkAnchor, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVoucherCode(String code) {
    if (code.contains('\n')) return code;
    // Chunk code into 5-character blocks with hyphens like screenshot
    final clean = code.replaceAll('-', '');
    final chunks = <String>[];
    for (int i = 0; i < clean.length; i += 5) {
      chunks.add(clean.substring(i, (i + 5 < clean.length) ? i + 5 : clean.length));
    }
    return chunks.join('-\n');
  }

  void _showHowToRedeemDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(26),
        decoration: const BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "How to Redeem with Cashier",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _buildStep("1", "Present this digital code to your waiter or cashier before requesting the final bill."),
            _buildStep("2", "The cashier will enter the 6-character code into their terminal."),
            _buildStep("3", "The cashier enters their 4-digit venue PIN to validate and apply the BOGO deduction."),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppTheme.darkPill,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
