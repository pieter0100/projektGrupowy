import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AuthService authService;

  setUpAll(() async {
    await Firebase.initializeApp();
    authService = AuthService();
  });

  testWidgets('register, sign in, and sign out (integration)', (WidgetTester tester) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'testuser$timestamp@example.com';
    final password = 'TestPassword123!';
    final username = 'TestUser$timestamp';

    // Register
    final user = await authService.register(email, password, username);
    expect(user, isNotNull);

    // Sign out
    await authService.signOut();
    expect(authService.onAuthStateChanged, emits(null));

    // Sign in
    final signInUser = await authService.signIn(email, password);
    expect(signInUser, isNotNull);

    // Send password reset (should not throw)
    await authService.sendPasswordReset(email);
  });

  testWidgets('register with existing email should fail', (WidgetTester tester) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'duplicateuser$timestamp@example.com';
    final password = 'TestPassword123!';
    final username1 = 'TestUser1_$timestamp';
    final username2 = 'TestUser2_$timestamp';

    // Register first time
    final user1 = await authService.register(email, password, username1);
    expect(user1, isNotNull);

    // Register second time with same email but different username
    try {
      await authService.register(email, password, username2);
      fail('Expected an exception for duplicate email');
    } catch (e) {
      expect(e.toString().toLowerCase(), contains('already in use'));
    }
  });

  testWidgets('sign in with wrong password should fail', (WidgetTester tester) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'wrongpwuser$timestamp@example.com';
    final password = 'TestPassword123!';
    final wrongPassword = 'WrongPassword1!';
    final username = 'TestUser$timestamp';

    // Register
    final user = await authService.register(email, password, username);
    expect(user, isNotNull);

    // Try to sign in with wrong password
    try {
      await authService.signIn(email, wrongPassword);
      fail('Expected an exception for wrong password');
    } catch (e) {
      expect(
        e.toString().toLowerCase(),
        anyOf(contains('incorrect'), contains('credential')),
      );
    }
  });

  testWidgets('sign in with non-existent email should fail', (WidgetTester tester) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'nonexistent$timestamp@example.com';
    final password = 'TestPassword123!';

    // Try to sign in with email that was never registered
    try {
      await authService.signIn(email, password);
      fail('Expected an exception for user not found');
    } catch (e) {
      expect(
        e.toString().toLowerCase(),
        anyOf(contains('incorrect'), contains('credential')),
      );
    }
  });

  testWidgets('onAuthStateChanged restores state after app restart', (WidgetTester tester) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'restartuser$timestamp@example.com';
    final password = 'TestPassword123!';
    final username = 'RestartUser$timestamp';

    // Rejestracja i logowanie
    final user = await authService.register(email, password, username);
    expect(user, isNotNull);

    // Symulacja restartu aplikacji (ponowna inicjalizacja AuthService)
    final newAuthService = AuthService();

    // Oczekujemy, że stream odtworzy zalogowanego użytkownika
    expect(
      newAuthService.onAuthStateChanged,
      emits(predicate((u) => u is User && u.email == email)),
    );

    // Wylogowanie i ponowna inicjalizacja
    await newAuthService.signOut();
    final afterSignOutAuthService = AuthService();
    expect(afterSignOutAuthService.onAuthStateChanged, emits(null));
  });
}
