import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/patient_detail.dart'; // Adjust the import path
import 'package:frontend/widgets/patient_card.dart'; // Adjust the import path

void main() {
  testWidgets('PatientCard renders correctly with valid patient data', (
    WidgetTester tester,
  ) async {
    // Arrange
    final patient = {
      "status": "Stable",
      "patientId": {"name": "John Doe", "gender": "Male", "dob": "1990-01-01"},
    };

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: PatientCard(patient: patient));
          },
        ),
      ),
    );

    // Assert: Check basic rendering, expecting five Containers
    expect(
      find.byType(GestureDetector),
      findsNWidgets(2),
    ); // Outer and arrow button
    expect(
      find.byType(AnimatedContainer),
      findsNWidgets(3),
    ); // Main card and two avatar containers
    expect(find.text('John Doe'), findsOneWidget); // Patient name
    expect(find.byIcon(Icons.male), findsOneWidget); // Gender icon
    expect(find.textContaining('Male, '), findsOneWidget); // Gender and age
    expect(find.text('Stable'), findsOneWidget); // Status
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget); // Arrow icon
    expect(
      find.byType(CircleAvatar),
      findsNWidgets(2),
    ); // Two CircleAvatars (outer and inner)
    expect(
      find.byType(Container),
      findsNWidgets(5),
    ); // Main, two avatars, status circle, status text
  });

  testWidgets('PatientCard renders error message when patient is null', (
    WidgetTester tester,
  ) async {
    // Arrange
    final patient = null;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(body: PatientCard(patient: patient));
          },
        ),
      ),
    );

    // Assert: Check that error message is shown
    expect(find.text('Patient data is missing'), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Text), findsOneWidget); // Error text
    expect(
      find.byType(GestureDetector),
      findsNothing,
    ); // No interactive elements
    expect(find.byType(AnimatedContainer), findsNothing); // No card
  });
}
