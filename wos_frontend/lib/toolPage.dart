import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wos_frontend/calcInput.dart';
import 'package:wos_frontend/calcOutput.dart';
import 'package:wos_frontend/graphs.dart';
import 'package:wos_frontend/validation.dart';
import 'package:http/http.dart' as http;

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
    "Inverse function": {
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
    "Inverse function": {
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
    "Inverse function": {"df": "Degrees of freedom", "P": "P(X <= x)"}
  }
};

const Map<String, dynamic> graphs = {
  "Binomial": DiscreteGraph,
  "Normal": ContinuousGraph,
  "Chi-squared": ContinuousGraph
};

const List<String> discreteDistributions = ["Binomial"];
const List<String> continuousDistributions = ["Normal"];

const Map<String, Function> validationFuncs = {
  "Binomial": Validation.binomial,
  "Normal": Validation.normal,
  "Chi-squared": Validation.normal
};

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
    }
    // else if (widget.toolGroup == "Data analysis") {
    //   tool = DataAnalyser();
    // } else {
    //   tool = HypothesisTester();
    // }
    return Row(children: [tool]);
  }
}

class PDCalculator extends StatefulWidget {
  //
  // Name of distribution
  //
  final String distribution;
  //
  // Type of function mapped to name of input field and label of input field
  //
  final Map<String, Map<String, String>> inputInfo;
  //
  // Holds values from previous usage from history component
  //
  final Map<String, String>? initialVals;
  PDCalculator({super.key, required this.distribution, this.initialVals})
      : inputInfo = PDInfo[distribution]!;

  @override
  State<PDCalculator> createState() => PDCalculatorState();
}

class PDCalculatorState extends State<PDCalculator> {
  //
  // Stores current function being used with calculator
  //
  late String currentFunc = widget.inputInfo.keys.toList()[0];
  //
  // Creates all the input fields, dp menu and submit button
  //
  late CalcInput inputSection = CalcInput(
      key: Key(currentFunc),
      fieldNames: widget.inputInfo[currentFunc]!,
      initialVals: widget.initialVals,
      onSubmit: onSubmit);
  //
  // Stores all of the fields showing the different output of the calculator
  //
  GridView? resultFields;
  //
  // Stores the graph component
  //
  dynamic graph;
  //
  // Stores dropdown output fields
  //
  CalcOutput? outputSection;

  void switchFunc(String newFunc) {
    //
    // Changes to different function when new tab selected
    //
    setState(() {
      currentFunc = newFunc;
      inputSection = CalcInput(
          key: Key(currentFunc),
          fieldNames: widget.inputInfo[currentFunc]!,
          initialVals: widget.initialVals,
          onSubmit: onSubmit);
      graph = null;
      outputSection = null;
      resultFields = null;
    });
  }

  Future<Map<String, dynamic>> calculateResult(
      Map<String, String> submittedVals) async {
    //
    // Sends request to FastAPI backend to retrieve distribution results
    //
    String baseIP = "127.0.0.1:8000";
    String path = "/${widget.distribution}";
    if (currentFunc == "Probability mass function") {
      path += "/pmf";
    } else if (currentFunc == "Cumulative distribution function") {
      path += "/cdf";
    } else if (currentFunc == "Inverse function") {
      path += "/inv";
    }
    Uri uri = Uri.http(baseIP, path, submittedVals);
    var response = await http.get(uri);
    return jsonDecode(response.body);
  }

  void updateGraph(
      Map<String, dynamic> data, Map<String, String> submittedVals) {
    //
    // Updates graph with new parameters
    //
    if (currentFunc == "Probability mass function") {
      graph = DiscreteGraph(
          barData: data["graph_data"],
          lower: submittedVals["x"]!,
          upper: submittedVals["x"]!);
    } else {
      if (discreteDistributions.contains(widget.distribution)) {
        graph = DiscreteGraph(
            barData: data["graph_data"],
            lower: submittedVals["x_1"]!,
            upper: submittedVals["x_2"]!);
      } else {
        graph = ContinuousGraph(
            lineData: data["graph_data"],
            lower: submittedVals["x_1"]!,
            upper: submittedVals["x_2"]!);
      }
    }
  }

  void updateOutput(Map<String, dynamic> res) {
    //.
    // Updates each output field showing the method for every calculated
    // result
    //
    Map<String, String> outputContent = {};
    List<Container> results = [];
    res.forEach((heading, data) {
      if (heading != "graph_data") {
        if (res[heading].keys.toList().contains("method")) {
          outputContent[heading] = res[heading]!["method"]!;
        }
        String content = res[heading]!["res"]!;
        results.add(Container(
            padding: const EdgeInsets.all(0),
            child: Column(children: [
              Text(style: const TextStyle(fontSize: 18), heading),
              Text(
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  content)
            ])));
      }
    });
    outputSection = CalcOutput(outputInfo: outputContent);
    resultFields = GridView.count(
        crossAxisCount: 2, childAspectRatio: (4 / 1), children: results);
  }

  void onSubmit(Map<String, String> submittedVals) async {
    //
    // Checks inputted fields are valid
    //
    Map<String, dynamic> validateResult =
        validationFuncs[widget.distribution]!(submittedVals);
    late Map<String, dynamic> res;
    if (validateResult["res"]) {
      res = await calculateResult(submittedVals);
    }
    setState(() {
      //
      // Checks inputted fields are valid
      //
      if (validateResult["res"]) {
        updateGraph(res, submittedVals);
        updateOutput(res);
      } else {
        //
        // Creates alert box and clears input fields if invalid
        //
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  content: Text(validateResult["msg"]),
                  actions: [
                    TextButton(
                        onPressed: () => setState(() {
                              Navigator.pop(context, "OK");
                              inputSection
                                  .clearInputFields(validateResult["fields"]);
                            }),
                        child: const Text('OK'))
                  ],
                ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    // Creates tabs to switch function
    //
    List<Expanded> tabs = [];
    widget.inputInfo.keys.toList().forEach((func) {
      late TextButton funcButton;
      if (func == currentFunc) {
        funcButton = TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero))),
            onPressed: () => {switchFunc(func)},
            child: Text(style: const TextStyle(fontSize: 17), func));
      } else {
        funcButton = TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Colors.indigoAccent,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero))),
            onPressed: () => {switchFunc(func)},
            child: Text(style: const TextStyle(fontSize: 17), func));
      }
      tabs.add(
          Expanded(flex: 1, child: SizedBox(height: 40, child: funcButton)));
    });
    return Column(children: [
      Container(
          child: SizedBox(
              width: MediaQuery.of(context).size.width - 4,
              height: 40,
              child: Row(children: tabs))),
      SizedBox(
          width: MediaQuery.of(context).size.width - 2,
          child: Row(children: [
            Expanded(flex: 1, child: inputSection),
            (() {
              if (resultFields != null &&
                  graph != null &&
                  outputSection != null) {
                return Expanded(
                    flex: 2,
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height - 54,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(
                                      top: 25, bottom: 20),
                                  child: SizedBox(
                                      height: 150,
                                      width: 600,
                                      child: resultFields!)),
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20, bottom: 20),
                                      child: graph)),
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      child: outputSection!))
                            ])));
              } else {
                return Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Center(
                            child: Text(
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold),
                                "Enter the parameters of the distribution and click 'Submit' to generate the result"))));
              }
            }())
          ]))
    ]);
  }
}
