import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/patient_history_row.dart'; // Adjust the import path

void main() {
  testWidgets('PatientHistoryRow renders correctly with Stable status', (
    WidgetTester tester,
  ) async {
    // Arrange
    final history = {
      "date": "2025-04-13",
      "status": "Stable",
      "bp": "120/80 mmHg",
      "oxygen": "95%",
      "hr": "70 bpm",
    };

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: PatientHistoryRow(history: history));
          },
        ),
      ),
    );

    // Assert: Check basic rendering
    expect(find.byType(Row), findsNWidgets(2)); // Main Row and status Row
    expect(find.byType(Container), findsOneWidget); // Icon container
    expect(find.byIcon(Icons.history), findsOneWidget); // History icon
    expect(find.text('Date: 2025-04-13'), findsOneWidget); // Date
    expect(find.text('Status: Stable'), findsOneWidget); // Status
    expect(find.byIcon(Icons.circle), findsOneWidget); // Status indicator
    expect(find.text('Blood Pressure: 120/80 mmHg'), findsOneWidget); // BP
    expect(find.text('Oxygen: 95%'), findsOneWidget); // Oxygen
    expect(find.text('Heart Rate: 70 bpm'), findsOneWidget); // Heart Rate
    expect(find.byType(Column), findsOneWidget); // Vitals column
  });

  testWidgets('PatientHistoryRow renders correctly with Critical status', (
    WidgetTester tester,
  ) async {
    // Arrange
    final history = {
      "date": "2025-04-12",
      "status": "Critical",
      "bp": "140/90 mmHg",
      "oxygen": "90%",
      "hr": "100 bpm",
    };

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: PatientHistoryRow(history: history));
          },
        ),
      ),
    );

    // Assert: Check basic rendering
    expect(find.byType(Row), findsNWidgets(2)); // Main Row and status Row
    expect(find.byType(Container), findsOneWidget); // Icon container
    expect(find.byIcon(Icons.history), findsOneWidget); // History icon
    expect(find.text('Date: 2025-04-12'), findsOneWidget); // Date
    expect(find.text('Status: Critical'), findsOneWidget); // Status
    expect(find.byIcon(Icons.circle), findsOneWidget); // Status indicator
    expect(find.text('Blood Pressure: 140/90 mmHg'), findsOneWidget); // BP
    expect(find.text('Oxygen: 90%'), findsOneWidget); // Oxygen
    expect(find.text('Heart Rate: 100 bpm'), findsOneWidget); // Heart Rate
    expect(find.byType(Column), findsOneWidget); // Vitals column
  });
}
