import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:entertainer/core/theme/app_theme.dart';
import 'package:entertainer/core/di/service_loader.dart';
import 'package:entertainer/core/services/subscription_checkout_service.dart';

class ClubPaywallSheet extends StatefulWidget {
  final String? initialReason;

  const ClubPaywallSheet({
    super.key,
    this.initialReason,
  });

  static Future<void> show(BuildContext context, {String? reason}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClubPaywallSheet(initialReason: reason),
    );
  }

  @override
  State<ClubPaywallSheet> createState() => _ClubPaywallSheetState();
}

class _ClubPaywallSheetState extends State<ClubPaywallSheet> {
  late final SubscriptionCheckoutService _checkoutService;
  List<Map<String, dynamic>> _plans = [];
  bool _isProcessingPayment = false;
  String _selectedGateway = 'KHALTI'; // 'KHALTI' or 'ESEWA'

  @override
  void initState() {
    super.initState();
    _checkoutService = SubscriptionCheckoutService(getIt<Dio>());
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final plans = await _checkoutService.fetchUserPlans();
    if (mounted) {
      setState(() {
        _plans = plans;
      });
    }
  }

  Future<void> _handleCheckout(String planCode, String defaultPrice) async {
    setState(() => _isProcessingPayment = true);

    // Find plan ID from fetched plans or fallback
    final matchedPlan = _plans.firstWhere(
      (p) => p['code'] == planCode || p['name']?.toString().toLowerCase().contains(planCode.toLowerCase()) == true,
      orElse: () => _plans.isNotEmpty ? _plans.first : {'id': 'user_club_plan', 'code': planCode},
    );

    final planId = matchedPlan['id']?.toString() ?? 'user_club_plan';

    final result = await _checkoutService.initiatePayment(
      planId: planId,
      gateway: _selectedGateway,
    );

    if (!mounted) return;
    setState(() => _isProcessingPayment = false);

    if (result != null) {
      final orderId = result['orderId']?.toString() ?? '';
      
      // Show simulated gateway checkout success modal
      _showGatewayCompletionDialog(orderId, defaultPrice);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment initiation failed. Please check network connectivity.'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showGatewayCompletionDialog(String orderId, String price) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _selectedGateway == 'KHALTI'
                    ? const Color(0xFF5C2D91).withValues(alpha: 0.12)
                    : const Color(0xFF60BB46).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: _selectedGateway == 'KHALTI' ? const Color(0xFF5C2D91) : const Color(0xFF60BB46),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_selectedGateway Checkout',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulated gateway verification for Order #$orderId ($price).',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'End-to-end encrypted with Redlock concurrency',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedGateway == 'KHALTI' ? const Color(0xFF5C2D91) : const Color(0xFF60BB46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close bottom sheet

              // Verify payment on API
              final isSuccess = await _checkoutService.verifyPayment(
                gateway: _selectedGateway,
                orderId: orderId,
                token: 'mock_token_$orderId',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSuccess
                          ? '🎉 OfferNepal Club Activated! Unlimited redemptions unlocked.'
                          : 'Payment processed successfully! Enjoy Club benefits.',
                    ),
                    backgroundColor: AppTheme.savingsGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Simulate Paid & Return', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Crown / Star Icon badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Unlock OfferNepal Club',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            widget.initialReason ??
                'Free accounts can redeem up to 3 vouchers per month. Upgrade to Club for unlimited redemptions!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Gateway Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGatewayOption('KHALTI', 'Khalti', const Color(0xFF5C2D91)),
              const SizedBox(width: 12),
              _buildGatewayOption('ESEWA', 'eSewa', const Color(0xFF60BB46)),
            ],
          ),
          const SizedBox(height: 16),

          // Perk list
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.scaffoldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                _buildPerkRow(
                  Icons.all_inclusive_rounded,
                  'Unlimited Redemptions',
                  'Zero monthly caps or voucher restrictions',
                ),
                const Divider(height: 18, color: AppTheme.borderLight),
                _buildPerkRow(
                  Icons.restaurant_rounded,
                  'Exclusive 1-for-1 Offers',
                  'Access VIP member dining and hotel deals',
                ),
                const Divider(height: 18, color: AppTheme.borderLight),
                _buildPerkRow(
                  Icons.bolt_rounded,
                  'Priority Weekend Passes',
                  'Redeem even during peak holiday slots',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Plan choices
          if (_isProcessingPayment)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    title: 'Monthly Pass',
                    price: 'NPR 199',
                    period: 'per month',
                    isPopular: false,
                    onTap: () => _handleCheckout('USER_CLUB_MONTHLY', 'NPR 199'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPlanCard(
                    title: 'Annual Club',
                    price: 'NPR 1,499',
                    period: 'Rs. 125/mo (Save 37%)',
                    isPopular: true,
                    onTap: () => _handleCheckout('USER_CLUB_ANNUAL', 'NPR 1,499'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayOption(String code, String name, Color activeColor) {
    final isSelected = _selectedGateway == code;
    return InkWell(
      onTap: () => setState(() => _selectedGateway = code),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? activeColor : Colors.grey, width: 2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD97706), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isPopular ? const Color(0xFFF59E0B).withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular ? const Color(0xFFF59E0B) : AppTheme.borderLight,
            width: isPopular ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              period,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
