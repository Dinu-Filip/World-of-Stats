import 'package:flutter/material.dart';

class CalcInput extends StatelessWidget {
  //
  // Maps the name of the input field to its label
  //
  final Map<String, String> fieldNames;
  //
  // Initial values if from history component
  //
  final Map<String, String>? initialVals;
  //
  // List of input fields with labels
  //
  final List<Column> inputComps;
  //
  // Maps name of input field to controller/value
  //
  final Map<String, dynamic> inputVals;
  //
  // onSubmit event handler from parent
  //
  final ValueChanged<Map<String, String>> onSubmit;

  const CalcInput._(
      {super.key,
      required this.fieldNames,
      this.initialVals,
      required this.inputComps,
      required this.inputVals,
      required this.onSubmit});

  factory CalcInput(
      {Key? key,
      required Map<String, String> fieldNames,
      Map<String, String>? initialVals,
      required ValueChanged<Map<String, String>> onSubmit}) {
    List<Column> inputComps = [];
    //
    // Creates input controllers and components
    //
    Map<String, dynamic> inputVals = {};
    fieldNames.forEach((inputName, fieldName) {
      TextEditingController inputController = TextEditingController();
      if (initialVals != null) {
        inputController.text != initialVals[inputName];
      }
      inputComps.add(Column(
          children: [Text(fieldName), TextField(controller: inputController)]));
      inputVals[inputName] = inputController;
    });
    //
    // Sets default value for number of decimal places to round to
    //
    inputVals["dpVal"] = "2";
    return CalcInput._(
        key: key,
        fieldNames: fieldNames,
        initialVals: initialVals,
        inputComps: inputComps,
        inputVals: inputVals,
        onSubmit: onSubmit);
  }

  Map<String, String> getInputVals() {
    //
    // Gets all values inputted by users on submit
    //
    final Map<String, String> submittedVals = {};
    for (String inputName in fieldNames.keys.toList()) {
      submittedVals[inputName] = inputVals[inputName].text;
    }
    submittedVals["dpVal"] = inputVals["dpVal"];
    return submittedVals;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ...inputComps,
      dpSelect(onDecimalSelect: (String newDp) => inputVals["dpVal"] = newDp),
      TextButton(
          onPressed: () => onSubmit(getInputVals()),
          child: const Text("Submit"))
    ]);
  }
}

class dpSelect extends StatefulWidget {
  final ValueChanged<String> onDecimalSelect;

  const dpSelect({super.key, required this.onDecimalSelect});

  @override
  State<dpSelect> createState() => dpSelectState();
}

class dpSelectState extends State<dpSelect> {
  String dpValue = "2";
  //
  // Number of decimal places ranges from 0 to 8 inclusive
  //
  final List<String> dpOptions = [for (int i = 0; i <= 8; i++) '$i'];

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: dpValue,
        icon: const Icon(Icons.arrow_downward),
        onChanged: (String? value) {
          setState(() {
            dpValue = value!;
            widget.onDecimalSelect(value);
          });
        },
        items: dpOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList());
  }
}
