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
}
