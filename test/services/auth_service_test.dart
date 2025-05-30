import 'package:flutter_test/flutter_test.dart';
import 'package:my_stash_app/services/auth_service.dart';
import 'package:my_stash_app/models/user.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('Email Validation', () {
      test('should return true for valid email formats', () {
        expect(authService.isValidEmail('test@example.com'), true);
        expect(authService.isValidEmail('user.name@domain.co.uk'), true);
        expect(authService.isValidEmail('user123@test-domain.com'), true);
        expect(authService.isValidEmail('a@b.co'), true);
      });

      test('should return false for invalid email formats', () {
        expect(authService.isValidEmail(''), false);
        expect(authService.isValidEmail('invalid-email'), false);
        expect(authService.isValidEmail('@domain.com'), false);
        expect(authService.isValidEmail('user@'), false);
        expect(authService.isValidEmail('user@domain'), false);
        expect(authService.isValidEmail('user.domain.com'), false);
        expect(authService.isValidEmail('user @domain.com'), false);
      });

      test('should handle edge cases for email validation', () {
        expect(authService.isValidEmail('a@b.c'), true);
        expect(authService.isValidEmail('very-long-email-address@very-long-domain-name.com'), true);
        expect(authService.isValidEmail('user+tag@domain.com'), true);
        expect(authService.isValidEmail('user.name+tag@domain.com'), true);
      });
    });

    group('Password Validation', () {
      test('should return true for valid passwords', () {
        expect(authService.isValidPassword('password'), true);
        expect(authService.isValidPassword('123456'), true);
        expect(authService.isValidPassword('complex!Password123'), true);
        expect(authService.isValidPassword('simple'), true);
      });

      test('should return false for invalid passwords', () {
        expect(authService.isValidPassword(''), false);
        expect(authService.isValidPassword('12345'), false);
        expect(authService.isValidPassword('short'), false);
        expect(authService.isValidPassword('a'), false);
      });

      test('should require minimum 6 characters', () {
        expect(authService.isValidPassword('12345'), false);
        expect(authService.isValidPassword('123456'), true);
        expect(authService.isValidPassword('abcdef'), true);
      });
    });

    group('Login Functionality', () {
      test('should return user for valid credentials', () async {
        final result = await authService.login('test@example.com', 'password123');
        
        expect(result, isA<User>());
        expect(result!.email, 'test@example.com');
        expect(result.name, 'Test User');
        expect(result.id, isNotNull);
      });

      test('should return null for invalid email format', () async {
        final result = await authService.login('invalid-email', 'password123');
        expect(result, isNull);
      });

      test('should return null for short password', () async {
        final result = await authService.login('test@example.com', '12345');
        expect(result, isNull);
      });

      test('should return null for empty credentials', () async {
        final result1 = await authService.login('', 'password123');
        expect(result1, isNull);
        
        final result2 = await authService.login('test@example.com', '');
        expect(result2, isNull);
        
        final result3 = await authService.login('', '');
        expect(result3, isNull);
      });

      test('should simulate async behavior', () async {
        final stopwatch = Stopwatch()..start();
        await authService.login('test@example.com', 'password123');
        stopwatch.stop();
        
        // Should take at least 500ms due to the delay in the service
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });

      test('should generate different user IDs for different sessions', () async {
        final user1 = await authService.login('test1@example.com', 'password123');
        final user2 = await authService.login('test2@example.com', 'password123');
        
        expect(user1!.id, isNot(equals(user2!.id)));
      });

      test('should extract name from email correctly', () async {
        final user1 = await authService.login('john.doe@example.com', 'password123');
        expect(user1!.name, 'John Doe');
        
        final user2 = await authService.login('jane_smith@company.com', 'password123');
        expect(user2!.name, 'Jane Smith');
        
        final user3 = await authService.login('single@domain.com', 'password123');
        expect(user3!.name, 'Single');
        
        final user4 = await authService.login('test.user.name@domain.com', 'password123');
        expect(user4!.name, 'Test User Name');
      });
    });

    group('Logout Functionality', () {
      test('should logout successfully', () async {
        final result = await authService.logout();
        expect(result, true);
      });

      test('should simulate async logout behavior', () async {
        final stopwatch = Stopwatch()..start();
        await authService.logout();
        stopwatch.stop();
        
        // Should take at least 200ms due to the delay in the service
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(200));
      });
    });

    group('Name Extraction', () {
      test('should extract and format names correctly', () async {
        // Test various email formats
        final testCases = [
          {'email': 'john.doe@example.com', 'expectedName': 'John Doe'},
          {'email': 'jane_smith@company.com', 'expectedName': 'Jane Smith'},
          {'email': 'mary-jane@domain.com', 'expectedName': 'Mary Jane'},
          {'email': 'bob@domain.com', 'expectedName': 'Bob'},
          {'email': 'a.b.c@domain.com', 'expectedName': 'A B C'},
        ];

        for (final testCase in testCases) {
          final user = await authService.login(
            testCase['email'] as String, 
            'password123'
          );
          expect(user!.name, testCase['expectedName'],
              reason: 'Failed for email: ${testCase['email']}');
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very long emails', () async {
        final longEmail = 'very.long.email.address.that.might.cause.issues@very-long-domain-name-that-should-still-work.com';
        final user = await authService.login(longEmail, 'password123');
        
        expect(user, isNotNull);
        expect(user!.email, longEmail);
      });

      test('should handle special characters in password', () async {
        final specialPassword = 'p@ssw0rd!#\$%^&*()';
        final user = await authService.login('test@example.com', specialPassword);
        
        expect(user, isNotNull);
      });

      test('should handle unicode characters', () async {
        final unicodePassword = 'pássw🔐rd123';
        if (unicodePassword.length >= 6) {
          final user = await authService.login('test@example.com', unicodePassword);
          expect(user, isNotNull);
        }
      });
    });
  });
} 