import 'package:flutter/material.dart';

class OptionSelect extends StatefulWidget {
  final ValueChanged<String> changeOption;
  final List<String> options;
  final String label;

  const OptionSelect(
      {super.key,
      required this.changeOption,
      required this.options,
      required this.label});

  @override
  State<OptionSelect> createState() => OptionSelectState();
}

class OptionSelectState extends State<OptionSelect> {
  late String currentOption = widget.options[0];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(widget.label, style: const TextStyle(fontSize: 20)),
      DropdownButton(
          underline: Container(height: 2, color: Colors.indigoAccent),
          value: currentOption,
          items: widget.options.map((String value) {
            return DropdownMenuItem(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 18)));
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              currentOption = value!;
              widget.changeOption(value);
            });
          })
    ]);
  }
}
