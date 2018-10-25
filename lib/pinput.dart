library pinput;

import 'package:flutter/material.dart';

class PinPut extends StatefulWidget {
  final Function onSubmit;
  final int fieldsCount;
  final bool isTextObscure;
  final double fontSize;
  final double borderRadius;
  final TextInputType keybaordType;
  final TextInputAction keyboardAction;

  PinPut(
      {this.onSubmit,
      this.fieldsCount = 4,
      this.isTextObscure = false,
      this.fontSize = 40.0,
      this.borderRadius = 5.0,
      this.keybaordType = TextInputType.number,
      this.keyboardAction = TextInputAction.next})
      : assert(fieldsCount > 0 && borderRadius > 0);

  @override
  State<StatefulWidget> createState() => PinPutState();
}

class PinPutState extends State<PinPut> {
  List<String> _pin;
  List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fieldsCount);
    _nodes = List<FocusNode>(widget.fieldsCount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: generateTextFields(context),
    );
  }

  @override
  void dispose() {
    _nodes.forEach((FocusNode f) => f.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fieldsCount, (int i) {
      return _buildTextField(i, context);
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields);
  }

  Widget _buildTextField(int i, BuildContext context) {
    _nodes[i] = FocusNode();

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          keyboardType: widget.keybaordType,
          textAlign: TextAlign.center,
          maxLength: 1,
          obscureText: widget.isTextObscure,
          textInputAction: widget.keyboardAction,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          focusNode: _nodes[i],
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5.0),
              counterStyle: TextStyle(fontSize: 0.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius))),
          onChanged: (String s) {
            _pin[i] = s;
            _focus(s, i);
          },
        ),
      ),
    );
  }

  void _focus(String s, int i) {
    if (s.isNotEmpty) {
      if ((i + 1) != widget.fieldsCount)
        FocusScope.of(context).requestFocus(_nodes[i + 1]);
      else {
        _nodes[i].unfocus();
        widget.onSubmit(_pin.join());
      }
    } else {
      if (i > 0) FocusScope.of(context).requestFocus(_nodes[i - 1]);
    }
  }
}
