import 'package:flutter/material.dart';
import 'package:latext/latext.dart';

class CalcOutput extends StatelessWidget {
  final Map<String, String> outputInfo;

  const CalcOutput({super.key, required this.outputInfo});

  List<OutputField> createOutputFields() {
    List<OutputField> outputComps = [];
    outputInfo.forEach((String heading, String content) {
      outputComps.add(
          OutputField(key: Key(content), heading: heading, content: content));
    });
    return outputComps;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: createOutputFields());
  }
}

class OutputField extends StatefulWidget {
  final String heading;
  final String content;

  const OutputField({super.key, required this.heading, required this.content});

  @override
  State<OutputField> createState() => OutputFieldState();
}

class OutputFieldState extends State<OutputField> {
  bool show = false;
  late LaTexT content = LaTexT(
      laTeXCode: Text(style: const TextStyle(fontSize: 18), widget.content));

  void toggleContent() {
    setState(() {
      show = !show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: TextButton(
              onPressed: toggleContent,
              child: LaTexT(
                  laTeXCode: Text(
                      style: const TextStyle(
                          fontSize: 18, color: Colors.indigoAccent),
                      "${widget.heading}  ${show ? "-" : "+"}")))),
      (() {
        if (show) {
          return Padding(
              padding: const EdgeInsets.only(left: 30, bottom: 20),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width, child: content));
        }
        return const Text("");
      }())
    ]);
  }
}
