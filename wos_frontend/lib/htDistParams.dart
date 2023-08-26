import 'dart:convert';
import 'package:latext/latext.dart';
import 'package:flutter/material.dart';
import 'package:wos_frontend/calcInput.dart';
import 'package:wos_frontend/calcOutput.dart';
import 'package:http/http.dart' as http;
import 'package:wos_frontend/validation.dart';

const Map<String, Map<String, String>> htInfo = {
  "binomial": {
    "num_trials": "Number of trials, n",
    "prob": "Probability of success of population, p",
    "X": "Number of successes in sample, X"
  },
  "normal": {
    "population_mean": "Population mean, mu",
    "sd": "Population standard deviation, sigma",
    "sample_mean": "Sample mean, X",
    "N": "Sample size, N"
  }
};

const Map<String, Function> validationFuncs = {
  "binomial": Validation.binomialHT,
  "normal": Validation.normalHT
};

const Map<String, Map<String, String>> testVals = {
  "binomial": {
    "population_param": "prob",
    "test_stat": "X",
    "population_param_name": "p"
  },
  "normal": {
    "population_param": "population_mean",
    "test_stat": "sample_mean",
    "population_param_name": r"\mu"
  }
};

class htDistParams extends StatefulWidget {
  const htDistParams({super.key});

  @override
  State<htDistParams> createState() => htDistParamsState();
}

class htDistParamsState extends State<htDistParams> {
  final List<String> distributions = ["binomial", "normal"];
  final List<String> typeMethods = ["critical region", "p value"];
  final List<String> typeTests = ["one-tailed", "two-tailed"];
  final List<String> tails = ["lower", "upper"];
  late String currentTail = tails[0];
  late String currentDistribution = distributions[0];
  late String currentMethod = typeMethods[0];
  late String currentTypeTest = typeTests[0];

  late CalcInput inputSection = CalcInput(
      fieldNames: htInfo[currentDistribution]!,
      onSubmit: onSubmit,
      showDp: false);
  CalcOutput? outputSection;
  Map<String, dynamic>? currentRes;
  Column? resultsView;
  String sigLevel = "";
  int numSubmits = 0;
  final List<String> sigLevels = [
    "0.01",
    "0.025",
    "0.05",
    "0.1",
    "0.2",
    "0.25"
  ];

  void setCurrentDistribution(String distribution) {
    setState(() {
      currentDistribution = distribution;
      inputSection = CalcInput(
          fieldNames: htInfo[currentDistribution]!,
          onSubmit: onSubmit,
          showDp: false);
      outputSection = null;
    });
  }

  void setTypeTest(String typeTest) {
    setState(() {
      currentTypeTest = typeTest;
    });
  }

  void setTypeMethod(String typeMethod) {
    setState(() {
      currentMethod = typeMethod;
      if (outputSection != null) {
        updateMethod();
      }
    });
  }

  void setSigLevel(String newSigLevel) {
    sigLevel = newSigLevel;
  }

  void setTypeTail(String newTail) {
    setState(() {
      currentTail = newTail;
    });
  }

  void updateMethod() {
    Map<String, String> resultsContent = {};
    currentRes![currentMethod]
        .forEach((heading, method) => resultsContent[heading] = method);
    outputSection = CalcOutput(outputInfo: resultsContent);
  }

  void updateOutput() {
    List<Expanded> results = [];
    currentRes!["res"].forEach((heading, data) {
      if (!typeMethods.contains(heading)) {
        results.add(Expanded(
            child: Column(children: [
          Text(heading, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 4),
          LaTexT(
              laTeXCode: Text(data,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
        ])));
      }
    });
    resultsView =
        Column(children: [results[0], Row(children: results.sublist(1))]);
    updateMethod();
  }

  Future<Map<String, dynamic>> calculateResult(
      Map<String, String> submittedVals) async {
    submittedVals["test_stat"] =
        submittedVals[testVals[currentDistribution]!["test_stat"]]!;
    submittedVals["distribution"] = currentDistribution;
    submittedVals["population_param_name"] =
        testVals[currentDistribution]!["population_param_name"]!;
    submittedVals["population_param_value"] =
        submittedVals[testVals[currentDistribution]!["population_param"]]!;
    submittedVals["type_test"] = currentTypeTest;
    if (currentTypeTest == "one-tailed") {
      submittedVals["type_tail"] = currentTail;
    }
    String baseIP = "127.0.0.1:8000";
    String path = "/dist-test/";
    Uri uri = Uri.http(baseIP, path);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(submittedVals));
    print(jsonEncode(submittedVals));
    return jsonDecode(response.body);
  }

  void onSubmit(Map<String, String> submittedVals) async {
    submittedVals["sig_level"] = sigLevel;
    Map<String, dynamic> validateResult =
        validationFuncs[currentDistribution]!(submittedVals);
    if (validateResult["res"]) {
      Map<String, dynamic> res = await calculateResult(submittedVals);
      setState(() {
        currentRes = res;
        numSubmits += 1;
        updateOutput();
      });
    } else {
      setState(() {
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: [
      Expanded(
          child: Row(children: [
        Expanded(
            flex: 2,
            child: Column(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Row(children: [
                    Expanded(
                        child: OptionSelect(
                            changeOption: setCurrentDistribution,
                            options: distributions,
                            label: "Select distribution")),
                    Expanded(
                        child: OptionSelect(
                            changeOption: setTypeTest,
                            options: typeTests,
                            label: "Select type of test"))
                  ])),
              (() {
                if (currentTypeTest == "one-tailed") {
                  return Row(children: [
                    Expanded(
                        child: OptionSelect(
                            changeOption: setSigLevel,
                            options: sigLevels,
                            label: "Select significance level")),
                    Expanded(
                        child: OptionSelect(
                            changeOption: setTypeTail,
                            options: tails,
                            label: "Select the tail of the test"))
                  ]);
                } else {
                  return OptionSelect(
                      changeOption: setSigLevel,
                      options: sigLevels,
                      label: "Select significance level");
                }
              }()),
              Expanded(child: inputSection)
            ])),
        (() {
          if (resultsView == null || outputSection == null) {
            return Expanded(
                flex: 3,
                child: Text(
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold),
                    "Enter the parameters of the distribution and click 'Submit' to generate the result"));
          } else {
            return Expanded(
                flex: 3,
                child: SizedBox(
                    child: Column(children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: OptionSelect(
                          changeOption: setTypeMethod,
                          options: typeMethods,
                          label: "Select method of test to show")),
                  SizedBox(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: resultsView!),
                  const SizedBox(height: 20),
                  Expanded(child: outputSection!)
                ])));
          }
        }())
      ]))
    ]));
  }
}

class OptionSelect extends StatefulWidget {
  final ValueChanged<String> changeOption;
  final List<String> options;
  final String label;

  const OptionSelect(
      {super.key,
      required this.changeOption,
      required this.options,
      required this.label});

  @override
  State<OptionSelect> createState() => OptionSelectState();
}

class OptionSelectState extends State<OptionSelect> {
  late String currentOption = widget.options[0];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(widget.label, style: const TextStyle(fontSize: 20)),
      DropdownButton(
          underline: Container(height: 2, color: Colors.indigoAccent),
          value: currentOption,
          items: widget.options.map((String value) {
            return DropdownMenuItem(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 18)));
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              currentOption = value!;
              widget.changeOption(value);
            });
          })
    ]);
  }
}
