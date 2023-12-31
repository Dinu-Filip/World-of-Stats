import 'package:latext/latext.dart';
import 'package:flutter/material.dart';
import 'dart:io';

const Map<String, String> theoryFiles = {
  "Distributional parameters": "hypothesis_tests",
  "Binomial": "Binomial",
  "Normal": "Normal",
  "Chi-squared": "Chi-squared",
  "Goodness of fit": "goodness_of_fit"
};

class TheoryView extends StatelessWidget {
  final String title;
  final String toolName;

  const TheoryView({super.key, required this.title, required this.toolName});

  @override
  Widget build(BuildContext context) {
    String theory =
        File("theory/${theoryFiles[toolName]}.txt").readAsStringSync();
    return Column(children: [
      const SizedBox(height: 10),
      SizedBox(
          width: MediaQuery.of(context).size.width / 5,
          height: 37,
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Text("Back <",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 60, 79, 184)))))),
      Container(
          margin: const EdgeInsets.only(top: 5, bottom: 20),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.w500))),
      Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  margin: const EdgeInsets.only(
                      top: 5, left: 25, right: 25, bottom: 20),
                  child: LaTexT(
                      laTeXCode:
                          Text(theory, style: const TextStyle(fontSize: 23))))))
    ]);
  }
}
