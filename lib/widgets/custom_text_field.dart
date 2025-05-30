import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
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
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
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
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _errorController;
  late Animation<double> _borderAnimation;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _errorShakeAnimation;

  late FocusNode _focusNode;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _setupAnimations() {
    _focusController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    ));

    _labelAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: AppConstants.textSecondary.withOpacity(0.3),
      end: AppConstants.primaryColor,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    ));

    _errorShakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.elasticIn,
    ));
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller?.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
      
      if (_hasError) {
        _errorController.forward().then((_) {
          _errorController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_focusController, _errorController]),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              AnimatedBuilder(
                animation: _labelAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _labelAnimation.value,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.label!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _hasError 
                            ? AppConstants.errorColor 
                            : _focusNode.hasFocus 
                                ? AppConstants.primaryColor 
                                : AppConstants.textSecondary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
            
            AnimatedBuilder(
              animation: _errorShakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _hasError ? (_errorShakeAnimation.value * 10 * 
                        (1 - _errorShakeAnimation.value)) : 0,
                    0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      boxShadow: _focusNode.hasFocus ? [
                        BoxShadow(
                          color: (_hasError ? AppConstants.errorColor : AppConstants.primaryColor)
                              .withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      enabled: widget.enabled,
                      maxLines: widget.maxLines,
                      inputFormatters: widget.inputFormatters,
                      onChanged: widget.onChanged,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: GoogleFonts.inter(
                          color: AppConstants.textSecondary.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: widget.prefixIcon != null
                            ? AnimatedContainer(
                                duration: AppConstants.animationMedium,
                                child: Icon(
                                  widget.prefixIcon,
                                  color: _focusNode.hasFocus 
                                      ? AppConstants.primaryColor 
                                      : AppConstants.textSecondary.withOpacity(0.6),
                                ),
                              )
                            : null,
                        suffixIcon: widget.suffixIcon != null
                            ? IconButton(
                                onPressed: widget.onSuffixIconPressed,
                                icon: AnimatedContainer(
                                  duration: AppConstants.animationMedium,
                                  child: Icon(
                                    widget.suffixIcon,
                                    color: _focusNode.hasFocus 
                                        ? AppConstants.primaryColor 
                                        : AppConstants.textSecondary.withOpacity(0.6),
                                  ),
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: BorderSide(
                            color: _hasError 
                                ? AppConstants.errorColor 
                                : AppConstants.textSecondary.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: BorderSide(
                            color: _hasError 
                                ? AppConstants.errorColor 
                                : AppConstants.textSecondary.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: BorderSide(
                            color: _hasError 
                                ? AppConstants.errorColor 
                                : _borderColorAnimation.value ?? AppConstants.primaryColor,
                            width: _borderAnimation.value,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: BorderSide(
                            color: AppConstants.errorColor,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: BorderSide(
                            color: AppConstants.errorColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingMedium,
                        ),
                        filled: true,
                        fillColor: widget.enabled 
                            ? Colors.white 
                            : AppConstants.textSecondary.withOpacity(0.1),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            if (_hasError && _errorText != null) ...[
              const SizedBox(height: 6),
              AnimatedOpacity(
                duration: AppConstants.animationFast,
                opacity: _hasError ? 1.0 : 0.0,
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
} 