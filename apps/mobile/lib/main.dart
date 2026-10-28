import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

void main() {
  runApp(const TftInsightsApp());
}

class TftInsightsApp extends StatelessWidget {
  const TftInsightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFT Insights',
      theme: TftTheme.light(),
      darkTheme: TftTheme.dark(),
      home: const Scaffold(body: Center(child: Text('TFT Insights'))),
    );
  }
}
