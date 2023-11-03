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
  static const Map<String, List<String>> options = {
    "Probability distributions": ["Binomial", "Normal", "Chi-squared"],
    "Data analysis": ["Discrete"],
    "Hypothesis testing": ["Distributional parameters", "Goodness of fit"]
  };
  final List<NavDropDown> dropDowns = [];
  bool showMenu = true;

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
    });
  }

  void createDropDowns() {
    //
    // Creates dropdown for each group of tools in the menu
    //
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
    //
    // Dynamic resizing of menu depending on width of application
    //
    int flexVal = 2;
    double currentWidth = MediaQuery.of(context).size.width;
    if (900 <= currentWidth && currentWidth < 1250) {
      flexVal = 3;
    } else if (currentWidth < 900) {
      flexVal = 4;
    }

    if (showMenu) {
      return Flexible(
          flex: flexVal,
          child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                  constraints: const BoxConstraints(minWidth: 500),
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(250, 250, 250, 1),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(255, 238, 238, 238),
                            blurRadius: 10,
                            spreadRadius: 0.2)
                      ]),
                  child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 15, top: 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("World of Stats",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                  width: 40,
                                  height: 35,
                                  child: TextButton(
                                      onPressed: toggleMenu,
                                      child: const Icon(
                                          color: Colors.indigoAccent,
                                          Icons.keyboard_arrow_left)))
                            ])),
                    const SizedBox(height: 10),
                    ...dropDowns
                  ]))));
    } else {
      return Flexible(
          flex: flexVal,
          child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 5),
              child: SizedBox(
                  width: 40,
                  height: 35,
                  child: TextButton(
                      onPressed: toggleMenu,
                      child: const Icon(
                          color: Colors.indigoAccent,
                          Icons.keyboard_arrow_right)))));
    }
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
    //
    // Selectively renders the option that represents the tool currently being used
    //
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

    IconData toggleIcon;
    if (showOptions) {
      toggleIcon = Icons.arrow_drop_up_rounded;
    } else {
      toggleIcon = Icons.arrow_drop_down_rounded;
    }
    return Column(
      children: [
        SizedBox(
            height: 48,
            child: TextButton(
                onPressed: () {
                  setState(() {
                    showOptions = !showOptions;
                  });
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 20),
                      Text(
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.indigoAccent),
                          widget.heading),
                      const Spacer(),
                      Icon(toggleIcon, color: Colors.indigoAccent, size: 30),
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
