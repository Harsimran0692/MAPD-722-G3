import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/doctor_note_tile.dart'; // Adjust the import path

void main() {
  testWidgets('DoctorNoteTile renders correctly with initial state', (
    WidgetTester tester,
  ) async {
    // Arrange
    final note = {"note": "Sample note", "createdAt": "2025-04-13"};
    final onUpdateCallback = () {};
    final onDeleteCallback = () {};

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: DoctorNoteTile(
                note: note,
                onUpdate: onUpdateCallback,
                onDelete: onDeleteCallback,
              ),
            );
          },
        ),
      ),
    );

    // Assert: Check basic rendering, expecting only 1 Container (the outer one)
    expect(find.byType(Dismissible), findsOneWidget);
    expect(find.byIcon(Icons.note_alt), findsOneWidget); // Leading icon
    expect(find.text('Sample note'), findsOneWidget); // Note text
    expect(
      find.textContaining('Added: 2025-04-13'),
      findsOneWidget,
    ); // Created at
    expect(find.byIcon(Icons.edit), findsOneWidget); // Edit button
    expect(find.byType(ListTile), findsOneWidget);
    expect(
      find.byType(Container),
      findsOneWidget,
    ); // Only the outer Container is visible initially

    // Optionally, check that the Dismissible has a key
    final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
    expect(dismissible.key, isNotNull);
  });
}
