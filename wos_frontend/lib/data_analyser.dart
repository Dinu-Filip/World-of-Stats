import 'dart:convert';
import 'package:wos_frontend/calc_output.dart';
import 'package:wos_frontend/graphs.dart';
import 'package:flutter/material.dart';
import 'package:wos_frontend/calc_input.dart';
import 'package:wos_frontend/validation.dart';
import 'package:wos_frontend/data_table.dart';
import 'package:http/http.dart' as http;

class DataAnalyser extends StatefulWidget {
  final Map<String, String>? initialVals;
  const DataAnalyser({super.key, this.initialVals});

  @override
  State<DataAnalyser> createState() => DataAnalyserState();
}

class DataAnalyserState extends State<DataAnalyser> {
  //
  // Describes the three different form of input
  //
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
    if (currentInputType != newType) {
      setState(() {
        currentInputType = newType;
        inputSection = DataAnalyserInput(
            inputType: newType, onSubmit: onSubmit, typeData: typeData);
        //
        // Re-initialises results section when the form of the input changes
        //
        graph = null;
        resultFields = null;
        outputSection = null;
      });
    }
  }

  void setTypeData(String newDataType) {
    if (newDataType != typeData) {
      setState(() {
        typeData = newDataType;
        //
        // Reinitialises results section when switching between univariate and bivariate
        //
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
  }

  void updateOutputs(Map<String, dynamic> results) {
    Map<String, String> resultsContent = {};
    List<Column> resultGridItems = [];

    for (String heading in results.keys.toList()) {
      //
      // Adds entry to output section only if a method is provided
      //
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
        childAspectRatio: (3 / 1),
        children: resultGridItems);
  }

  void onSubmit(submittedVals) async {
    late final Map<String, dynamic> response;
    List<String> xVals = [];
    List<String> yVals = [];
    //
    // Formats data as needed by data analysis function in backend
    //
    if (currentInputType == "(x, y) pairs") {
      //
      // First separates pairs using the delimiter and then separates the
      // number in each pair
      //
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
      //
      // Only one set of data passed to backend for univariate data
      //
      xVals = submittedVals["xInput"]!.split(submittedVals["delimiter"]!);
      yVals = [];
    } else {
      xVals = submittedVals["xVals"]!.split(",");
      yVals = submittedVals["yVals"]!.split(",");
    }

    Map<String, dynamic> validateResult = Validation.dataAnalysis({
      "xVals": xVals,
      "yVals": yVals,
      "dp": submittedVals["dp"],
      "inputType": currentInputType,
      "typeData": typeData,
      "delimiter": submittedVals["delimiter"]
    });

    if (validateResult["res"]) {
      response = await calculateResult({
        "xVals": xVals,
        "yVals": yVals,
        "dp": submittedVals["dp"],
        "inputType": currentInputType,
        "typeData": typeData
      });
    }

    setState(() {
      if (validateResult["res"]) {
        if (typeData == "bivariate") {
          //
          // Line graph only generated for bivariate data
          //
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
    return Column(children: [
      const Padding(
          padding: EdgeInsets.all(5),
          child: SizedBox(
            height: 50,
            child: Text("Data analysis",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
          )),
      Expanded(
          child: Row(children: [
        Expanded(
            flex: 2,
            child: Column(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Select input type",
                      style: TextStyle(fontSize: 20)),
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
                                              const TextStyle(fontSize: 18))))
                              .toList(),
                          onChanged: (value) => switchTypeInput(value!)))
                ]),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                    height: 50,
                    width: 200,
                    child: ListTile(
                        title: const Text("Univariate",
                            style: TextStyle(fontSize: 20)),
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
                        title: const Text("Bivariate",
                            style: TextStyle(fontSize: 20)),
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
            flex: 3,
            child: (() {
              if (resultFields == null &&
                  graph == null &&
                  outputSection == null) {
                return SizedBox(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold),
                            "Enter the parameters of the distribution and click 'Submit' to generate the result")));
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 72.5),
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 270,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: resultFields)),
                      (() {
                        if (graph != null) {
                          return Expanded(
                              flex: 1,
                              child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 600),
                                  margin: const EdgeInsets.all(15),
                                  child: graph));
                        } else {
                          return const SizedBox(width: 0, height: 0);
                        }
                      }()),
                      Expanded(
                          flex: 1,
                          child: Container(
                              margin: const EdgeInsets.all(15),
                              child: outputSection!))
                    ]);
              }
            }()))
      ]))
    ]);
  }
}

class DataAnalyserInput extends StatelessWidget {
  final String inputType;
  final ValueChanged<Map<String, String>> onSubmit;
  final Map<String, String>? initialVals;
  final Map<String, dynamic> inputComps = {};
  final Map<String, dynamic> inputVals = {};
  final String typeData;
  final Map<int, dynamic> xTableInput = {};
  final Map<int, dynamic> yTableInput = {};

  void onChanged(List<dynamic> params) {
    //
    // Dynamically updates map holding values entered into the table input
    //
    if (params[0][1] == 0) {
      xTableInput[params[0][0]] = params[1];
    } else {
      yTableInput[params[0][0]] = params[1];
    }
  }

  void initPairInputs() {
    TextEditingController dataController = TextEditingController();
    //
    // Initialises input with values from history component
    //
    if (initialVals != null) {
      dataController.text = initialVals!["dataInput"]!;
    }
    //
    // Modifies label depending on bivariate or univariate data
    //
    String lblText = "";
    if (typeData == "bivariate") {
      lblText = "Enter (x, y points)";
    } else {
      lblText = "Enter values";
    }
    inputComps["dataInput"] = TextField(
        style: const TextStyle(fontSize: 18),
        controller: dataController,
        maxLines: 4,
        decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
            labelText: lblText));

    inputVals["dataInput"] = dataController;
  }

  void initListInputs() {
    TextEditingController xController = TextEditingController();
    TextEditingController yController = TextEditingController();
    //
    // Initialises list inputs with values from history component
    //
    if (initialVals != null) {
      xController.text = initialVals!["xInput"]!;
      yController.text = initialVals!["yInput"]!;
    }
    inputComps["xInput"] = TextField(
        style: const TextStyle(fontSize: 20),
        controller: xController,
        maxLines: 3,
        decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
            labelText: "Enter x values"));
    //
    // Modifies label depending on univariate or bivariate data
    //
    String lblText = "";
    if (typeData == "univariate") {
      lblText = "Enter frequency values";
    } else {
      lblText = "Enter y values";
    }
    inputComps["yInput"] = TextField(
      style: const TextStyle(fontSize: 20),
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

  void initAuxInputs() {
    //
    // Sets default rounding to 2 dp
    //
    inputVals["dp"] = 2;
    TextEditingController delimiterController = TextEditingController();
    inputComps["delimiter"] = TextFormField(
      style: const TextStyle(fontSize: 20),
      controller: delimiterController,
      decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
          labelText: "Delimiter"),
    );
    inputVals["delimiter"] = delimiterController;
  }

  DataAnalyserInput(
      {super.key,
      required this.inputType,
      required this.onSubmit,
      this.initialVals,
      required this.typeData}) {
    if (inputType == "(x, y) pairs") {
      initPairInputs();
    } else if (inputType == "x, y list inputs") {
      initListInputs();
    }
    initAuxInputs();
  }

  Map<String, String> getTableVals() {
    Map<String, String> vals = {};
    //
    // Hold values from left and right columns
    //
    List<int> xKeys = [];
    List<int> yKeys = [];
    List<dynamic> xVals = [];
    List<dynamic> yVals = [];
    for (int key in xTableInput.keys) {
      if (xTableInput[key] != null && yTableInput[key] != null) {
        xKeys.add(key);
        yKeys.add(key);
      }
    }
    //
    // Sorts pairs from columns to make calculation in backend easier
    //
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
    return vals;
  }

  Map<String, String> getInputVals() {
    //
    // Retrieves values from components
    //
    Map<String, String> vals = {};
    inputVals.forEach((fieldName, controller) {
      if (fieldName == "dp") {
        vals["dp"] = controller.toString();
      } else {
        vals[fieldName] = controller.text;
      }
    });
    if (inputType == "table input") {
      vals.addAll(getTableVals());
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
      //
      // Univariate data should have only one list for inputs
      //
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
              height: 78.0 * inputComps.length,
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
                child: DpSelect(onDecimalSelect: (String newDp) {
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
