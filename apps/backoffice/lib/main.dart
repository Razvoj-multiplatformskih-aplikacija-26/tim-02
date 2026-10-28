import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

void main() {
  runApp(const BackofficeApp());
}

class BackofficeApp extends StatelessWidget {
  const BackofficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFT Insights Backoffice',
      theme: TftTheme.light(),
      darkTheme: TftTheme.dark(),
      home: const Scaffold(body: Center(child: Text('TFT Insights Backoffice'))),
    );
  }
}
