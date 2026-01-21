import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_grupowy/screens/typed_screen.dart';

void main() {
  group('TypedScreen', () {
    testWidgets('should render correctly with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: true,
          ),
        ),
      );

      // Verify basic UI elements
      expect(find.text('Type your answer'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("Don't know?"), findsOneWidget);
    });

    testWidgets('should show "Don\'t know?" only in practice mode', (WidgetTester tester) async {
      // Test practice mode - should show "Don't know?"
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: true,
          ),
        ),
      );

      expect(find.text("Don't know?"), findsOneWidget);

      // Test exam mode - should NOT show "Don't know?"
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: false,
          ),
        ),
      );

      expect(find.text("Don't know?"), findsNothing);
    });

    testWidgets('should handle TextField submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: true,
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text and submit
      await tester.enterText(textField, '15');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Test should not crash
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should handle skip in practice mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: true,
          ),
        ),
      );

      final skipText = find.text("Don't know?");
      expect(skipText, findsOneWidget);

      // Tap skip
      await tester.tap(skipText);
      await tester.pump();

      // Should show underlined text (highlighting)
      final textWidget = tester.widget<Text>(skipText);
      expect(textWidget.style?.decoration, TextDecoration.underline);

      // Wait for highlight to disappear
      await tester.pump(Duration(seconds: 4));
      
      final updatedTextWidget = tester.widget<Text>(find.text("Don't know?"));
      expect(updatedTextWidget.style?.decoration, TextDecoration.none);
    });

    testWidgets('should not handle skip in exam mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: false,
          ),
        ),
      );

      // "Don't know?" should not be visible in exam mode
      expect(find.text("Don't know?"), findsNothing);
    });

    testWidgets('should display question from engine', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: true,
          ),
        ),
      );

      await tester.pump();

      // Should display a question (format: "X × Y =")
      final questionFinder = find.textContaining('×');
      expect(questionFinder, findsOneWidget);
      
      final questionText = tester.widget<Text>(questionFinder).data;
      expect(questionText, contains('='));
    });    testWidgets('should be responsive on different screen sizes', (WidgetTester tester) async {
      // Test small screen
      await tester.binding.setSurfaceSize(Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: TypedScreen(
            level: 3,
            isPracticeMode: true,
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Test large screen
      await tester.binding.setSurfaceSize(Size(800, 1200));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      
      // Reset to default
      await tester.binding.setSurfaceSize(null);
    });
  });
}
