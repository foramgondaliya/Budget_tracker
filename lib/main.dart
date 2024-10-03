import 'package:animation/screens/spending.dart';
import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomePage(),
        'SpendingPage': (context) => const SpendingPage(),
      },
    ),
  );
}
