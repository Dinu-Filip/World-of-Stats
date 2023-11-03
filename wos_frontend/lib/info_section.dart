import 'package:flutter/material.dart';
import 'package:wos_frontend/theory_view.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final String toolName;
  const InfoSection({super.key, required this.title, required this.toolName});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            child: const Icon(Icons.info_outline),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                          body: Center(
                              child: TheoryView(
                                  title: title, toolName: toolName)))));
            }));
  }
}
