import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/stash_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CreateStashScreen extends StatefulWidget {
  const CreateStashScreen({super.key});

  @override
  State<CreateStashScreen> createState() => _CreateStashScreenState();
}

class _CreateStashScreenState extends State<CreateStashScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _initialAmountController = TextEditingController();

  String _selectedCategory = AppConstants.stashCategories.first;
  DateTime _selectedDate = DateTime.now();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _initialAmountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleCreateStash() async {
    if (!_formKey.currentState!.validate()) return;

    final stashProvider = context.read<StashProvider>();
    
    await stashProvider.createStash(
      name: _nameController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text),
      category: _selectedCategory,
      startDate: _selectedDate,
      initialAmount: _initialAmountController.text.isEmpty 
          ? 0 
          : double.parse(_initialAmountController.text),
    );

    if (mounted) {
      if (stashProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stashProvider.errorMessage!),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stash created successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
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

  String? _validateInitialAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount < 0) {
      return 'Please enter a valid amount';
    }
    
    final targetAmount = double.tryParse(_targetAmountController.text);
    if (targetAmount != null && amount > targetAmount) {
      return 'Initial amount cannot exceed target';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Create New Stash'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.textPrimary,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.savings,
                              size: 48,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            const Text(
                              'Create Your Stash',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'Set your savings goal and start building your future',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingXLarge),

                      // Stash Name
                      CustomTextField(
                        label: 'Stash Name',
                        hint: 'e.g., Emergency Fund, Vacation, New Car',
                        controller: _nameController,
                        prefixIcon: Icons.label_outline,
                        validator: _validateRequired,
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Target Amount
                      CustomTextField(
                        label: 'Target Amount',
                        hint: '0.00',
                        controller: _targetAmountController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: _validateAmount,
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Initial Amount (Optional)
                      CustomTextField(
                        label: 'Initial Amount (Optional)',
                        hint: '0.00',
                        controller: _initialAmountController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.monetization_on_outlined,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: _validateInitialAmount,
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Category Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppConstants.textSecondary.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppConstants.textSecondary,
                                ),
                                items: AppConstants.stashCategories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Row(
                                      children: [
                                        Icon(
                                          AppConstants.categoryIcons[category] ?? Icons.savings,
                                          color: AppConstants.categoryColors[category] ?? AppConstants.primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(category),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Start Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDate,
                            child: Container(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppConstants.textSecondary.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: AppConstants.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppFormatters.formatDate(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppConstants.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingXLarge),

                      // Create Button
                      Consumer<StashProvider>(
                        builder: (context, stashProvider, child) {
                          return CustomButton(
                            text: 'Create Stash',
                            onPressed: stashProvider.isLoading ? null : _handleCreateStash,
                            isLoading: stashProvider.isLoading,
                            icon: Icons.add,
                          );
                        },
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Cancel Button
                      CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 