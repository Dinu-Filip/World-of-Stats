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
  final List<SizedBox> inputComps;
  //
  // Maps name of input field to controller/value
  //
  final Map<String, dynamic> inputVals;
  //
  // onSubmit event handler from parent
  //
  final ValueChanged<Map<String, String>> onSubmit;
  final formKey = GlobalKey<FormState>();

  CalcInput._(
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
    List<SizedBox> inputComps = [];
    //
    // Creates input controllers and components
    //
    Map<String, dynamic> inputVals = {};
    fieldNames.forEach((inputName, fieldName) {
      TextEditingController inputController = TextEditingController();
      if (initialVals != null) {
        inputController.text != initialVals[inputName];
      }
      inputComps.add(SizedBox(
          width: 300,
          child: TextFormField(
              style: const TextStyle(fontSize: 20),
              controller: inputController,
              decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(width: 2, color: Colors.indigoAccent)),
                  labelText: fieldName))));
      inputVals[inputName] = inputController;
    });
    //
    // Sets default value for number of decimal places to round to
    //
    inputVals["dp"] = "2";
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
    submittedVals["dp"] = inputVals["dp"];
    return submittedVals;
  }

  void clearInputFields(List<String> fieldNames) {
    print("clearing");
    for (String inputName in fieldNames) {
      inputVals[inputName].text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: SizedBox(
            height: MediaQuery.of(context).size.height - 84,
            child: Column(children: [
              Expanded(
                  flex: 3,
                  child: Form(
                      key: formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: inputComps))),
              const SizedBox(height: 20),
              SizedBox(
                  width: 300,
                  height: 50,
                  child: dpSelect(
                      onDecimalSelect: (String newDp) =>
                          inputVals["dp"] = newDp)),
              const SizedBox(height: 50),
              SizedBox(
                  width: 300,
                  height: 40,
                  child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.indigoAccent),
                      onPressed: () => onSubmit(getInputVals()),
                      child: const Text(
                          style: TextStyle(fontSize: 18), "Submit"))),
              const Spacer(flex: 3)
            ])));
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
    return Wrap(children: [
      const Padding(
          padding: EdgeInsets.only(top: 8),
          child: SizedBox(
              width: 240,
              child: Text(style: TextStyle(fontSize: 20), "Decimal places:"))),
      SizedBox(
          width: 60,
          child: DropdownButton(
              itemHeight: 50,
              value: dpValue,
              icon: const Icon(Icons.arrow_downward),
              onChanged: (String? value) {
                setState(() {
                  dpValue = value!;
                  widget.onDecimalSelect(value);
                });
              },
              items: dpOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(style: const TextStyle(fontSize: 20), value));
              }).toList()))
    ]);
  }
}
