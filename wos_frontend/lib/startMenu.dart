import 'package:flutter/material.dart';
import 'package:wos_frontend/toolPage.dart';

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
  Map<String, Expanded> toolGroups = {};

  void _onToolSelect(Map<String, String> toolData) {
    //
    // Loads relevant tool page with corresponding tool and tool group
    //
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                    body: Center(
                        child: ToolPage(
                  toolGroup: toolData['toolGroup']!,
                  toolName: toolData['tool']!,
                )))));
  }

  _StartMenuState() {
    //
    // Adds selectable option for every type of tool
    //
    toolGroupNames.forEach((String groupName, List<String> toolNames) {
      List<SizedBox> group = [];
      for (final tool in toolNames) {
        group.add(SizedBox(
            height: 220,
            child: ToolSelect(
                toolName: tool,
                toolGroup: groupName,
                onSelect: _onToolSelect)));
      }
      toolGroups[groupName] = Expanded(
          flex: 5,
          child: Column(children: [
            Text(groupName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ...group
          ]));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Expanded> groupSelects = [];
    toolGroups.forEach((groupName, toolGroup) => groupSelects.add(toolGroup));

    return Scaffold(
        body: Column(children: [
      const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Select one of the tools below",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Spacer(flex: 1),
        ...groupSelects,
        const Spacer(flex: 1)
      ])
    ]));
  }
}

class ToolSelect extends StatelessWidget {
  const ToolSelect(
      {super.key,
      required this.toolName,
      required this.toolGroup,
      required this.onSelect});

  final String toolName;
  final String toolGroup;
  final ValueChanged<Map<String, String>> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () => {
                      onSelect({'tool': toolName, 'toolGroup': toolGroup})
                    },
                child: SizedBox(
                    width: 250,
                    child: Column(children: [
                      Image.asset("assets/images/$toolName.png",
                          fit: BoxFit.fitWidth),
                      Text(toolName, style: const TextStyle(fontSize: 17))
                    ])))));
  }
}
