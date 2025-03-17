import 'package:flutter/material.dart';
import 'package:tenebris/widgets/Landing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      themeMode: ThemeMode.dark, 
      darkTheme: ThemeData.dark(),
      home: Expanded(child: const Landing()),    
    );
  }
}
