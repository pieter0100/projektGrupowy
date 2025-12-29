import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AuthService authService;

  setUpAll(() async {
    await Firebase.initializeApp();
    authService = AuthService();
  });

  testWidgets('register, sign in, and sign out (integration)', (WidgetTester tester) async {
    final email = 'testuser${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'TestPassword123!';
    final username = 'TestUser';

    // Register
    final user = await authService.register(email, password, username: username);
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
    final email = 'duplicateuser${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'TestPassword123!';
    final username = 'TestUser';

    // Register first time
    final user1 = await authService.register(email, password, username: username);
    expect(user1, isNotNull);

    // Register second time with same email
    try {
      await authService.register(email, password, username: username);
      fail('Expected an exception for duplicate email');
    } catch (e) {
      expect(e.toString(), contains('email-already-in-use'));
    }
  });

  testWidgets('sign in with wrong password should fail', (WidgetTester tester) async {
    final email = 'wrongpwuser${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'TestPassword123!';
    final wrongPassword = 'WrongPassword!';
    final username = 'TestUser';

    // Register
    final user = await authService.register(email, password, username: username);
    expect(user, isNotNull);

    // Try to sign in with wrong password
    try {
      await authService.signIn(email, wrongPassword);
      fail('Expected an exception for wrong password');
    } catch (e) {
      expect(e.toString(), contains('invalid-credential'));
    }
  });

  testWidgets('sign in with non-existent email should fail', (WidgetTester tester) async {
    final email = 'nonexistent${DateTime.now().millisecondsSinceEpoch}@example.com';
    final password = 'TestPassword123!';

    // Try to sign in with email that was never registered
    try {
      await authService.signIn(email, password);
      fail('Expected an exception for user not found');
    } catch (e) {
      expect(e.toString(), contains('invalid-credential'));
    }
  });
}
