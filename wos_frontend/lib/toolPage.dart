import 'package:flutter/material.dart';
import 'package:wos_frontend/PDCalculator.dart';
import 'package:wos_frontend/dataAnalyser.dart';
import 'package:wos_frontend/htDistParams.dart';
import 'package:wos_frontend/navMenu.dart';

class ToolPage extends StatefulWidget {
  final String toolGroup;
  final String toolName;
  const ToolPage({super.key, required this.toolName, required this.toolGroup});

  @override
  State<ToolPage> createState() => ToolPageState();
}

class ToolPageState extends State<ToolPage> {
  dynamic tool;
  int numSelects = 0;
  late String currentGroup = widget.toolGroup;
  late String currentTool = widget.toolName;
  late NavMenu menu = NavMenu(
      selectTool: selectTool,
      currentGroup: currentGroup,
      currentTool: currentTool);
  void selectTool(String toolName, String toolGroup) {
    setState(() {
      numSelects += 1;
      currentGroup = toolGroup;
      currentTool = toolName;
      menu = NavMenu(
          selectTool: selectTool,
          currentGroup: currentGroup,
          currentTool: currentTool);
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    // Determines which type of tool to build
    //
    if (currentGroup == "Probability distribution calculators") {
      tool = PDCalculator(distribution: currentTool);
    } else if (currentGroup == "Data analysis") {
      tool = const DataAnalyser();
    } else if (currentGroup == "Hypothesis testing") {
      tool = const htDistParams();
    }

    return Row(children: [
      Expanded(
          flex: 1,
          child: Padding(padding: const EdgeInsets.all(10), child: menu)),
      Expanded(
          flex: 3,
          child: Padding(padding: const EdgeInsets.all(10), child: tool))
    ]);
  }
}
