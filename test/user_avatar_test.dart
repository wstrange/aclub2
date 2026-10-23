import 'package:aclub2/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserAvatar Widget', () {
    testWidgets('renders initials when photoUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: null,
              initials: 'JD',
              radius: 20,
            ),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders initials when photoUrl is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: '   ',
              initials: 'AB',
            ),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('applies custom background and text color on fallback', (tester) async {
      const bgColor = Colors.purple;
      const fgColor = Colors.white;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: null,
              initials: 'TL',
              backgroundColor: bgColor,
              foregroundColor: fgColor,
            ),
          ),
        ),
      );

      final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(circleAvatar.backgroundColor, bgColor);
      expect(find.text('TL'), findsOneWidget);
    });

    testWidgets('creates Image.network when photoUrl is valid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: 'https://example.com/avatar.jpg',
              initials: 'OK',
            ),
          ),
        ),
      );

      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
