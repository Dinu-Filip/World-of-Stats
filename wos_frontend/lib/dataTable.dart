import 'package:flutter/material.dart';

class DataFieldTable extends StatefulWidget {
  final ValueChanged<List<dynamic>> onChanged;
  final List<List<int>>? fieldsErase;
  final String typeData;

  const DataFieldTable(
      {super.key,
      required this.onChanged,
      this.fieldsErase,
      required this.typeData});

  @override
  State<DataFieldTable> createState() => DataFieldTableState();
}

class DataFieldTableState extends State<DataFieldTable> {
  int numRows = 5;
  List<TextEditingController> xControllers = [];
  List<TextEditingController> freqControllers = [];
  List<TableRow> rows = [];

  void addRow() {
    if (numRows < 30) {
      setState(() {
        numRows += 1;
      });
    }
  }

  void removeRow() {
    if (numRows > 5) {
      setState(() {
        numRows -= 1;
      });
    }
  }

  void onFieldChanged(int row, int column) {
    if (column == 0) {
      widget.onChanged([
        [row, column],
        xControllers[row].text
      ]);
    } else {
      widget.onChanged([
        [row, column],
        freqControllers[row].text
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (xControllers.length <= numRows) {
      int currentRowNum = xControllers.length;
      for (int i = 0; i < numRows - currentRowNum; i++) {
        xControllers.add(TextEditingController());
        freqControllers.add(TextEditingController());
        rows.add(TableRow(children: [
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 15),
              child: SizedBox(
                  height: 40,
                  child: TextField(
                      controller: xControllers.last,
                      onChanged: (text) => onFieldChanged(i, 0)))),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 20),
              child: SizedBox(
                  height: 40,
                  child: TextField(
                      controller: freqControllers.last,
                      onChanged: (text) => onFieldChanged(i, 1))))
        ]));
      }
    } else {
      for (int i = 0; i < xControllers.length - numRows; i++) {
        xControllers.removeLast();
        freqControllers.removeLast();
        rows.removeLast();
      }
    }
    if (widget.fieldsErase != null) {
      for (List<int> field in widget.fieldsErase!) {
        if (field[1] == 0) {
          xControllers[field[0]].text = "";
        } else {
          freqControllers[field[0]].text = "";
        }
      }
    }
    String dataLbl = "";
    if (widget.typeData == "univariate") {
      dataLbl = "Frequency";
    } else {
      dataLbl = "y";
    }
    return Column(
      children: [
        Row(children: [
          const Spacer(flex: 1),
          Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: addRow,
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.indigoAccent)),
                child: const Text(
                  "Add row",
                  style: TextStyle(color: Colors.indigoAccent),
                ),
              )),
          const Spacer(flex: 1),
          Expanded(
              flex: 2,
              child: TextButton(
                onPressed: removeRow,
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.indigoAccent)),
                child: const Text("Remove row",
                    style: TextStyle(color: Colors.indigoAccent)),
              )),
          const Spacer(flex: 1)
        ]),
        const SizedBox(height: 20),
        Table(
          children: [
            TableRow(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Color.fromARGB(255, 129, 129, 129),
                            width: 1))),
                children: [
                  const Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Text("x", style: TextStyle(fontSize: 16)))
                      ])),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text(dataLbl,
                                style: const TextStyle(fontSize: 16)))
                      ]))
                ]),
            ...rows,
          ],
        )
      ],
    );
  }
}
