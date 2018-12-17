import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put_bloc.dart';
import './pin_put.dart';

abstract class PinPutViewModel extends State<PinPut> {
  List<String> _pin;
  List<FocusNode> _nodes;
  List<TextEditingController> _textCtrls;
  final PinPutBloc bloc = PinPutBloc();
  String clp;

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fieldsCount);
    _nodes = List<FocusNode>(widget.fieldsCount);
    _textCtrls = List<TextEditingController>(widget.fieldsCount);
    _checkClipboard();
  }

  @override
  void dispose() {
    _nodes.forEach((FocusNode f) => f.dispose());
    bloc.dispose();
    super.dispose();
  }

  Widget buildTextField(int i, BuildContext context) {
    _nodes[i] = FocusNode();
    _textCtrls[i] = TextEditingController(text: '');
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
                  borderRadius: BorderRadius.circular(widget.borderRadius))),
          onChanged: (String s) {
            _pin[i] = s;
            _onActionChange();
            _focusNext(context, s, i);
          },
        ),
      ),
    );
  }

  void _focusNext(BuildContext context, String s, int i) {
    if (s.isNotEmpty) {
      if (i + 1 == widget.fieldsCount) {
        _submit();
      } else
        FocusScope.of(context).requestFocus(_nodes[i + 1]);
    } else {
      if (i > 0) FocusScope.of(context).requestFocus(_nodes[i - 1]);
    }
  }

  void _onActionChange() {
    if (_isClear())
      _checkClipboard();
    else
      bloc.onActionChange.add(false);
  }

  bool _isClear() {
    for (int i = 0; i < widget.fieldsCount; ++i)
      if (_pin[i].isNotEmpty) return false;
    return true;
  }

  void _checkClipboard() {
    Clipboard.getData('text/plain').then((ClipboardData cl) {
      if (cl == null || cl.text.length != widget.fieldsCount) {
        bloc.onActionChange.add(false);
      } else {
        clp = cl.text;
        bloc.onActionChange.add(true);
      }
    });
  }

  void _copyFromClipboard(BuildContext context) {
    if (clp.length == widget.fieldsCount) {
      for (int i = 0; i < widget.fieldsCount; i++) {
        _pin[i] = clp[i];
        _textCtrls[i].text = clp[i];
      }
      _submit();
    }
  }

  void onAction(BuildContext context, bool paste) {
    if (paste) {
      _copyFromClipboard(context);
    } else {
      for (int i = 0; i < widget.fieldsCount; ++i) {
        _textCtrls[i].clear();
        _pin[i] = '';
      }
      FocusScope.of(context).requestFocus(_nodes[0]);
    }
    _onActionChange();
  }

  void _submit() {
    for (int i = 0; i < widget.fieldsCount; ++i) {
      if (_pin[i].isEmpty) {
        FocusScope.of(context).requestFocus(_nodes[i]);
        return;
      }
      if (_nodes[i].hasFocus) _nodes[i].unfocus();
    }
    String pin = _pin.join();
    widget.onSubmit(pin);
  }
}
