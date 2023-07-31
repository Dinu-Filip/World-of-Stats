import 'package:flutter/material.dart';

class CalcOutput extends StatelessWidget {
  final Map<String, String> outputInfo;

  const CalcOutput({super.key, required this.outputInfo});

  List<OutputField> createOutputFields() {
    List<OutputField> outputComps = [];
    outputInfo.forEach((String heading, String content) {
      outputComps.add(OutputField(heading: heading, content: content));
    });

    return outputComps;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: createOutputFields());
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

  void toggleContent() {
    setState(() {
      show = !show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextButton(
          onPressed: toggleContent,
          child: Text("${widget.heading}  ${show ? "-" : "+"}")),
      Text(widget.content)
    ]);
  }
}
