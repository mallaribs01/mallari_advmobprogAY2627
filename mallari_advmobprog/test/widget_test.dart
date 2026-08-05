import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mallari_advmobprog/main.dart';
import 'package:mallari_advmobprog/theme_model.dart';

void main() {
  /// Tests whether the counter increments correctly
  /// when the FloatingActionButton is pressed.
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    
    /// Builds the application wrapped with ChangeNotifierProvider.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeModel(),
        child: const MyApp(),
      ),
    );

    /// Verifies that the counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    /// Simulates tapping the increment button.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    /// Verifies that the counter increments from 0 to 1.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}