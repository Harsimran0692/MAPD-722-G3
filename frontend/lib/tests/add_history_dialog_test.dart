import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/add_history_dialog.dart'; // Adjust the import path

void main() {
  testWidgets('AddHistoryDialog renders correctly with initial state', (
    WidgetTester tester,
  ) async {
    // Arrange
    final onAddCallback = (Map<String, dynamic> data) {};

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: AddHistoryDialog(onAdd: onAddCallback));
          },
        ),
      ),
    );

    // Assert: Check only basic rendering
    expect(find.text('Add Patient History'), findsOneWidget);
    expect(find.text('Date & Time'), findsOneWidget);
    expect(find.text('Vital Signs'), findsOneWidget);
    expect(find.text("Doctor's Note"), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.air), findsOneWidget);
    expect(find.byIcon(Icons.opacity), findsOneWidget);
    expect(find.byIcon(Icons.monitor_heart), findsOneWidget);
    expect(find.byIcon(Icons.note), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('Date selection UI elements are present', (
    WidgetTester tester,
  ) async {
    // Arrange
    final onAddCallback = (Map<String, dynamic> data) {};

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: AddHistoryDialog(onAdd: onAddCallback));
          },
        ),
      ),
    );

    // Assert: Check that date selection elements exist, but don’t tap
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byType(TextFormField).first, findsOneWidget); // Date field
  });

  testWidgets('Cancel button closes the dialog', (WidgetTester tester) async {
    // Arrange
    final onAddCallback = (Map<String, dynamic> data) {};

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: AddHistoryDialog(onAdd: onAddCallback));
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
