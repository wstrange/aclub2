import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notifications Badge and Formatting', () {
    testWidgets('Badge displays unread count when count > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Badge.count(
                count: 3,
                isLabelVisible: true,
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('Badge is hidden when count is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Badge.count(
                count: 0,
                isLabelVisible: false,
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
