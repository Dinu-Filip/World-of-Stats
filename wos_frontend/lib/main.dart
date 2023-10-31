import 'package:flutter/material.dart';
import 'package:wos_frontend/start_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'World of Stats',
      home: StartMenu(),
    );
  }
}
