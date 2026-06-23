import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows loading indicator then home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('YCulture'), findsOneWidget);
    expect(find.text('Jouer maintenant'), findsOneWidget);
  });
}
