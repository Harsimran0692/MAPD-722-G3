import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/patient_header.dart'; // Adjust the import path

void main() {
  testWidgets('PatientHeader renders correctly with valid patient data', (
    WidgetTester tester,
  ) async {
    // Arrange
    final patientData = {
      "patientId": {"name": "John Doe"},
      "status": "Stable",
    };

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: PatientHeader(patientData: patientData));
          },
        ),
      ),
    );

    // Assert: Check basic rendering, expecting two Containers
    expect(find.byType(Row), findsNWidgets(2)); // Main Row and status Row
    expect(find.byType(Hero), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('J'), findsOneWidget); // Avatar initial
    expect(find.text('John Doe'), findsOneWidget); // Patient name
    expect(find.text('Status: Stable'), findsOneWidget); // Status text
    expect(find.byIcon(Icons.circle), findsOneWidget); // Status icon
    expect(
      find.byType(Container),
      findsNWidgets(2),
    ); // Avatar container and CircleAvatar container
    expect(find.byType(Column), findsOneWidget); // Info column
  });

  testWidgets('PatientHeader renders correctly with missing data', (
    WidgetTester tester,
  ) async {
    // Arrange
    final patientData = {"patientId": {}, "status": null};

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: PatientHeader(patientData: patientData));
          },
        ),
      ),
    );

    // Assert: Check rendering with fallbacks, expecting two Containers
    expect(find.byType(Row), findsNWidgets(2)); // Main Row and status Row
    expect(find.byType(Hero), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Unknown'), findsOneWidget); // Fallback name
    expect(find.text('Status: Unknown'), findsOneWidget); // Fallback status
    expect(find.byIcon(Icons.circle), findsOneWidget); // Status icon
    expect(
      find.byType(Container),
      findsNWidgets(2),
    ); // Avatar container and CircleAvatar container
    expect(find.byType(Column), findsOneWidget); // Info column
  });
}
