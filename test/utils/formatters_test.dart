import 'package:flutter_test/flutter_test.dart';
import 'package:my_stash_app/utils/formatters.dart';

void main() {
  group('AppFormatters Tests', () {
    group('Currency Formatting', () {
      test('should format positive amounts correctly', () {
        expect(AppFormatters.formatCurrency(0), '\$0.00');
        expect(AppFormatters.formatCurrency(1), '\$1.00');
        expect(AppFormatters.formatCurrency(10), '\$10.00');
        expect(AppFormatters.formatCurrency(100), '\$100.00');
        expect(AppFormatters.formatCurrency(1000), '\$1,000.00');
        expect(AppFormatters.formatCurrency(10000), '\$10,000.00');
        expect(AppFormatters.formatCurrency(100000), '\$100,000.00');
        expect(AppFormatters.formatCurrency(1000000), '\$1,000,000.00');
      });

      test('should format decimal amounts correctly', () {
        expect(AppFormatters.formatCurrency(0.01), '\$0.01');
        expect(AppFormatters.formatCurrency(0.99), '\$0.99');
        expect(AppFormatters.formatCurrency(1.50), '\$1.50');
        expect(AppFormatters.formatCurrency(99.99), '\$99.99');
        expect(AppFormatters.formatCurrency(123.45), '\$123.45');
        expect(AppFormatters.formatCurrency(1234.56), '\$1,234.56');
      });

      test('should format negative amounts correctly', () {
        expect(AppFormatters.formatCurrency(-1), '-\$1.00');
        expect(AppFormatters.formatCurrency(-10.50), '-\$10.50');
        expect(AppFormatters.formatCurrency(-1000), '-\$1,000.00');
        expect(AppFormatters.formatCurrency(-1234.56), '-\$1,234.56');
      });

      test('should handle very large amounts', () {
        expect(AppFormatters.formatCurrency(999999999.99), '\$999,999,999.99');
        expect(AppFormatters.formatCurrency(1000000000), '\$1,000,000,000.00');
      });

      test('should handle very small amounts', () {
        expect(AppFormatters.formatCurrency(0.001), '\$0.00');
        expect(AppFormatters.formatCurrency(0.005), '\$0.01');
        expect(AppFormatters.formatCurrency(0.004), '\$0.00');
      });

      test('should handle edge cases', () {
        expect(AppFormatters.formatCurrency(double.infinity), '\$∞');
        expect(AppFormatters.formatCurrency(double.negativeInfinity), '-\$∞');
        expect(AppFormatters.formatCurrency(double.nan), '\$NaN');
      });
    });

    group('Percentage Formatting', () {
      test('should format whole number percentages correctly', () {
        expect(AppFormatters.formatPercentage(0), '0%');
        expect(AppFormatters.formatPercentage(1), '1%');
        expect(AppFormatters.formatPercentage(25), '25%');
        expect(AppFormatters.formatPercentage(50), '50%');
        expect(AppFormatters.formatPercentage(75), '75%');
        expect(AppFormatters.formatPercentage(100), '100%');
      });

      test('should format decimal percentages correctly', () {
        expect(AppFormatters.formatPercentage(0.1), '0.1%');
        expect(AppFormatters.formatPercentage(0.5), '0.5%');
        expect(AppFormatters.formatPercentage(12.5), '12.5%');
        expect(AppFormatters.formatPercentage(33.33), '33.33%');
        expect(AppFormatters.formatPercentage(66.67), '66.67%');
        expect(AppFormatters.formatPercentage(99.9), '99.9%');
      });

      test('should handle percentages over 100%', () {
        expect(AppFormatters.formatPercentage(101), '101%');
        expect(AppFormatters.formatPercentage(150), '150%');
        expect(AppFormatters.formatPercentage(200), '200%');
        expect(AppFormatters.formatPercentage(999.99), '999.99%');
      });

      test('should handle negative percentages', () {
        expect(AppFormatters.formatPercentage(-1), '-1%');
        expect(AppFormatters.formatPercentage(-10.5), '-10.5%');
        expect(AppFormatters.formatPercentage(-100), '-100%');
      });

      test('should round to appropriate decimal places', () {
        expect(AppFormatters.formatPercentage(33.333333), '33.33%');
        expect(AppFormatters.formatPercentage(66.666666), '66.67%');
        expect(AppFormatters.formatPercentage(12.345678), '12.35%');
        expect(AppFormatters.formatPercentage(0.123456), '0.12%');
      });

      test('should handle edge cases', () {
        expect(AppFormatters.formatPercentage(double.infinity), '∞%');
        expect(AppFormatters.formatPercentage(double.negativeInfinity), '-∞%');
        expect(AppFormatters.formatPercentage(double.nan), 'NaN%');
      });
    });

    group('Date Formatting', () {
      test('should format dates correctly', () {
        final date1 = DateTime(2024, 1, 1);
        expect(AppFormatters.formatDate(date1), 'Jan 1, 2024');

        final date2 = DateTime(2024, 12, 31);
        expect(AppFormatters.formatDate(date2), 'Dec 31, 2024');

        final date3 = DateTime(2024, 6, 15);
        expect(AppFormatters.formatDate(date3), 'Jun 15, 2024');
      });

      test('should format all months correctly', () {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        for (int i = 0; i < 12; i++) {
          final date = DateTime(2024, i + 1, 1);
          final formatted = AppFormatters.formatDate(date);
          expect(formatted, contains(months[i]));
        }
      });

      test('should handle different years', () {
        final date1 = DateTime(2020, 1, 1);
        expect(AppFormatters.formatDate(date1), 'Jan 1, 2020');

        final date2 = DateTime(2030, 1, 1);
        expect(AppFormatters.formatDate(date2), 'Jan 1, 2030');

        final date3 = DateTime(1999, 12, 31);
        expect(AppFormatters.formatDate(date3), 'Dec 31, 1999');
      });

      test('should handle different days of month', () {
        final date1 = DateTime(2024, 1, 1);
        expect(AppFormatters.formatDate(date1), 'Jan 1, 2024');

        final date2 = DateTime(2024, 1, 10);
        expect(AppFormatters.formatDate(date2), 'Jan 10, 2024');

        final date3 = DateTime(2024, 1, 31);
        expect(AppFormatters.formatDate(date3), 'Jan 31, 2024');
      });
    });

    group('Short Date Formatting', () {
      test('should format short dates correctly', () {
        final date1 = DateTime(2024, 1, 1);
        expect(AppFormatters.formatDateShort(date1), 'Jan 1');

        final date2 = DateTime(2024, 12, 31);
        expect(AppFormatters.formatDateShort(date2), 'Dec 31');

        final date3 = DateTime(2024, 6, 15);
        expect(AppFormatters.formatDateShort(date3), 'Jun 15');
      });

      test('should not include year in short format', () {
        final date = DateTime(2024, 5, 20);
        final formatted = AppFormatters.formatDateShort(date);
        expect(formatted, 'May 20');
        expect(formatted, isNot(contains('2024')));
      });
    });

    group('Integration Tests', () {
      test('should maintain consistency between formatters', () {
        // Test that formatters work well together
        final amount = 1234.56;
        final percentage = 75.5;
        final date = DateTime(2024, 3, 15);

        final formattedAmount = AppFormatters.formatCurrency(amount);
        final formattedPercentage = AppFormatters.formatPercentage(percentage);
        final formattedDate = AppFormatters.formatDate(date);

        expect(formattedAmount, '\$1,234.56');
        expect(formattedPercentage, '75.5%');
        expect(formattedDate, 'Mar 15, 2024');
      });

      test('should handle multiple operations without interference', () {
        // Test that calling one formatter doesn't affect others
        AppFormatters.formatCurrency(1000);
        expect(AppFormatters.formatPercentage(50), '50%');
        
        AppFormatters.formatPercentage(75);
        expect(AppFormatters.formatCurrency(2000), '\$2,000.00');
        
        AppFormatters.formatDate(DateTime(2024, 1, 1));
        expect(AppFormatters.formatCurrency(500), '\$500.00');
        expect(AppFormatters.formatPercentage(25), '25%');
      });
    });

    group('Locale Considerations', () {
      test('should use consistent formatting regardless of system locale', () {
        // These tests ensure our formatters work consistently
        // regardless of the device's locale settings
        expect(AppFormatters.formatCurrency(1000), '\$1,000.00');
        expect(AppFormatters.formatPercentage(50.5), '50.5%');
        
        final date = DateTime(2024, 1, 15);
        expect(AppFormatters.formatDate(date), 'Jan 15, 2024');
      });
    });

    group('Performance Tests', () {
      test('should handle rapid successive calls efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        // Test 1000 rapid calls
        for (int i = 0; i < 1000; i++) {
          AppFormatters.formatCurrency(i.toDouble());
          AppFormatters.formatPercentage(i.toDouble());
          AppFormatters.formatDate(DateTime(2024, 1, 1).add(Duration(days: i)));
        }
        
        stopwatch.stop();
        
        // Should complete within reasonable time (adjust threshold as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
} 