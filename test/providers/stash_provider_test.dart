import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_stash_app/providers/stash_provider.dart';
import 'package:my_stash_app/services/storage_service.dart';
import 'package:my_stash_app/models/stash.dart';

// Generate mocks
@GenerateMocks([StorageService])
import 'stash_provider_test.mocks.dart';

void main() {
  group('StashProvider Tests', () {
    late StashProvider stashProvider;
    late MockStorageService mockStorageService;
    late List<Stash> testStashes;

    setUp(() {
      mockStorageService = MockStorageService();
      stashProvider = StashProvider();
      
      // Create test data
      testStashes = [
        Stash(
          id: 'stash-1',
          name: 'Emergency Fund',
          targetAmount: 1000.0,
          currentAmount: 250.0,
          category: 'Emergency Fund',
          startDate: DateTime(2024, 1, 1),
          contributions: [
            Contribution(
              id: 'contribution-1',
              amount: 250.0,
              date: DateTime(2024, 1, 15),
            ),
          ],
        ),
        Stash(
          id: 'stash-2',
          name: 'Vacation Fund',
          targetAmount: 2000.0,
          currentAmount: 500.0,
          category: 'Vacation',
          startDate: DateTime(2024, 1, 10),
          contributions: [
            Contribution(
              id: 'contribution-2',
              amount: 500.0,
              date: DateTime(2024, 1, 20),
            ),
          ],
        ),
        Stash(
          id: 'stash-3',
          name: 'Completed Goal',
          targetAmount: 500.0,
          currentAmount: 500.0,
          category: 'Other',
          startDate: DateTime(2024, 1, 5),
          contributions: [
            Contribution(
              id: 'contribution-3',
              amount: 500.0,
              date: DateTime(2024, 1, 25),
            ),
          ],
        ),
      ];
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(stashProvider.stashes, isEmpty);
        expect(stashProvider.isLoading, false);
        expect(stashProvider.errorMessage, isNull);
        expect(stashProvider.hasStashes, false);
        expect(stashProvider.totalSaved, 0.0);
        expect(stashProvider.totalTarget, 0.0);
        expect(stashProvider.overallProgress, 0.0);
        expect(stashProvider.completedStashes, 0);
      });
    });

    group('Statistics Calculations', () {
      test('should calculate total saved correctly', () {
        stashProvider.setStashes(testStashes);
        expect(stashProvider.totalSaved, 1250.0); // 250 + 500 + 500
      });

      test('should calculate total target correctly', () {
        stashProvider.setStashes(testStashes);
        expect(stashProvider.totalTarget, 3500.0); // 1000 + 2000 + 500
      });

      test('should calculate overall progress correctly', () {
        stashProvider.setStashes(testStashes);
        expect(stashProvider.overallProgress, closeTo(35.71, 0.01)); // 1250/3500 * 100
      });

      test('should count completed stashes correctly', () {
        stashProvider.setStashes(testStashes);
        expect(stashProvider.completedStashes, 1); // Only stash-3 is completed
      });

      test('should handle empty stashes list', () {
        stashProvider.setStashes([]);
        expect(stashProvider.totalSaved, 0.0);
        expect(stashProvider.totalTarget, 0.0);
        expect(stashProvider.overallProgress, 0.0);
        expect(stashProvider.completedStashes, 0);
      });

      test('should handle division by zero in progress calculation', () {
        final zeroTargetStashes = [
          Stash(
            id: 'zero-target',
            name: 'Zero Target',
            targetAmount: 0.0,
            currentAmount: 100.0,
            category: 'Other',
            startDate: DateTime.now(),
          ),
        ];
        
        stashProvider.setStashes(zeroTargetStashes);
        expect(stashProvider.overallProgress, 0.0);
      });
    });

    group('Stash Management', () {
      test('should add new stash correctly', () async {
        final newStash = Stash(
          id: 'new-stash',
          name: 'New Stash',
          targetAmount: 1500.0,
          currentAmount: 0.0,
          category: 'Car',
          startDate: DateTime(2024, 2, 1),
        );

        stashProvider.addStash(newStash);

        expect(stashProvider.stashes.length, 1);
        expect(stashProvider.stashes.first.id, 'new-stash');
        expect(stashProvider.stashes.first.name, 'New Stash');
        expect(stashProvider.hasStashes, true);
      });

      test('should update existing stash correctly', () {
        stashProvider.setStashes(testStashes);
        final originalStash = testStashes.first;
        
        final updatedStash = Stash(
          id: originalStash.id,
          name: 'Updated Emergency Fund',
          targetAmount: originalStash.targetAmount,
          currentAmount: originalStash.currentAmount,
          category: originalStash.category,
          startDate: originalStash.startDate,
          contributions: originalStash.contributions,
        );

        stashProvider.updateStash(updatedStash);

        final foundStash = stashProvider.stashes.firstWhere(
          (s) => s.id == originalStash.id,
        );
        expect(foundStash.name, 'Updated Emergency Fund');
      });

      test('should find stash by ID correctly', () {
        stashProvider.setStashes(testStashes);
        
        final foundStash = stashProvider.getStashById('stash-2');
        expect(foundStash, isNotNull);
        expect(foundStash!.name, 'Vacation Fund');

        final notFoundStash = stashProvider.getStashById('non-existent');
        expect(notFoundStash, isNull);
      });
    });

    group('Contribution Management', () {
      test('should add contribution to stash correctly', () {
        stashProvider.setStashes(testStashes);
        final stashId = 'stash-1';
        final originalAmount = testStashes.first.currentAmount;
        final contributionAmount = 100.0;

        stashProvider.addContribution(stashId, contributionAmount);

        final updatedStash = stashProvider.getStashById(stashId);
        expect(updatedStash!.currentAmount, originalAmount + contributionAmount);
        expect(updatedStash.contributions.length, 2); // Original + new contribution
        
        // Check that the new contribution has correct properties
        final newContribution = updatedStash.contributions.last;
        expect(newContribution.amount, contributionAmount);
        expect(newContribution.id, isNotNull);
        expect(newContribution.date.day, DateTime.now().day);
      });

      test('should handle contribution to non-existent stash', () {
        stashProvider.setStashes(testStashes);
        
        // This should not throw an error but also should not modify anything
        stashProvider.addContribution('non-existent-stash', 100.0);
        
        // Verify that existing stashes are unchanged
        expect(stashProvider.stashes.length, testStashes.length);
        expect(stashProvider.totalSaved, 1250.0);
      });

      test('should handle zero contribution amount', () {
        stashProvider.setStashes(testStashes);
        final stashId = 'stash-1';
        final originalAmount = testStashes.first.currentAmount;
        final originalContributionsCount = testStashes.first.contributions.length;

        stashProvider.addContribution(stashId, 0.0);

        final updatedStash = stashProvider.getStashById(stashId);
        expect(updatedStash!.currentAmount, originalAmount);
        expect(updatedStash.contributions.length, originalContributionsCount + 1);
      });

      test('should handle negative contribution amount', () {
        stashProvider.setStashes(testStashes);
        final stashId = 'stash-1';
        final originalAmount = testStashes.first.currentAmount;

        stashProvider.addContribution(stashId, -50.0);

        final updatedStash = stashProvider.getStashById(stashId);
        expect(updatedStash!.currentAmount, originalAmount - 50.0);
        expect(updatedStash.contributions.length, 2);
      });
    });

    group('Loading and Error States', () {
      test('should manage loading state correctly', () {
        expect(stashProvider.isLoading, false);
        
        // Simulate loading
        stashProvider.setLoadingState(true);
        expect(stashProvider.isLoading, true);
        
        stashProvider.setLoadingState(false);
        expect(stashProvider.isLoading, false);
      });

      test('should manage error state correctly', () {
        expect(stashProvider.errorMessage, isNull);
        
        const errorMessage = 'Test error message';
        stashProvider.setError(errorMessage);
        expect(stashProvider.errorMessage, errorMessage);
        
        stashProvider.clearError();
        expect(stashProvider.errorMessage, isNull);
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle very large contribution amounts', () {
        stashProvider.setStashes(testStashes);
        final stashId = 'stash-1';
        final largeAmount = 999999999.99;

        stashProvider.addContribution(stashId, largeAmount);

        final updatedStash = stashProvider.getStashById(stashId);
        expect(updatedStash!.currentAmount, 250.0 + largeAmount);
      });

      test('should handle decimal contribution amounts', () {
        stashProvider.setStashes(testStashes);
        final stashId = 'stash-1';
        final decimalAmount = 123.45;

        stashProvider.addContribution(stashId, decimalAmount);

        final updatedStash = stashProvider.getStashById(stashId);
        expect(updatedStash!.currentAmount, 250.0 + decimalAmount);
      });

      test('should maintain data integrity after multiple operations', () {
        stashProvider.setStashes(testStashes);
        
        // Add multiple contributions
        stashProvider.addContribution('stash-1', 100.0);
        stashProvider.addContribution('stash-1', 50.0);
        stashProvider.addContribution('stash-2', 200.0);
        
        // Verify totals are still correct
        expect(stashProvider.totalSaved, 1600.0); // 1250 + 100 + 50 + 200
        expect(stashProvider.totalTarget, 3500.0); // Should remain unchanged
        
        // Verify individual stash states
        final stash1 = stashProvider.getStashById('stash-1')!;
        expect(stash1.currentAmount, 400.0); // 250 + 100 + 50
        expect(stash1.contributions.length, 3); // Original + 2 new
        
        final stash2 = stashProvider.getStashById('stash-2')!;
        expect(stash2.currentAmount, 700.0); // 500 + 200
        expect(stash2.contributions.length, 2); // Original + 1 new
      });
    });

    group('Data Consistency', () {
      test('should maintain sorted order after operations', () {
        // Test that stashes maintain a consistent order
        stashProvider.setStashes(testStashes);
        final originalOrder = stashProvider.stashes.map((s) => s.id).toList();
        
        // Add contributions to various stashes
        stashProvider.addContribution('stash-2', 100.0);
        stashProvider.addContribution('stash-1', 50.0);
        
        final newOrder = stashProvider.stashes.map((s) => s.id).toList();
        expect(newOrder, equals(originalOrder));
      });

      test('should notify listeners on state changes', () {
        var notificationCount = 0;
        stashProvider.addListener(() {
          notificationCount++;
        });

        stashProvider.setStashes(testStashes);
        expect(notificationCount, 1);

        stashProvider.addContribution('stash-1', 100.0);
        expect(notificationCount, 2);

        stashProvider.setError('Test error');
        expect(notificationCount, 3);

        stashProvider.clearError();
        expect(notificationCount, 4);
      });
    });
  });
} 