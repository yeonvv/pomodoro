import 'package:chosimpo_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffE7626C),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 50,
            color: Color.lerp(Colors.transparent, Colors.grey, 0.3),
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 25,
            color: Color.lerp(Colors.transparent, Colors.grey, 0.3),
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardColor: const Color(0xffF4EDDB),
      ),
      home: const HomeScreen(),
    );
  }
}