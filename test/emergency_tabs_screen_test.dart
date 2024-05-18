import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hike_connect/features/emergency/emergency_info.dart';
import 'package:hike_connect/features/emergency/emergency_tabs_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('EmergencyTabsScreen initial state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmergencyTabsScreen(),
      ),
    );

    expect(find.text('Informatii esentiale - Salvamont Romania'), findsOneWidget);
    expect(find.text('Urgenta'), findsOneWidget);
    expect(find.text('Alimentatia'), findsOneWidget);
    expect(find.text('Accident montan'), findsOneWidget);
  });

  testWidgets('EmergencyTabsScreen tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmergencyTabsScreen(),
      ),
    );

    // Verify initial tab content
    expect(find.text('Apelul de urgenta'), findsOneWidget);
    expect(find.text(EmergencyInfo.getEmergencyPageText()), findsOneWidget);

    // Tap on the "Alimentatia" tab
    await tester.tap(find.text('Alimentatia'));
    await tester.pumpAndSettle();

    // Verify "Alimentatia" tab content
    expect(find.text('Alimentatia si hidratarea'), findsOneWidget);
    expect(find.text(EmergencyInfo.getFoodPageText()), findsOneWidget);

    // Tap on the "Accident montan" tab
    await tester.tap(find.text('Accident montan'));
    await tester.pumpAndSettle();

    // Verify "Accident montan" tab content
    expect(find.text('Martor la accident montan'), findsOneWidget);
    expect(find.text(EmergencyInfo.getInjuryPageText()), findsOneWidget);
  });
}
