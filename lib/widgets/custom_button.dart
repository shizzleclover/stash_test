import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
      _rippleController.forward();
      
      // Reset ripple after completion
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _rippleController.reset();
        }
      });
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
    }
  }

  Color get _backgroundColor {
    if (widget.isSecondary) {
      return Colors.transparent;
    }
    return widget.onPressed != null && !widget.isLoading
        ? AppConstants.primaryColor
        : AppConstants.primaryColor.withOpacity(0.5);
  }

  Color get _textColor {
    if (widget.isSecondary) {
      return AppConstants.primaryColor;
    }
    return Colors.white;
  }

  BorderSide? get _borderSide {
    if (widget.isSecondary) {
      return BorderSide(
        color: AppConstants.primaryColor,
        width: 2,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: AppConstants.animationMedium,
              width: widget.width,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: _borderSide != null ? Border.all(
                  color: _borderSide!.color,
                  width: _borderSide!.width,
                ) : null,
                boxShadow: !widget.isSecondary && widget.onPressed != null && !widget.isLoading
                    ? [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(_isPressed ? 0.4 : 0.2),
                          blurRadius: _isPressed ? 20 : 12,
                          offset: Offset(0, _isPressed ? 8 : 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple effect
                    if (!widget.isSecondary)
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                              ),
                              child: CustomPaint(
                                painter: RipplePainter(
                                  animation: _rippleAnimation,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Button content
                    AnimatedSwitcher(
                      duration: AppConstants.animationMedium,
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: _textColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.text,
                                  style: GoogleFonts.inter(
                                    color: _textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  RipplePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value > 0) {
      final paint = Paint()
        ..color = color.withOpacity((1 - animation.value) * 0.3)
        ..style = PaintingStyle.fill;

      final center = Offset(size.width / 2, size.height / 2);
      final radius = size.width * animation.value;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
} 