import 'package:flutter/material.dart';
import 'package:wos_frontend/calc_output.dart';
import 'package:wos_frontend/info_section.dart';
import 'package:wos_frontend/option_select.dart';
import 'package:wos_frontend/validation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoodnessOfFit extends StatefulWidget {
  const GoodnessOfFit({super.key});

  @override
  State<GoodnessOfFit> createState() => GoodnessOfFitState();
}

const List<String> distributions = ["Binomial"];
const Map<String, Map<String, String>> distParams = {
  "Binomial": {"n": "Number of trials, n", "p": "Probability of success, p"}
};
const Map<String, List<String>> estimatedParams = {
  "Binomial": ["p", "Probability of success, p"]
};

class GoodnessOfFitState extends State<GoodnessOfFit> {
  //
  // Stores the result of the previous calculation
  //
  Map<String, dynamic>? currentRes;
  bool estimateParam = false;
  late GOFInput inputSection = GOFInput(
      onSubmit: onSubmit,
      estimateParam: estimateParam,
      currentDist: currentDist);
  late String currentDist = distributions[0];
  CalcOutput? outputSection;
  Row? resultView;

  void updateOutput() {
    //
    // Updates output section with result of test
    //
    Map<String, String> test = {};
    currentRes!["test"].forEach((step, method) {
      test[step] = method;
    });
    outputSection = CalcOutput(outputInfo: test);
    List<Expanded> resultFields = [];
    currentRes!["res"].forEach((heading, data) {
      resultFields.add(Expanded(
          flex: 2,
          child: Column(children: [
            Text(heading,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
            Text(data.toString(),
                style:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.bold))
          ])));
    });
    resultView = Row(children: [
      ...resultFields,
    ]);
  }

  void onSubmit(Map<String, String> submittedVals) async {
    Map<String, dynamic> validateResult =
        Validation.goodnessOfFit(submittedVals);
    if (validateResult["res"]) {
      Map<String, dynamic> res = await calculateResult(submittedVals);
      setState(() {
        currentRes = res;
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
                            }),
                        child: const Text('OK'))
                  ],
                ));
      });
    }
  }

  Future<Map<String, dynamic>> calculateResult(
      Map<String, String> submittedVals) async {
    String baseIP = "127.0.0.1:8000";
    String path = "/gof-test/";
    Uri uri = Uri.http(baseIP, path);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(submittedVals));
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
          padding: EdgeInsets.all(5),
          child: SizedBox(
              height: 50,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Goodness of fit tests",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                SizedBox(height: 50, width: 10),
                InfoSection(
                    title: "About goodness of fit tests",
                    toolName: "Goodness of fit")
              ]))),
      Expanded(
          child: Row(
        children: [
          inputSection,
          (() {
            if (outputSection == null || resultView == null) {
              return Expanded(
                  flex: 3,
                  child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold),
                          "Enter the observed frequencies and the parameters of the modelling distribution, and click 'Submit' to generate the result")));
            } else {
              return Expanded(
                  flex: 3,
                  child: Column(children: [
                    const SizedBox(height: 20),
                    SizedBox(height: 100, child: resultView!),
                    Expanded(child: outputSection!)
                  ]));
            }
          }())
        ],
      ))
    ]);
  }
}

class GOFInput extends StatefulWidget {
  final ValueChanged<Map<String, String>> onSubmit;
  final bool estimateParam;
  final String currentDist;

  const GOFInput(
      {super.key,
      required this.onSubmit,
      required this.estimateParam,
      required this.currentDist});

  @override
  State<GOFInput> createState() => GOFInputState();
}

class GOFInputState extends State<GOFInput> {
  final List<String> sigLevels = ["0.01", "0.05", "0.10", "0.20", "0.25"];
  //
  // xVals is values of random variable for observed frequency
  //
  final TextEditingController xValsController = TextEditingController();
  late final TextField xVals = TextField(
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
          labelText: "Enter the values of x",
          labelStyle: TextStyle(fontSize: 20),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  width: 2, color: Color.fromRGBO(83, 109, 254, 1)))),
      maxLines: 2,
      controller: xValsController);
  //
  // observedVals is number of times each value of x was observed
  //
  final TextEditingController observedValsController = TextEditingController();
  late final TextField observedVals = TextField(
      decoration: const InputDecoration(
          labelText: "Enter the observed frequencies for each value of x",
          labelStyle: TextStyle(fontSize: 20),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.indigoAccent))),
      maxLines: 2,
      style: const TextStyle(fontSize: 20),
      controller: observedValsController);
  //
  // estimatedParam holds calculated value of parameter for the distribution
  //
  final TextEditingController estimatedParam = TextEditingController();
  late final TextFormField estimatedParamField = TextFormField(
      controller: estimatedParam,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
          labelText: estimatedParams[widget.currentDist]![1],
          labelStyle: const TextStyle(fontSize: 20)));
  //
  // sigLevel field allows user to select significance level from pre-defined set of options
  //
  String sigLevel = "0.01";
  late final OptionSelect sigLevelField = OptionSelect(
      changeOption: setSigLevel,
      options: sigLevels,
      label: "Select significance level");
  //
  // delimiterControl allows user to set the delimiter for their input data
  //
  final TextEditingController delimiterController = TextEditingController();
  late final TextFormField delimiterControl = TextFormField(
      controller: delimiterController,
      decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
          labelText: "Delimiter",
          labelStyle: TextStyle(fontSize: 20)));

  final Map<String, TextEditingController> inputVals = {};
  List<TextFormField> inputComps = [];
  bool showEstimateParam = true;

  String currentDistribution = distributions[0];

  void setSigLevel(String newLevel) {
    sigLevel = newLevel;
  }

  void setCurrentDistribution(String newDist) {
    setState(() {
      currentDistribution = newDist;
    });
  }

  void clearInputFields(List<String> fields) {
    for (String fieldName in fields) {
      inputVals[fieldName]!.text = "";
    }
  }

  void addInputVals() {
    //
    // Adds controllers for text fields to inputVals map so that values can be retrieved when submitted
    //
    inputVals["xVals"] = xValsController;
    inputVals["observedVals"] = observedValsController;
    distParams[widget.currentDist]!.forEach((key, value) {
      //
      // Adds all distribution-specific fields to inputVals
      //
      if (key != estimatedParams[widget.currentDist]![0]) {
        inputVals[key] = TextEditingController();
        inputComps.add(TextFormField(
            style: const TextStyle(fontSize: 20),
            controller: inputVals[key],
            decoration: InputDecoration(
                enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(width: 2, color: Colors.indigoAccent)),
                labelText: value,
                labelStyle: const TextStyle(fontSize: 20))));
      }
    });
  }

  void onSubmit() {
    Map<String, String> submittedVals = {};
    //
    // Submitted values from default fields added to map
    //
    submittedVals["xVals"] = xValsController.text;
    submittedVals["observedVals"] = observedValsController.text;
    submittedVals["delimiter"] = delimiterController.text;
    submittedVals["sigLevel"] = sigLevel;
    submittedVals["distribution"] = currentDistribution;
    submittedVals["estimateParam"] = showEstimateParam.toString();
    submittedVals["estimateParamName"] =
        estimatedParams[widget.currentDist]![1];
    //
    // Submitted values from distribution specific fields added to map
    //
    inputVals.forEach((key, value) {
      if (key != estimatedParams[widget.currentDist]![0]) {
        submittedVals[key] = value.text;
      }
    });
    submittedVals[estimatedParams[widget.currentDist]![0]] =
        estimatedParam.text;
    widget.onSubmit(submittedVals);
  }

  @override
  Widget build(BuildContext context) {
    if (inputVals.keys.isEmpty) {
      addInputVals();
    }
    return Expanded(
        flex: 2,
        child: Container(
            margin: const EdgeInsets.all(15),
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OptionSelect(
                      changeOption: setCurrentDistribution,
                      options: distributions,
                      label: "Select distribution")),
              Row(children: [
                const Expanded(
                    child: Text(
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20),
                        "Estimate parameter by calculation")),
                Checkbox(
                    value: showEstimateParam,
                    onChanged: (value) {
                      setState(() {
                        showEstimateParam = value!;
                      });
                    })
              ]),
              Padding(padding: const EdgeInsets.only(top: 20), child: xVals),
              Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: observedVals),
              ...inputComps,
              (() {
                if (!showEstimateParam) {
                  return estimatedParamField;
                } else {
                  return const SizedBox(height: 0);
                }
              }()),
              const SizedBox(height: 25),
              SizedBox(
                  height: 80,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: sigLevelField),
                        const SizedBox(width: 10),
                        Expanded(child: delimiterControl)
                      ])),
              const SizedBox(height: 25),
              Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigoAccent),
                          onPressed: onSubmit,
                          child: const Text(
                              style: TextStyle(fontSize: 18), "Submit"))))
            ])));
  }
}
