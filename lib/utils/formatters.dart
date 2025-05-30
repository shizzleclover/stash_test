import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortDateFormatter = DateFormat('dd/MM/yyyy');

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
} 