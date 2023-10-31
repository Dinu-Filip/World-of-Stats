import 'package:flutter/material.dart';
import 'package:wos_frontend/tool_page.dart';

class StartMenu extends StatefulWidget {
  const StartMenu({super.key});

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  static const Map<String, List<String>> toolGroupNames = {
    "Probability distributions": ["Binomial", "Normal", "Chi-squared"],
    "Data analysis": ["Discrete"],
    "Hypothesis testing": ["Distributional parameters", "Goodness of fit"]
  };
  Map<String, Container> toolGroups = {};

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
      List<ToolSelect> group = [];
      for (final tool in toolNames) {
        group.add(ToolSelect(
            toolName: tool, toolGroup: groupName, onSelect: _onToolSelect));
      }
      toolGroups[groupName] = Container(
          margin: const EdgeInsets.only(left: 15, right: 15),
          child: Column(children: [
            Text(
                textAlign: TextAlign.center,
                groupName,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...group
          ]));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Container> groupSelects = [];
    toolGroups.forEach((groupName, toolGroup) => groupSelects.add(toolGroup));

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 249, 255),
        body: ListView(children: [
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Select one of the tools below",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700))),
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.center,
              children: [
                ...groupSelects,
              ])
        ]));
  }
}

class ToolSelect extends StatefulWidget {
  final String toolName;
  final String toolGroup;
  final ValueChanged<Map<String, String>> onSelect;
  const ToolSelect(
      {super.key,
      required this.toolName,
      required this.toolGroup,
      required this.onSelect});

  @override
  ToolSelectState createState() => ToolSelectState();
}

class ToolSelectState extends State<ToolSelect> {
  double width = 250;
  double height = 170;
  Color background = const Color.fromARGB(255, 249, 249, 251);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: background,
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(255, 232, 232, 232),
                  spreadRadius: 0.5,
                  blurRadius: 15)
            ],
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        margin: const EdgeInsets.all(10),
        child: MouseRegion(
            onEnter: (event) {
              setState(() {
                background = const Color.fromARGB(255, 230, 230, 230);
              });
            },
            onExit: (event) {
              setState(() {
                background = const Color.fromARGB(255, 249, 249, 251);
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () => {
                      widget.onSelect({
                        'tool': widget.toolName,
                        'toolGroup': widget.toolGroup
                      })
                    },
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                        width: width,
                        height: height,
                        child: Column(children: [
                          Image.asset("assets/images/${widget.toolName}.png",
                              fit: BoxFit.fitWidth),
                          const SizedBox(height: 3),
                          Text(widget.toolName,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600))
                        ]))))));
  }
}
