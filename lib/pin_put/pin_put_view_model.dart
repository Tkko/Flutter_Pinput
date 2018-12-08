import 'package:flutter/material.dart';
import './pin_put.dart';

abstract class PinPutViewModel extends State<PinPut> {
  List<String> _pin;
  List<FocusNode> _nodes;
  List<TextEditingController> _textCtrls;

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fieldsCount);
    _nodes = List<FocusNode>(widget.fieldsCount);
    _textCtrls = List<TextEditingController>(widget.fieldsCount);
  }

  @override
  void dispose() {
    _nodes.forEach((FocusNode f) => f.dispose());
    super.dispose();
  }

  Widget buildTextField(int i, BuildContext context) {
    _nodes[i] = FocusNode();
    _textCtrls[i] = TextEditingController(text: '');
    //if(i == 0) FocusScope.of(context).requestFocus(_nodes[0]); 
    if (widget.collapsed) {
      return Expanded(
        child: Container (
          // padding: EdgeInsets.only(top: 8.0),
          margin: EdgeInsets.only(top: 8.0),
          child: TextField(
            keyboardType: widget.keybaordType,
            textAlign: TextAlign.center,
            autofocus: i == 0 && widget.autoFocus,
            maxLength: 1,
            controller: _textCtrls[i],
            obscureText: widget.isTextObscure,
            textInputAction: widget.keyboardAction,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              // color: Colors.black,
              color: widget.color,
            ),
            focusNode: _nodes[i],
            decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(widget.contentPadding),
                counterStyle: TextStyle(fontSize: 0.0),
                border: InputBorder.none,
                hintText: widget.hintText,
            ),
            onChanged: (String s) {
              _pin[i] = s;
              _focusNext(context, s, i);
            },
          ),
        ),
      );

    }
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: TextField(
          keyboardType: widget.keybaordType,
          textAlign: TextAlign.center,
          autofocus: i == 0 && widget.autoFocus,
          maxLength: 1,
          controller: _textCtrls[i],
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
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
          ),
          onChanged: (String s) {
            _pin[i] = s;
            _focusNext(context, s, i);
          },
        ),
      ),
    );
  }

  void _focusNext(BuildContext context, String s, int i) {
    if (s.isNotEmpty) {
      if (i + 1 == widget.fieldsCount) {
        _nodes[i].unfocus();
        String pin = _pin.join();
        if (pin.length == widget.fieldsCount) widget.onSubmit(pin);
      } else
        FocusScope.of(context).requestFocus(_nodes[i + 1]);
    } else {
      if (i > 0) FocusScope.of(context).requestFocus(_nodes[i - 1]);
    }
  }

  void clearWidget(BuildContext context) {
    for (int i = 0; i < widget.fieldsCount; ++i) {
      _textCtrls[i].clear();
      _pin[i] = '';
    }
    FocusScope.of(context).requestFocus(_nodes[0]);
  }
}
