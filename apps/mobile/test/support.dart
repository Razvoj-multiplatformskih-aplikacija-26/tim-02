import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';

Future<AppDependencies> pumpApp(WidgetTester tester, {bool signedIn = true}) async {
  final dependencies = AppDependencies.fake(latency: Duration.zero, signedIn: signedIn);
  await tester.pumpWidget(TftInsightsApp(dependencies: dependencies));
  await tester.pumpAndSettle();
  return dependencies;
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}
