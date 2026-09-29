import 'package:flutter/material.dart';

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
    _initFocusNode();
  }

  void _initFocusNode() {
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _effectiveFocusNode.dispose();
      } else {
        _effectiveFocusNode.removeListener(_handleFocusChange);
      }
      _initFocusNode();
    }
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
      _effectiveFocusNode.dispose();
    } else {
      _effectiveFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? const Color(0xFFEF4444)
        : (_isFocused ? primaryColor : Colors.white.withValues(alpha: 0.12));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: 58,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: hasError
            ? const Color(0xFFEF4444).withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: (_isFocused || hasError) ? 1.8 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: (hasError ? const Color(0xFFEF4444) : primaryColor)
                      .withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            style: const TextStyle(
              color: Colors.black,
              // backgroundColor: Color(0xFFDCE9FF),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            onSubmitted: (value) {
              if (widget.nextFocusNode != null) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              }
              if (widget.onFieldSubmitted != null) {
                widget.onFieldSubmitted!(value);
              }
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),fillColor: Color(0xffDCE9FF),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: hasError
                    ? const Color(0xFFF87171)
                    : (_isFocused
                        ? primaryColor
                        : Color(0xFF346EF6)),
                fontSize: 13,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  widget.prefixIcon,
                  color: hasError
                      ? const Color(0xFFF87171)
                      : (_isFocused
                          ? primaryColor
                          : Color(0xFF346EF6)),
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 24,
              ),
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            key: ValueKey<bool>(_obscureText),
                            color: hasError
                                ? const Color(0xFFF87171)
                                : Color(0xFF346EF6),
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : (hasError
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFF87171),
                            size: 20,
                          ),
                        )
                      : null),
            ),
          ),
        ),
      ),
    );
  }
}
