import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// WebView page for Khalti / eSewa payment gateway checkout.
/// Intercepts the return_url redirect to extract payment status and pop with result.
class GatewayCheckoutPage extends StatefulWidget {
  /// The initial checkout URL from Khalti or eSewa
  final String checkoutUrl;

  /// The return/success URL prefix to detect payment completion.
  /// e.g. 'https://offernepal.com/payment/success' or 'offernepal://payment'
  final String returnUrlPrefix;

  /// Label shown in the AppBar (e.g. 'Khalti Checkout' or 'eSewa Payment')
  final String gatewayName;

  const GatewayCheckoutPage({
    super.key,
    required this.checkoutUrl,
    required this.returnUrlPrefix,
    this.gatewayName = 'Secure Checkout',
  });

  @override
  State<GatewayCheckoutPage> createState() => _GatewayCheckoutPageState();
}

class _GatewayCheckoutPageState extends State<GatewayCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (e) => setState(() {
            _isLoading = false;
            _errorMessage = e.description;
          }),
          onNavigationRequest: (request) {
            final url = request.url;
            debugPrint('[Gateway] Navigating to: $url');

            // Detect success redirect
            if (url.startsWith(widget.returnUrlPrefix)) {
              Navigator.pop(context, _parsePaymentResult(url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  /// Parses query params from the redirect URL into a result map.
  Map<String, String> _parsePaymentResult(String url) {
    try {
      final uri = Uri.parse(url);
      return Map<String, String>.from(uri.queryParameters);
    } catch (_) {
      return {'url': url};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context, null), // cancelled
          tooltip: 'Cancel payment',
        ),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, size: 14, color: AppTheme.savingsGreen),
            const SizedBox(width: 6),
            Text(
              widget.gatewayName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _errorMessage != null
          ? _ErrorView(message: _errorMessage!, onRetry: () {
              setState(() => _errorMessage = null);
              _controller.loadRequest(Uri.parse(widget.checkoutUrl));
            })
          : WebViewWidget(controller: _controller),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'Payment page failed to load',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPill,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
