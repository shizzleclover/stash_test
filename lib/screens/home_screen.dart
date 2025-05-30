import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/stash_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/stash_card.dart';
import '../utils/page_transitions.dart';
import '../screens/create_stash_screen.dart';
import '../screens/stash_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    _listController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _loadData() async {
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StashProvider>().loadStashes();
      if (mounted) {
        _headerController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _listController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToCreateStash() {
    Navigator.of(context).push(
      CustomPageTransitions.slideUp(const CreateStashScreen()),
    );
  }

  void _navigateToStashDetail(String stashId) {
    Navigator.of(context).push(
      CustomPageTransitions.slideRight(StashDetailScreen(stashId: stashId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with user info and statistics
            _buildHeader(),
            
            // Stash list
            Expanded(
              child: _buildStashList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateStash,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerAnimation,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            Text(
                              authProvider.user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      onPressed: _handleLogout,
                      icon: Icon(
                        Icons.logout,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // Overview statistics
                Consumer<StashProvider>(
                  builder: (context, stashProvider, child) {
                    if (!stashProvider.hasStashes) {
                      return const SizedBox.shrink();
                    }
                    
                    return Container(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem(
                                'Total Saved',
                                AppFormatters.formatCurrency(stashProvider.totalSaved),
                                Icons.account_balance_wallet,
                              ),
                              _buildStatItem(
                                'Total Target',
                                AppFormatters.formatCurrency(stashProvider.totalTarget),
                                Icons.flag,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingMedium),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem(
                                'Progress',
                                AppFormatters.formatPercentage(stashProvider.overallProgress),
                                Icons.trending_up,
                              ),
                              _buildStatItem(
                                'Completed',
                                '${stashProvider.completedStashes}/${stashProvider.stashes.length}',
                                Icons.check_circle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStashList() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listAnimation,
          child: Consumer<StashProvider>(
            builder: (context, stashProvider, child) {
              if (stashProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (stashProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppConstants.errorColor,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        stashProvider.errorMessage!,
                        style: TextStyle(
                          color: AppConstants.textSecondary,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      CustomButton(
                        text: 'Retry',
                        onPressed: _loadData,
                        isSecondary: true,
                      ),
                    ],
                  ),
                );
              }

              if (!stashProvider.hasStashes) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        ),
                        child: Icon(
                          Icons.savings,
                          size: 80,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      const Text(
                        'No stashes yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Create your first stash to start saving!',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      CustomButton(
                        text: 'Create First Stash',
                        onPressed: _navigateToCreateStash,
                        icon: Icons.add,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stashProvider.stashes.length,
                itemBuilder: (context, index) {
                  final stash = stashProvider.stashes[index];
                  return StashCard(
                    stash: stash,
                    index: index,
                    onTap: () => _navigateToStashDetail(stash.id),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
} 