import 'package:flutter/material.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/widgets/slide_to_action_slider.dart';

/// Modern PIN keypad & dual redemption verification modal.
/// Modeled after high-trust fintech checkout sheets with tactile number buttons
/// and physical "Slide to Redeem" confirmation.
class MerchantPinRedemptionModal extends StatefulWidget {
  final String offerTitle;
  final String merchantName;
  final String estimatedSavings;
  final VoidCallback onRedemptionSuccess;

  const MerchantPinRedemptionModal({
    super.key,
    required this.offerTitle,
    required this.merchantName,
    required this.estimatedSavings,
    required this.onRedemptionSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required String offerTitle,
    required String merchantName,
    required String estimatedSavings,
    required VoidCallback onRedemptionSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MerchantPinRedemptionModal(
        offerTitle: offerTitle,
        merchantName: merchantName,
        estimatedSavings: estimatedSavings,
        onRedemptionSuccess: onRedemptionSuccess,
      ),
    );
  }

  @override
  State<MerchantPinRedemptionModal> createState() => _MerchantPinRedemptionModalState();
}

class _MerchantPinRedemptionModalState extends State<MerchantPinRedemptionModal> {
  String _pin = '';
  bool _isValidating = false;
  String? _errorMessage;

  void _onKeyPress(String key) {
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
        _errorMessage = null;
      });
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _confirmRedemption() async {
    if (_pin.length < 4) {
      setState(() {
        _errorMessage = "Please ask merchant to enter full 4-digit PIN";
      });
      return;
    }

    setState(() {
      _isValidating = true;
    });

    // Simulate atomic verification
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      Navigator.of(context).pop();
      widget.onRedemptionSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle notch
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.merchantName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Merchant Verification",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  widget.estimatedSavings,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Instruction Callout
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.borderSubtle, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.darkPill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pin_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Hand phone to merchant staff to enter their 4-digit branch PIN",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PIN Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isFilled ? 18 : 14,
                height: isFilled ? 18 : 14,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isFilled ? AppTheme.darkPill : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFilled ? AppTheme.darkPill : AppTheme.borderLight,
                    width: 2,
                  ),
                ),
              );
            }),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.errorRed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Tactile Number Keypad (Grid 3x4)
          SizedBox(
            width: 280,
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                const SizedBox(height: 12),
                _buildKeypadRow(['4', '5', '6']),
                const SizedBox(height: 12),
                _buildKeypadRow(['7', '8', '9']),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 72, height: 60),
                    _buildKey('0'),
                    _buildBackspaceKey(),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Slide-to-Redeem Confirmation
          if (_isValidating)
            const SizedBox(
              height: 64,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.darkPill,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else
            SlideToActionSlider(
              label: "Slide to Confirm",
              onActionCompleted: _confirmRedemption,
            ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String value) {
    return Container(
      width: 72,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _onKeyPress(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Container(
      width: 72,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _onBackspace,
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
