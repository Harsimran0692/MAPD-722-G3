import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/bottom_nav_bar.dart'; // Adjust the import path

void main() {
  testWidgets('BottomNavBar renders correctly with initial state', (
    WidgetTester tester,
  ) async {
    // Arrange
    const int currentIndex = 0;
    final onTapCallback = (int index) {};

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              bottomNavigationBar: BottomNavBar(
                currentIndex: currentIndex,
                onTap: onTapCallback,
              ),
            );
          },
        ),
      ),
    );

    // Assert: Check basic rendering
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Check if the current index is highlighted (first item "Home" should be selected)
    final navBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navBar.currentIndex, currentIndex);
  });
}
