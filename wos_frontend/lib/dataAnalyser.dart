import 'dart:convert';
import 'package:wos_frontend/calcOutput.dart';
import 'package:wos_frontend/graphs.dart';
import 'package:flutter/material.dart';
import 'package:wos_frontend/calcInput.dart';
import 'package:wos_frontend/validation.dart';
import 'package:http/http.dart' as http;

class DataAnalyser extends StatefulWidget {
  final Map<String, String>? initialVals;
  const DataAnalyser({super.key, this.initialVals});

  @override
  State<DataAnalyser> createState() => DataAnalyserState();
}

class DataAnalyserState extends State<DataAnalyser> {
  final List<String> inputTypes = ["(x, y) pairs", "x, y list inputs"];
  String currentInputType = "(x, y) pairs";
  dynamic graph;
  GridView? resultFields;
  CalcOutput? outputSection;
  late DataAnalyserInput inputSection =
      DataAnalyserInput(inputType: currentInputType, onSubmit: onSubmit);

  void switchType(String newType) {
    setState(() {
      currentInputType = newType;
      inputSection = DataAnalyserInput(inputType: newType, onSubmit: onSubmit);
      graph = null;
      resultFields = null;
      outputSection = null;
    });
  }

  Future<Map<String, dynamic>> calculateResult(
      Map<String, dynamic> submittedVals) async {
    String baseIP = "127.0.0.1:8000";
    String path = "/bivariate/";
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
    print(submittedVals);
    Map<String, dynamic> validateResult = Validation.bivariate(submittedVals);
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
      } else {
        xVals = submittedVals["xInput"]!.split(submittedVals["delimiter"]!);
        yVals = submittedVals["yInput"]!.split(submittedVals["delimiter"]!);
      }
      response = await calculateResult(
          {"xVals": xVals, "yVals": yVals, "dp": submittedVals["dp"]});
    }
    setState(() {
      if (validateResult["res"]) {
        updateGraph(response["regress_slope"]["res"],
            response["regress_intercept"]["res"], xVals, yVals);
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
    List<Expanded> tabs = [];
    inputTypes.forEach((element) {
      tabs.add(Expanded(
          flex: 1,
          child: SizedBox(
              height: 40,
              child: TextButton(
                  style: (() {
                    if (currentInputType != element) {
                      return TextButton.styleFrom(
                          foregroundColor: Colors.indigoAccent,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero)));
                    } else {
                      return TextButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero)));
                    }
                  }()),
                  onPressed: () => switchType(element),
                  child:
                      Text(style: const TextStyle(fontSize: 17), element)))));
    });
    return Column(children: [
      SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: Row(children: tabs)),
      Row(children: [
        Expanded(
            flex: 1,
            child: SizedBox(
                height: 415,
                child: Container(
                    margin: const EdgeInsets.all(15), child: inputSection))),
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
    ]);
  }
}

class DataAnalyserInput extends StatelessWidget {
  final String inputType;
  final ValueChanged<Map<String, String>> onSubmit;
  final Map<String, String>? initialVals;
  final Map<String, dynamic> inputComps;
  final Map<String, dynamic> inputVals;

  const DataAnalyserInput._(
      {super.key,
      required this.inputType,
      required this.onSubmit,
      this.initialVals,
      required this.inputComps,
      required this.inputVals});

  factory DataAnalyserInput(
      {Key? key, required inputType, required onSubmit, initialVals}) {
    Map<String, dynamic> inputComps = {};
    Map<String, dynamic> inputVals = {};
    if (inputType == "(x, y) pairs") {
      TextEditingController dataController = TextEditingController();
      if (initialVals != null) {
        dataController.text = initialVals["dataInput"];
      }
      inputComps["dataInput"] = TextField(
          style: const TextStyle(fontSize: 17),
          controller: dataController,
          maxLines: 4,
          decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
              labelText: "Enter (x, y) points"));
      inputVals["dataInput"] = dataController;
    } else {
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
      inputComps["yInput"] = TextField(
        style: const TextStyle(fontSize: 17),
        controller: yController,
        maxLines: 3,
        decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.indigoAccent)),
            labelText: "Enter y values"),
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
        inputVals: inputVals);
  }

  Map<String, String> getInputVals() {
    Map<String, String> vals = {};
    inputVals.forEach((fieldName, controller) {
      print(fieldName);
      if (fieldName == "dp") {
        vals["dp"] = controller.toString();
      } else {
        vals[fieldName] = controller.text;
      }
    });
    return vals;
  }

  @override
  Widget build(BuildContext context) {
    List<TextField> dataInputs = [];
    if (inputType == "(x, y) pairs") {
      dataInputs.add(inputComps["dataInput"]);
    } else {
      dataInputs.add(inputComps["xInput"]);
      dataInputs.add(inputComps["yInput"]);
    }
    return Column(children: [
      SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 70.0 * inputComps.length,
          child: Column(children: dataInputs)),
      const SizedBox(height: 20),
      SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            const Spacer(flex: 1),
            Expanded(flex: 2, child: inputComps["delimiter"]),
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
