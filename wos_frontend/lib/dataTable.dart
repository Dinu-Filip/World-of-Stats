import 'package:flutter/material.dart';

class DataTable extends StatefulWidget {
  final ValueChanged<List<dynamic>> onChanged;
  final List<List<int>>? fieldsErase;

  const DataTable({super.key, required this.onChanged, this.fieldsErase});

  @override
  State<DataTable> createState() => DataTableState();
}

class DataTableState extends State<DataTable> {
  int numRows = 10;
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
    if (xControllers.length < numRows) {
      for (int i = 0; i < numRows - xControllers.length; i++) {
        xControllers.add(TextEditingController());
        freqControllers.add(TextEditingController());
        rows.add(TableRow(children: [
          TextField(
              controller: xControllers[-1],
              onChanged: (text) => onFieldChanged(i, 0)),
          TextField(
              controller: freqControllers[-1],
              onChanged: (text) => onFieldChanged(i, 1))
        ]));
      }
    } else {
      for (int i = 0; i < numRows - xControllers.length; i++) {
        xControllers.removeLast();
        freqControllers.removeLast();
        rows.removeLast();
      }
    }
    if (widget.fieldsErase != null) {
      for (List<int> field in widget.fieldsErase!) {
        if (field[0] == 0) {
          xControllers[field[1]].text = "";
        } else {
          freqControllers[field[1]].text = "";
        }
      }
    }
    return Column(
      children: [
        TextButton(onPressed: addRow, child: const Text("Add row")),
        TextButton(onPressed: removeRow, child: const Text("Remove row")),
        Table(
          children: [
            const TableRow(children: [Text("x"), Text("Frequency")]),
            ...rows
          ],
        )
      ],
    );
  }
}
