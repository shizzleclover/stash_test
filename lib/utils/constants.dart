import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Stash Categories
  static const List<String> stashCategories = [
    'Emergency Fund',
    'Vacation',
    'Home',
    'Car',
    'Education',
    'Health',
    'Investment',
    'Wedding',
    'Electronics',
    'Other',
  ];

  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'Emergency Fund': Icons.security,
    'Vacation': Icons.flight_takeoff,
    'Home': Icons.home,
    'Car': Icons.directions_car,
    'Education': Icons.school,
    'Health': Icons.medical_services,
    'Investment': Icons.trending_up,
    'Wedding': Icons.favorite,
    'Electronics': Icons.devices,
    'Other': Icons.savings,
  };

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Emergency Fund': Color(0xFFFF5722),
    'Vacation': Color(0xFF2196F3),
    'Home': Color(0xFF4CAF50),
    'Car': Color(0xFF9C27B0),
    'Education': Color(0xFFFFC107),
    'Health': Color(0xFFE91E63),
    'Investment': Color(0xFF00BCD4),
    'Wedding': Color(0xFFFF9800),
    'Electronics': Color(0xFF607D8B),
    'Other': Color(0xFF795548),
  };
}

enum LoadingState {
  idle,
  loading,
  success,
  error,
}

enum AuthState {
  unknown,
  authenticated,
  unauthenticated,
} 