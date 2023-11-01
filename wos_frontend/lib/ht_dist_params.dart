import 'dart:convert';
import 'package:latext/latext.dart';
import 'package:flutter/material.dart';
import 'package:wos_frontend/option_select.dart';
import 'package:wos_frontend/calc_input.dart';
import 'package:wos_frontend/calcOutput.dart';
import 'package:http/http.dart' as http;
import 'package:wos_frontend/info_section.dart';
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

class HTDistParams extends StatefulWidget {
  const HTDistParams({super.key});

  @override
  State<HTDistParams> createState() => HTDistParamsState();
}

class HTDistParamsState extends State<HTDistParams> {
  //
  // Stores the supported distributions
  //
  final List<String> distributions = ["binomial", "normal"];
  //
  // Stores the two ways that the test can be carried out
  //
  final List<String> typeMethods = ["critical region", "p value"];
  final List<String> typeTests = ["one-tailed", "two-tailed"];
  final List<String> tails = ["lower", "upper"];
  final List<String> sigLevels = [
    "0.01",
    "0.025",
    "0.05",
    "0.1",
    "0.2",
    "0.25"
  ];
  //
  // Parameters of tests are initialised
  //
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
  String sigLevel = "0.01";
  int numSubmits = 0;

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
    //
    // Changes the method to p value or critical region
    //
    Map<String, String> resultsContent = {};
    currentRes![currentMethod]
        .forEach((heading, method) => resultsContent[heading] = method);
    outputSection = CalcOutput(outputInfo: resultsContent);
  }

  void updateOutput() {
    //
    // Updates results variable with results of test
    //
    List<Expanded> results = [];
    currentRes!["res"].forEach((heading, data) {
      if (!typeMethods.contains(heading)) {
        results.add(Expanded(
            child: Column(children: [
          Text(heading, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 4),
          LaTexT(
              laTeXCode: Text(data.toString(),
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
    //
    // Adds parameters of test to data to be sent to backend
    //
    submittedVals["test_stat"] =
        submittedVals[testVals[currentDistribution]!["test_stat"]]!;
    submittedVals["distribution"] = currentDistribution;
    submittedVals["population_param_name"] =
        testVals[currentDistribution]!["population_param_name"]!;
    submittedVals["population_param_value"] =
        submittedVals[testVals[currentDistribution]!["population_param"]]!;
    submittedVals["type_test"] = currentTypeTest;
    //
    // Upper and lower tail tests refer only to one-tailed tests
    //
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
    return Column(children: [
      const SizedBox(
          height: 50,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Hypothesis tests of distributional parameters",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(width: 12),
            InfoSection(
                title: "Hypothesis tests of distribution parameters",
                toolName: "Distributional parameters")
          ])),
      Expanded(
          child: Row(children: [
        Expanded(
            flex: 2,
            child: Column(children: [
              SizedBox(
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
                  const SizedBox(height: 40),
                  Expanded(child: outputSection!)
                ])));
          }
        }())
      ]))
    ]);
  }
}
