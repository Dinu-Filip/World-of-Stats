import 'dart:convert';
import 'dart:io';
import 'package:wos_frontend/calcOutput.dart';
import 'package:wos_frontend/graphs.dart';
import 'package:flutter/material.dart';
import 'package:wos_frontend/calc_input.dart';
import 'package:wos_frontend/validation.dart';
import 'package:wos_frontend/dataTable.dart';
import 'package:http/http.dart' as http;

class DataAnalyser extends StatefulWidget {
  final Map<String, String>? initialVals;
  const DataAnalyser({super.key, this.initialVals});

  @override
  State<DataAnalyser> createState() => DataAnalyserState();
}

class DataAnalyserState extends State<DataAnalyser> {
  final List<String> inputTypes = [
    "(x, y) pairs",
    "x, y list inputs",
    "table input"
  ];
  String currentInputType = "(x, y) pairs";
  String typeData = "bivariate";
  dynamic graph;
  GridView? resultFields;
  CalcOutput? outputSection;
  late DataAnalyserInput inputSection = DataAnalyserInput(
      inputType: currentInputType, onSubmit: onSubmit, typeData: typeData);

  void switchTypeInput(String newType) {
    setState(() {
      currentInputType = newType;
      inputSection = DataAnalyserInput(
          inputType: newType, onSubmit: onSubmit, typeData: typeData);
      graph = null;
      resultFields = null;
      outputSection = null;
    });
  }

  void setTypeData(String newDataType) {
    if (newDataType != typeData) {
      setState(() {
        typeData = newDataType;
        graph = null;
        resultFields = null;
        outputSection = null;
        inputSection = DataAnalyserInput(
            inputType: currentInputType,
            onSubmit: onSubmit,
            typeData: typeData);
      });
    }
  }

  Future<Map<String, dynamic>> calculateResult(
      Map<String, dynamic> submittedVals) async {
    String baseIP = "127.0.0.1:8000";
    String path = "";
    if (typeData == "bivariate") {
      path = "/bivariate/";
    } else {
      path = "/univariate/";
    }
    Uri uri = Uri.http(baseIP, path);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(submittedVals));
    return jsonDecode(response.body);
  }

  void updateGraph(
      String slope, String intercept, List<String> xVals, List<String> yVals) {
    graph = ScatterGraph(
        xData: xVals, yData: yVals, slope: slope, intercept: intercept);
    print(graph);
  }

  void updateOutputs(Map<String, dynamic> results) {
    Map<String, String> resultsContent = {};
    print(results);
    List<Column> resultGridItems = [];

    for (String heading in results.keys.toList()) {
      if (results[heading]["method"] != null) {
        resultsContent[heading] = results[heading]["method"];
      }
      String content = results[heading]["res"];
      resultGridItems.add(Column(children: [
        Text(style: const TextStyle(fontSize: 18), heading),
        Text(content,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
      ]));
    }
    outputSection = CalcOutput(outputInfo: resultsContent);
    resultFields = GridView.count(
        crossAxisCount: 3,
        childAspectRatio: (4 / 1),
        children: resultGridItems);
  }

  void onSubmit(submittedVals) async {
    Map<String, dynamic> validateResult =
        Validation.dataAnalysis(submittedVals);
    late final Map<String, dynamic> response;
    List<String> xVals = [];
    List<String> yVals = [];
    if (validateResult["res"]) {
      if (currentInputType == "(x, y) pairs") {
        List<String> points =
            submittedVals["dataInput"]!.split(submittedVals["delimiter"]!);
        for (String point in points) {
          List<String> xy = point.substring(1, point.length - 1).split(", ");
          xVals.add(xy[0]);
          yVals.add(xy[1]);
        }
      } else if (currentInputType == "x, y list inputs" &&
          typeData == "bivariate") {
        xVals = submittedVals["xInput"]!.split(submittedVals["delimiter"]!);
        yVals = submittedVals["yInput"]!.split(submittedVals["delimiter"]!);
      } else if (currentInputType == "x, y list inputs" &&
          typeData == "univariate") {
        xVals = submittedVals["xInput"]!.split(submittedVals["delimiter"]!);
      } else {
        xVals = submittedVals["xVals"]!.split(",");
        yVals = submittedVals["yVals"]!.split(",");
      }
      response = await calculateResult({
        "xVals": xVals,
        "yVals": yVals,
        "dp": submittedVals["dp"],
        "typeData": typeData
      });
    }
    setState(() {
      if (validateResult["res"]) {
        if (typeData == "bivariate") {
          updateGraph(response["regress_slope"]["res"],
              response["regress_intercept"]["res"], xVals, yVals);
        }
        updateOutputs(response);
      } else {
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: [
      Row(children: [
        Expanded(
            flex: 1,
            child: Column(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Select input type",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 20),
                  SizedBox(
                      height: 50,
                      child: DropdownButton(
                          value: currentInputType,
                          items: inputTypes
                              .map<DropdownMenuItem<String>>((String value) =>
                                  DropdownMenuItem(
                                      value: value,
                                      child: Text(value,
                                          style:
                                              const TextStyle(fontSize: 16))))
                              .toList(),
                          onChanged: (value) => switchTypeInput(value!)))
                ]),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                    height: 50,
                    width: 200,
                    child: ListTile(
                        title: const Text("Univariate data",
                            style: TextStyle(fontSize: 18)),
                        leading: Radio(
                            value: "univariate",
                            groupValue: typeData,
                            onChanged: (value) {
                              setTypeData("univariate");
                            }))),
                SizedBox(
                    height: 50,
                    width: 200,
                    child: ListTile(
                        title: const Text("Bivariate data",
                            style: TextStyle(fontSize: 18)),
                        leading: Radio(
                            value: "bivariate",
                            groupValue: typeData,
                            onChanged: (value) {
                              setTypeData("bivariate");
                            })))
              ]),
              SizedBox(
                  height: MediaQuery.of(context).size.height - 250,
                  child: Container(
                      margin: const EdgeInsets.all(15), child: inputSection))
            ])),
        Expanded(
            flex: 1,
            child: Column(children: [
              const SizedBox(height: 72.5),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 270,
                  child: resultFields ??
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold),
                              "Enter the parameters of the distribution and click 'Submit' to generate the result"))),
              const SizedBox(height: 72.5)
            ]))
      ]),
      (() {
        if (graph == null && resultFields == null && outputSection == null) {
          return const Flexible(flex: 1, child: Text(""));
        } else {
          print("good2");
          return Expanded(
              flex: 2,
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Container(
                        margin: const EdgeInsets.all(15), child: graph)),
                Expanded(
                    flex: 1,
                    child: Container(
                        margin: const EdgeInsets.all(15),
                        child: outputSection!))
              ]));
        }
      }())
    ]));
  }
}

class DataAnalyserInput extends StatelessWidget {
  final String inputType;
  final ValueChanged<Map<String, String>> onSubmit;
  final Map<String, String>? initialVals;
  final Map<String, dynamic> inputComps;
  final Map<String, dynamic> inputVals;
  final String typeData;
  final Map<int, dynamic> xTableInput = {};
  final Map<int, dynamic> yTableInput = {};

  void onChanged(List<dynamic> params) {
    if (params[0][1] == 0) {
      xTableInput[params[0][0]] = params[1];
    } else {
      yTableInput[params[0][0]] = params[1];
    }
  }

  DataAnalyserInput._(
      {super.key,
      required this.inputType,
      required this.onSubmit,
      this.initialVals,
      required this.inputComps,
      required this.inputVals,
      required this.typeData});

  factory DataAnalyserInput(
      {Key? key,
      required inputType,
      required onSubmit,
      initialVals,
      required typeData}) {
    Map<String, dynamic> inputComps = {};
    Map<String, dynamic> inputVals = {};
    if (inputType == "(x, y) pairs") {
      TextEditingController dataController = TextEditingController();
      if (initialVals != null) {
        dataController.text = initialVals["dataInput"];
      }
      String lblText = "";
      if (typeData == "bivariate") {
        lblText = "Enter (x, y points)";
      } else {
        lblText = "Enter values";
      }
      inputComps["dataInput"] = TextField(
          style: const TextStyle(fontSize: 17),
          controller: dataController,
          maxLines: 4,
          decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
              labelText: lblText));

      inputVals["dataInput"] = dataController;
    } else if (inputType == "x, y list inputs") {
      TextEditingController xController = TextEditingController();
      TextEditingController yController = TextEditingController();
      if (initialVals != null) {
        xController.text = initialVals["xInput"];
        yController.text = initialVals["yInput"];
      }
      inputComps["xInput"] = TextField(
          style: const TextStyle(fontSize: 17),
          controller: xController,
          maxLines: 3,
          decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
              labelText: "Enter x values"));
      String lblText = "";
      if (typeData == "univariate") {
        lblText = "Enter frequence values";
      } else {
        lblText = "Enter y values";
      }
      inputComps["yInput"] = TextField(
        style: const TextStyle(fontSize: 17),
        controller: yController,
        maxLines: 3,
        decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
            labelText: lblText),
      );
      inputVals["xInput"] = xController;
      inputVals["yInput"] = yController;
    }
    inputVals["dp"] = 2;
    TextEditingController delimiterController = TextEditingController();
    inputComps["delimiter"] = TextFormField(
      controller: delimiterController,
      decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
          labelText: "Delimiter"),
    );
    inputVals["delimiter"] = delimiterController;
    return DataAnalyserInput._(
        key: key,
        inputType: inputType,
        onSubmit: onSubmit,
        inputComps: inputComps,
        inputVals: inputVals,
        typeData: typeData);
  }

  Map<String, String> getInputVals() {
    Map<String, String> vals = {};
    inputVals.forEach((fieldName, controller) {
      if (fieldName == "dp") {
        vals["dp"] = controller.toString();
      } else {
        vals[fieldName] = controller.text;
      }
    });
    if (inputType == "table input") {
      List<int> xKeys = [];
      List<int> yKeys = [];
      List<dynamic> xVals = [];
      List<dynamic> yVals = [];
      for (int key in xTableInput.keys) {
        xKeys.add(key);
      }
      for (int key in yTableInput.keys) {
        yKeys.add(key);
      }
      xKeys.sort();
      yKeys.sort();
      for (int key in xKeys) {
        xVals.add(xTableInput[key]);
      }
      for (int key in yKeys) {
        yVals.add(yTableInput[key]);
      }
      vals["xVals"] = xVals.join(",");
      vals["yVals"] = yVals.join(",");
    }
    vals["typeData"] = typeData;
    return vals;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dataInputs = [];
    if (inputType == "(x, y) pairs") {
      dataInputs.add(inputComps["dataInput"]);
    } else if (inputType == "x, y list inputs") {
      dataInputs.add(inputComps["xInput"]);
      if (typeData == "bivariate") {
        dataInputs.add(inputComps["yInput"]);
      }
    }
    return ListView(children: [
      (() {
        if (inputType == "table input") {
          return DataFieldTable(
              key: Key(typeData), onChanged: onChanged, typeData: typeData);
        } else {
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 70.0 * inputComps.length,
              child: Column(children: dataInputs));
        }
      })(),
      const SizedBox(height: 20),
      SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            ...(() {
              if (inputType != "table input") {
                return [
                  const Spacer(flex: 1),
                  Expanded(flex: 2, child: inputComps["delimiter"])
                ];
              } else {
                return [const SizedBox()];
              }
            }()),
            const Spacer(flex: 1),
            Expanded(
                flex: 2,
                child: dpSelect(onDecimalSelect: (String newDp) {
                  inputVals["dp"] = newDp;
                })),
            const Spacer(flex: 1)
          ])),
      const SizedBox(height: 30),
      SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width / 3,
          child: TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigoAccent),
              onPressed: () => onSubmit(getInputVals()),
              child: const Text(style: TextStyle(fontSize: 18), "Submit")))
    ]);
  }
}
