import 'package:flutter/material.dart';
import '../models/stash.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class StashCard extends StatefulWidget {
  final Stash stash;
  final VoidCallback onTap;
  final bool showShadow;
  final int index;

  const StashCard({
    super.key,
    required this.stash,
    required this.onTap,
    this.showShadow = true,
    this.index = 0,
  });

  @override
  State<StashCard> createState() => _StashCardState();
}

class _StashCardState extends State<StashCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.stash.progressPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Stagger the animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _animationController.forward();
        
        // Start shimmer effect if stash is completed
        if (widget.stash.isCompleted) {
          _shimmerController.repeat();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isHovered = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isHovered = false;
    });
  }

  Color get _categoryColor {
    return AppConstants.categoryColors[widget.stash.category] ??
        AppConstants.primaryColor;
  }

  IconData get _categoryIcon {
    return AppConstants.categoryIcons[widget.stash.category] ??
        Icons.savings;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: AppConstants.animationFast,
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                transform: Matrix4.identity()
                  ..scale(_isHovered ? 0.98 : 1.0),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  boxShadow: widget.showShadow
                      ? [
                          BoxShadow(
                            color: _isHovered 
                                ? _categoryColor.withOpacity(0.15)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: _isHovered ? 20 : 12,
                            offset: Offset(0, _isHovered ? 8 : 4),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                  child: Stack(
                    children: [
                      // Shimmer effect for completed stashes
                      if (widget.stash.isCompleted)
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(_shimmerAnimation.value * 400, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon and completion status
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: AppConstants.animationMedium,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _categoryColor.withOpacity(_isHovered ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _categoryIcon,
                                    color: _categoryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.stash.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.stash.category,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppConstants.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.stash.isCompleted)
                                  AnimatedContainer(
                                    duration: AppConstants.animationMedium,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants.successColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppConstants.successColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppConstants.successColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Complete',
                                          style: TextStyle(
                                            color: AppConstants.successColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            // Amount saved vs target
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saved',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppFormatters.formatCurrency(widget.stash.currentAmount),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Target',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppFormatters.formatCurrency(widget.stash.targetAmount),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppConstants.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingLarge),

                            // Progress bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      AppFormatters.formatPercentage(widget.stash.progressPercentage),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AnimatedBuilder(
                                    animation: _progressAnimation,
                                    builder: (context, child) {
                                      return LinearProgressIndicator(
                                        value: _progressAnimation.value,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
                                        minHeight: 8,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 