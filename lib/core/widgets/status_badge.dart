import 'package:flutter/material.dart';

/// Canonical status badge — the single source of truth for redemption-status
/// copy and colors (Phase 30 UI-SPEC §Color). Replaces per-page divergent
/// badge hue math; consumers sweep to this widget across Phase 30 plans.
///
/// E2 color contract: only the canonical state union
/// (INIT | PENDING_SYNC | REDEEMED | REJECTED | EXPIRED) is keyed here.
/// Legacy non-canonical values fall through to the unknown branch
/// (title-cased raw copy on muted grey) — no banned status literals
/// (CANCELLED / PENDING / COMPLETED) are introduced by this widget.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    this.status = '',
    this.icon,
  });

  final String status;

  /// Optional status icon rendered inside a 44px circle on 10% alpha tint.
  final Widget? icon;

  static const Color _amber = Color(0xFFE5A93C);
  static const Color _savingsGreen = Color(0xFF10B981);
  static const Color _errorRed = Color(0xFFEF4444);
  static const Color _textMuted = Color(0xFF6B7280);

  /// Resolves [status] to its canonical (copy, foreground, background) tuple.
  static ({String label, Color foreground, Color background}) resolve(
    String status,
  ) {
    final key = status.trim().toUpperCase();
    switch (key) {
      case 'INIT':
      case 'PENDING_SYNC':
        return (
          label: 'Active',
          foreground: _amber,
          background: _amber.withValues(alpha: 0.12),
        );
      case 'REDEEMED':
        return (
          label: 'Redeemed',
          foreground: _savingsGreen,
          background: _savingsGreen.withValues(alpha: 0.12),
        );
      case 'EXPIRED':
        return (
          label: 'Expired',
          foreground: _errorRed,
          background: _errorRed.withValues(alpha: 0.12),
        );
      case 'REJECTED':
        return (
          label: 'Cancelled',
          foreground: _textMuted,
          background: _textMuted.withValues(alpha: 0.12),
        );
      default:
        final raw = status.trim();
        final label = raw.isEmpty
            ? 'Cancelled'
            : raw[0].toUpperCase() + raw.substring(1).toLowerCase();
        return (
          label: label,
          foreground: _textMuted,
          background: _textMuted.withValues(alpha: 0.12),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = resolve(status);

    final Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (icon == null) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: style.foreground.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(width: 8),
        badge,
      ],
    );
  }
}
