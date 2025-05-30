import 'package:flutter/material.dart';
import '../models/stash.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class StashCard extends StatefulWidget {
  final Stash stash;
  final VoidCallback onTap;
  final bool showShadow;

  const StashCard({
    super.key,
    required this.stash,
    required this.onTap,
    this.showShadow = true,
  });

  @override
  State<StashCard> createState() => _StashCardState();
}

class _StashCardState extends State<StashCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.stash.progressPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.forward();
  }

  void _onTapCancel() {
    _animationController.forward();
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
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppConstants.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                boxShadow: widget.showShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and completion status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _categoryColor.withOpacity(0.1),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
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
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 