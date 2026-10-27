import 'package:flutter/material.dart';

void main() {
  runApp(const TftInsightsApp());
}

class TftInsightsApp extends StatelessWidget {
  const TftInsightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TFT Insights',
      home: Scaffold(body: Center(child: Text('TFT Insights'))),
    );
  }
}
