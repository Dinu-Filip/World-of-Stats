import 'package:flutter/material.dart';

class NavMenu extends StatefulWidget {
  final Function selectTool;
  final String currentGroup;
  final String currentTool;

  const NavMenu(
      {super.key,
      required this.selectTool,
      required this.currentGroup,
      required this.currentTool});

  @override
  State<NavMenu> createState() => NavMenuState();
}

class NavMenuState extends State<NavMenu> {
  final Map<String, List<String>> options = {
    "Probability distribution calculators": [
      "Binomial",
      "Normal",
      "Chi-squared"
    ],
    "Data analysis": ["Bivariate data"],
    "Hypothesis testing": ["Distributional parameters", "Goodness of fit"]
  };
  final List<NavDropDown> dropDowns = [];

  void createDropDowns() {
    options.forEach((header, options) {
      dropDowns.add(NavDropDown(
          selectTool: widget.selectTool,
          heading: header,
          options: options,
          currentTool: widget.currentTool));
    });
  }

  void updateOption(String group, String toolName) {
    setState(() {
      for (int i = 0; i < dropDowns.length; i++) {
        if (dropDowns[i].heading == group) {
          dropDowns[i] = NavDropDown(
              selectTool: widget.selectTool,
              heading: group,
              options: options[group]!,
              currentTool: toolName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dropDowns.clear();
    createDropDowns();
    return Column(children: [
      const Text("Menu",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ...dropDowns
    ]);
  }
}

class NavDropDown extends StatefulWidget {
  final Function selectTool;
  final String heading;
  final List<String> options;
  final String currentTool;

  const NavDropDown(
      {super.key,
      required this.selectTool,
      required this.heading,
      required this.options,
      required this.currentTool});

  @override
  State<NavDropDown> createState() => NavDropDownState();
}

class NavDropDownState extends State<NavDropDown> {
  late bool showOptions =
      widget.options.contains(widget.currentTool) ? true : false;

  @override
  Widget build(BuildContext context) {
    List<SizedBox> toolSelects = [];

    for (String tool in widget.options) {
      if (tool == widget.currentTool) {
        toolSelects.add(SizedBox(
            height: 30,
            width: double.infinity,
            child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.indigo[300],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.zero))),
                onPressed: () => widget.selectTool(tool, widget.heading),
                child: Row(children: [
                  const SizedBox(width: 80),
                  Text(tool,
                      style: const TextStyle(fontSize: 17, color: Colors.white))
                ]))));
      } else {
        toolSelects.add(SizedBox(
            height: 30,
            width: double.infinity,
            child: TextButton(
                onPressed: () => widget.selectTool(tool, widget.heading),
                child: Row(children: [
                  const SizedBox(width: 80),
                  Text(tool,
                      style:
                          const TextStyle(fontSize: 17, color: Colors.indigo))
                ]))));
      }
    }
    return Column(
      children: [
        SizedBox(
            height: 48,
            width: double.infinity,
            child: TextButton(
                onPressed: () {
                  setState(() {
                    showOptions = !showOptions;
                  });
                },
                child: Row(children: [
                  const SizedBox(width: 30),
                  Expanded(
                      flex: 4,
                      child: Text(
                          style: const TextStyle(
                              fontSize: 18, color: Colors.indigoAccent),
                          widget.heading)),
                  const Expanded(
                      flex: 1,
                      child: Icon(Icons.arrow_drop_down_rounded,
                          color: Colors.indigoAccent, size: 30)),
                  const SizedBox(width: 10)
                ]))),
        (() {
          if (showOptions) {
            return Column(children: toolSelects);
          } else {
            return const SizedBox(height: 0);
          }
        }())
      ],
    );
  }
}
