import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/patient_section.dart'; // Adjust the import path

void main() {
  testWidgets('PatientSection renders correctly with action', (
    WidgetTester tester,
  ) async {
    // Arrange
    const title = "Patient Info";
    const icon = Icons.info;
    final content = [
      const Text("Sample content 1"),
      const Text("Sample content 2"),
    ];
    final action = ElevatedButton(
      onPressed: () {},
      child: const Text("Action"),
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: PatientSection(
                title: title,
                icon: icon,
                content: content,
                action: action,
              ),
            );
          },
        ),
      ),
    );

    // Assert: Check basic rendering
    expect(
      find.byType(Column),
      findsNWidgets(2),
    ); // Main Column and content Column
    expect(
      find.byType(Row),
      findsNWidgets(2),
    ); // Title Row and nested icon-title Row
    expect(find.byIcon(Icons.info), findsOneWidget); // Icon
    expect(find.text('Patient Info'), findsOneWidget); // Title
    expect(find.text('Sample content 1'), findsOneWidget); // Content item 1
    expect(find.text('Sample content 2'), findsOneWidget); // Content item 2
    expect(find.text('Action'), findsOneWidget); // Action button
    expect(find.byType(Card), findsOneWidget); // Card
    expect(find.byType(Container), findsOneWidget); // Content container
  });

  testWidgets('PatientSection renders correctly without action', (
    WidgetTester tester,
  ) async {
    // Arrange
    const title = "Vital Signs";
    const icon = Icons.favorite;
    final content = [
      const Text("Heart Rate: 70 bpm"),
      const Text("BP: 120/80 mmHg"),
    ];

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: PatientSection(title: title, icon: icon, content: content),
            );
          },
        ),
      ),
    );

    // Assert: Check basic rendering
    expect(
      find.byType(Column),
      findsNWidgets(2),
    ); // Main Column and content Column
    expect(
      find.byType(Row),
      findsNWidgets(2),
    ); // Title Row and nested icon-title Row
    expect(find.byIcon(Icons.favorite), findsOneWidget); // Icon
    expect(find.text('Vital Signs'), findsOneWidget); // Title
    expect(find.text('Heart Rate: 70 bpm'), findsOneWidget); // Content item 1
    expect(find.text('BP: 120/80 mmHg'), findsOneWidget); // Content item 2
    expect(find.byType(ElevatedButton), findsNothing); // No action button
    expect(find.byType(Card), findsOneWidget); // Card
    expect(find.byType(Container), findsOneWidget); // Content container
  });
}
