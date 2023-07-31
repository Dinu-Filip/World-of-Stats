import 'package:flutter/material.dart';

class StartMenu extends StatefulWidget {
  const StartMenu({super.key});

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  static const Map<String, List<String>> toolGroupNames = {
    "Probability distribution calculators": [
      "Binomial",
      "Normal",
      "Chi-squared"
    ],
    "Data analysis": ["Bivariate"],
    "Hypothesis testing": ["Distributional parameters", "Goodness of fit"]
  };
  Map<String, Container> toolGroups = {};

  void _onToolSelect(String tool) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(body: Center(child: Text(tool)))));
  }

  _StartMenuState() {
    toolGroupNames.forEach((String groupName, List<String> toolNames) {
      List<ToolSelect> group = [];
      for (final tool in toolNames) {
        group.add(ToolSelect(toolName: tool, onSelect: _onToolSelect));
      }
      toolGroups[groupName] = Container(
          margin: const EdgeInsets.all(20), child: Column(children: group));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Container> groupSelects = [];
    toolGroups.forEach((groupName, toolGroup) => groupSelects.add(toolGroup));

    return Scaffold(body: Row(children: groupSelects));
  }
}

class ToolSelect extends StatelessWidget {
  const ToolSelect({super.key, required this.toolName, required this.onSelect});

  final String toolName;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: GestureDetector(
            onTap: () => {onSelect(toolName)},
            child: SizedBox(
                width: 300,
                child: Column(children: [
                  Image.asset("assets/images/$toolName.png"),
                  Text(toolName)
                ]))));
  }
}
