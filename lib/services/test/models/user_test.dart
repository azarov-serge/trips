import 'package:flutter_test/flutter_test.dart';
import 'package:trips/services/services.dart';

void main() {
  group('AuthUser', () {
    const id = 'mock-id';
    const email = 'mock-email';

    test('uses value equality', () {
      expect(
        AuthUser(email: email, id: id),
        AuthUser(email: email, id: id),
      );
    });

    test('isEmpty returns true for empty AuthUser', () {
      expect(AuthUser.empty.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty AuthUser', () {
      final authUser = AuthUser(
        email: email,
        id: id,
      );
      expect(authUser.isEmpty, isFalse);
    });

    test('isNotEmpty returns false for empty AuthUser', () {
      expect(AuthUser.empty.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty AuthUser', () {
      final authUser = AuthUser(
        email: email,
        id: id,
      );
      expect(authUser.isNotEmpty, isTrue);
    });
  });
}
