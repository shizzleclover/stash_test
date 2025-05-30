import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(
                  color: _isFocused
                      ? AppConstants.primaryColor
                      : AppConstants.textSecondary.withOpacity(0.3),
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                onChanged: widget.onChanged,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                inputFormatters: widget.inputFormatters,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GoogleFonts.inter(
                    color: AppConstants.textSecondary.withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? AppConstants.primaryColor
                              : AppConstants.textSecondary,
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: _isFocused
                                ? AppConstants.primaryColor
                                : AppConstants.textSecondary,
                          ),
                          onPressed: widget.onSuffixIconPressed,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingMedium,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 