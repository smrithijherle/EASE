import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const EASEApp());
}

class EASEApp extends StatelessWidget {
  const EASEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EASE',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}