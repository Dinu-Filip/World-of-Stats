import 'package:flutter/material.dart';
import 'package:wos_frontend/PDCalculator.dart';
import 'package:wos_frontend/dataAnalyser.dart';

class ToolPage extends StatefulWidget {
  final String toolGroup;
  final String toolName;
  const ToolPage({super.key, required this.toolName, required this.toolGroup});

  @override
  State<ToolPage> createState() => ToolPageState();
}

class ToolPageState extends State<ToolPage> {
  @override
  Widget build(BuildContext context) {
    late dynamic tool;
    //
    // Determines which type of tool to build
    //
    if (widget.toolGroup == "Probability distribution calculators") {
      tool = PDCalculator(distribution: widget.toolName);
    } else if (widget.toolGroup == "Data analysis") {
      tool = const DataAnalyser();
    }
    return Row(children: [tool]);
  }
}
