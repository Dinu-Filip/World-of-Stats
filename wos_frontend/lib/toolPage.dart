import 'package:flutter/material.dart';
import 'package:wos_frontend/calcInput.dart';
import 'package:wos_frontend/calcOutput.dart';

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
    late var tool;
    if (widget.toolGroup == "Probability distribution calculators") {
      tool = PDCalculator(distribution: widget.toolName);
    } else if (widget.toolGroup == "Data analysis") {
      tool = DataAnalyser();
    } else {
      tool = HypothesisTester();
    }
    return Row(children: [Menu(), tool]);
  }
}

const Map<String, Map<String, Map<String, String>>> PDInfo = {
  "Binomial": {
    "Probability mass function": {
      "n": "Number of trials, n",
      "p": "Probability of success, p",
      "x": "Trial number, x"
    },
    "Cumulative distribution function": {
      "n": "Number of trials, n",
      "p": "Probability of success, p",
      "x_1": "Lower limit, x_1",
      "x_2": "Upper limit, x_2"
    },
    "Inverse binomial function": {
      "n": "Number of trials, n",
      "p": "Probability of success, p",
      "P": "P(X <= x)"
    }
  },
  "Normal": {
    "Cumulative distribution function": {
      "mu": "Mean, mu",
      "sigma": "Standard deviation, sigma",
      "x_1": "Lower limit, x_1",
      "x_2": "Upper limit, x_2"
    },
    "Inverse normal function": {
      "mu": "Mean, mu",
      "sigma": "Standard deviation, sigma",
      "P": "P(X <= x)"
    }
  },
  "Chi-squared": {
    "Cumulative distribution function": {
      "df": "Degrees of freedom",
      "x_1": "Lower limit, x_1",
      "x_2": "Upper limit, x_2"
    },
    "Inverse chi-squared function": {
      "df": "Degrees of freedom",
      "P": "P(X <= x)"
    }
  }
};

class PDCalculator extends StatefulWidget {
  final String distribution;
  final Map<String, Map<String, String>> inputInfo;
  final Map<String, String>? initialVals;

  PDCalculator({super.key, required this.distribution, this.initialVals})
      : inputInfo = PDInfo[distribution]!;

  @override
  State<PDCalculator> createState() => PDCalculatorState();
}

class PDCalculatorState extends State<PDCalculator> {
  late String currentFunc = widget.inputInfo.keys.toList()[0];

  PDCalculatorState() {}
  void updateGraph() {}

  void onSubmit() async {}

  void createInputSection() {}

  void switchFunc(String newFunc) {
    setState(() {
      currentFunc = newFunc;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TextButton> tabs = [];
    widget.inputInfo.keys.toList().forEach((func) => tabs.add(
        TextButton(onPressed: () => {switchFunc(func)}, child: Text(func))));
    return Column(children: [
      Row(children: tabs),
      Row(children: [
        CalcInput(fieldNames, widget.initialVals, (value) {}),
        Column(children: [graph, outputComps])
      ])
    ]);
  }
}
