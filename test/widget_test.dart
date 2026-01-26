// Basic Flutter widget test for Walkup MVP

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walkupmvp/main.dart';

void main() {
  testWidgets('App launches with Game Day screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: WalkupApp(),
      ),
    );

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that the Game Day screen appears
    expect(find.text('Game Day Controller'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
  });
}
