import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/stash_provider.dart';
import '../models/stash.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class StashDetailScreen extends StatefulWidget {
  final String stashId;

  const StashDetailScreen({
    super.key,
    required this.stashId,
  });

  @override
  State<StashDetailScreen> createState() => _StashDetailScreenState();
}

class _StashDetailScreenState extends State<StashDetailScreen>
    with TickerProviderStateMixin {
  final _contributionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _headerController;
  late AnimationController _progressController;
  late AnimationController _contributionAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _contributionSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    _progressController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    _contributionAnimationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _contributionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contributionAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _progressController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _contributionAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _contributionController.dispose();
    _headerController.dispose();
    _progressController.dispose();
    _contributionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleAddContribution() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_contributionController.text);
    final stashProvider = context.read<StashProvider>();

    await stashProvider.addContribution(widget.stashId, amount);

    if (mounted) {
      if (stashProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stashProvider.errorMessage!),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      } else {
        _contributionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution added successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        // Restart progress animation
        _progressController.reset();
        _progressController.forward();
      }
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    
    return null;
  }

  Color _getCategoryColor(String category) {
    return AppConstants.categoryColors[category] ?? AppConstants.primaryColor;
  }

  IconData _getCategoryIcon(String category) {
    return AppConstants.categoryIcons[category] ?? Icons.savings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<StashProvider>(
        builder: (context, stashProvider, child) {
          final stash = stashProvider.getStashById(widget.stashId);
          
          if (stash == null) {
            return const Center(
              child: Text('Stash not found'),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(stash),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProgressSection(stash),
                    _buildDetailsSection(stash),
                    _buildContributionSection(stash, stashProvider),
                    _buildContributionHistory(stash),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Stash stash) {
    final categoryColor = _getCategoryColor(stash.category);
    final categoryIcon = _getCategoryIcon(stash.category);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: categoryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _headerAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      categoryColor,
                      categoryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                categoryIcon,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stash.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    stash.category,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (stash.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Complete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSection(Stash stash) {
    final categoryColor = _getCategoryColor(stash.category);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(AppConstants.paddingLarge),
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Amount',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatCurrency(stash.currentAmount),
                        style: const TextStyle(
                          fontSize: 28,
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
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatCurrency(stash.targetAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      Text(
                        AppFormatters.formatPercentage(stash.progressPercentage),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value * (stash.progressPercentage / 100),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsSection(Stash stash) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildDetailRow('Created', AppFormatters.formatDate(stash.createdDate)),
          _buildDetailRow('Category', stash.category),
          _buildDetailRow('Remaining', AppFormatters.formatCurrency(stash.targetAmount - stash.currentAmount)),
          _buildDetailRow('Total Contributions', '${stash.contributions.length}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionSection(Stash stash, StashProvider stashProvider) {
    return AnimatedBuilder(
      animation: _contributionSlideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _contributionSlideAnimation,
          child: Container(
            margin: const EdgeInsets.all(AppConstants.paddingLarge),
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Contribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Amount',
                          hint: '0.00',
                          controller: _contributionController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: _validateAmount,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      CustomButton(
                        text: 'Add',
                        onPressed: stashProvider.isLoading ? null : _handleAddContribution,
                        isLoading: stashProvider.isLoading,
                        width: 80,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContributionHistory(Stash stash) {
    if (stash.contributions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Contributions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...stash.contributions.reversed.take(5).map((contribution) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppConstants.textSecondary.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.formatCurrency(contribution.amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      Text(
                        AppFormatters.getDaysAgo(contribution.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.add_circle_outline,
                    color: AppConstants.successColor,
                    size: 20,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
} 