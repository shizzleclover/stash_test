import 'package:flutter_test/flutter_test.dart';
import 'package:my_stash_app/models/stash.dart';

void main() {
  group('Stash Model Tests', () {
    late Stash testStash;
    late Contribution testContribution;

    setUp(() {
      testContribution = Contribution(
        id: 'contribution-1',
        amount: 100.0,
        date: DateTime(2024, 1, 15),
      );

      testStash = Stash(
        id: 'stash-1',
        name: 'Test Stash',
        targetAmount: 1000.0,
        currentAmount: 250.0,
        category: 'Emergency Fund',
        startDate: DateTime(2024, 1, 1),
        contributions: [testContribution],
      );
    });

    test('should create a valid Stash instance', () {
      expect(testStash.id, 'stash-1');
      expect(testStash.name, 'Test Stash');
      expect(testStash.targetAmount, 1000.0);
      expect(testStash.currentAmount, 250.0);
      expect(testStash.category, 'Emergency Fund');
      expect(testStash.startDate, DateTime(2024, 1, 1));
      expect(testStash.contributions.length, 1);
    });

    test('should calculate progress percentage correctly', () {
      expect(testStash.progressPercentage, 25.0);
      
      // Test with 0 target amount (edge case)
      final zeroTargetStash = Stash(
        id: 'test',
        name: 'Test',
        targetAmount: 0.0,
        currentAmount: 100.0,
        category: 'Other',
        startDate: DateTime.now(),
      );
      expect(zeroTargetStash.progressPercentage, 0.0);
    });

    test('should determine completion status correctly', () {
      expect(testStash.isCompleted, false);
      
      final completedStash = Stash(
        id: 'completed',
        name: 'Completed Stash',
        targetAmount: 500.0,
        currentAmount: 500.0,
        category: 'Vacation',
        startDate: DateTime(2024, 1, 1),
      );
      expect(completedStash.isCompleted, true);
      
      final overCompletedStash = Stash(
        id: 'over-completed',
        name: 'Over Completed Stash',
        targetAmount: 500.0,
        currentAmount: 600.0,
        category: 'Vacation',
        startDate: DateTime(2024, 1, 1),
      );
      expect(overCompletedStash.isCompleted, true);
    });

    test('should calculate remaining amount correctly', () {
      expect(testStash.remainingAmount, 750.0);
      
      final completedStash = Stash(
        id: 'completed',
        name: 'Completed Stash',
        targetAmount: 500.0,
        currentAmount: 600.0,
        category: 'Vacation',
        startDate: DateTime(2024, 1, 1),
      );
      expect(completedStash.remainingAmount, 0.0);
    });

    test('should add contribution correctly', () {
      expect(testStash.contributions.length, 1);
      expect(testStash.currentAmount, 250.0);
      
      final newContribution = Contribution(
        id: 'contribution-2',
        amount: 50.0,
        date: DateTime(2024, 1, 20),
      );
      
      testStash.contributions.add(newContribution);
      testStash.currentAmount += newContribution.amount;
      
      expect(testStash.contributions.length, 2);
      expect(testStash.currentAmount, 300.0);
      expect(testStash.progressPercentage, 30.0);
    });

    test('should handle edge cases for progress calculation', () {
      // Test with negative current amount
      final negativeStash = Stash(
        id: 'negative',
        name: 'Negative Stash',
        targetAmount: 1000.0,
        currentAmount: -100.0,
        category: 'Other',
        startDate: DateTime.now(),
      );
      expect(negativeStash.progressPercentage, 0.0);
      
      // Test with very large numbers
      final largeStash = Stash(
        id: 'large',
        name: 'Large Stash',
        targetAmount: 1000000.0,
        currentAmount: 250000.0,
        category: 'Investment',
        startDate: DateTime.now(),
      );
      expect(largeStash.progressPercentage, 25.0);
    });
  });

  group('Contribution Model Tests', () {
    test('should create a valid Contribution instance', () {
      final contribution = Contribution(
        id: 'test-contribution',
        amount: 150.0,
        date: DateTime(2024, 1, 10),
      );

      expect(contribution.id, 'test-contribution');
      expect(contribution.amount, 150.0);
      expect(contribution.date, DateTime(2024, 1, 10));
    });

    test('should handle different amount types', () {
      final intContribution = Contribution(
        id: 'int-contribution',
        amount: 100,
        date: DateTime.now(),
      );
      expect(intContribution.amount, 100.0);

      final decimalContribution = Contribution(
        id: 'decimal-contribution',
        amount: 99.99,
        date: DateTime.now(),
      );
      expect(decimalContribution.amount, 99.99);
    });
  });
} 