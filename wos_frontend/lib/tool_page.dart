import 'package:flutter/material.dart';
import 'package:wos_frontend/pd_calculator.dart';
import 'package:wos_frontend/data_analyser.dart';
import 'package:wos_frontend/goodness_of_fit.dart';
import 'package:wos_frontend/ht_dist_params.dart';
import 'package:wos_frontend/nav_menu.dart';

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
  bool showMenu = true;

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
    if (currentGroup == "Probability distributions") {
      tool = PDCalculator(distribution: currentTool, key: Key(currentTool));
    } else if (currentGroup == "Data analysis") {
      tool = const DataAnalyser();
    } else if (currentGroup == "Hypothesis testing") {
      if (currentTool == "Distributional parameters") {
        tool = const HTDistParams();
      } else {
        tool = const GoodnessOfFit();
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      menu,
      Expanded(
          flex: 7,
          child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 5, right: 10),
              child: tool))
    ]);
  }
}
