import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/add_note_dialog.dart'; // Adjust the import path

void main() {
  testWidgets('AddNoteDialog renders correctly with initial state', (
    WidgetTester tester,
  ) async {
    // Arrange
    final onAddCallback = (String note) {};

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: AddNoteDialog(onAdd: onAddCallback));
          },
        ),
      ),
    );

    // Assert: Check basic rendering
    expect(find.text('Add Doctor Note'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.note_alt), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('Cancel button closes the dialog', (WidgetTester tester) async {
    // Arrange
    final onAddCallback = (String note) {};

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: AddNoteDialog(onAdd: onAddCallback));
          },
        ),
      ),
    );

    // Act: Tap the Cancel button
    await tester.tap(
      find.text('Cancel'),
      warnIfMissed: false,
    ); // Silence warnings
    await tester.pumpAndSettle();

    // Assert: Dialog should close
    expect(find.byType(AlertDialog), findsNothing);
  });
}
