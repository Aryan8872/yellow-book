import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:entertainer/core/theme/app_theme.dart';

/// Clean, flat text field matching the app's clean card design system.
/// No tacky neon shadows, no excessive 32px curves, no AI gradients.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.onFieldSubmitted,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _effectiveFocusNode.removeListener(_handleFocusChange);
      _effectiveFocusNode.dispose();
    } else {
      _effectiveFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            widget.labelText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Flat Input Container
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? AppTheme.errorRed
                    : (_isFocused ? AppTheme.crimsonPrimary : AppTheme.borderLight),
                width: (_isFocused || hasError) ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  widget.prefixIcon,
                  size: 19,
                  color: hasError
                      ? AppTheme.errorRed
                      : (_isFocused ? AppTheme.crimsonPrimary : AppTheme.textMuted),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _effectiveFocusNode,
                    obscureText: widget.isPassword && _obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textMuted,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) {
                      if (widget.nextFocusNode != null) {
                        FocusScope.of(context).requestFocus(widget.nextFocusNode);
                      }
                      if (widget.onFieldSubmitted != null) {
                        widget.onFieldSubmitted!(value);
                      }
                    },
                  ),
                ),
                if (widget.isPassword)
                  IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),

          if (hasError) ...[
            const SizedBox(height: 4),
            Text(
              widget.errorText!,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.errorRed,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
