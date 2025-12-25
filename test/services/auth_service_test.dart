import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  late AuthService authService;

  setUpAll(() async {
    // Initialize Firebase only once for all tests
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    authService = AuthService();
  });

  test('register, sign in, and sign out', () async {
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
}