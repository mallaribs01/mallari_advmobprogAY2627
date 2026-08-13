import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mallari_advmobprog/main.dart';

void main() {
  testWidgets('E-Commerce app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MallariAdvMobProg());

    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });
}