import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class PinPutBloc {
  final BuildContext context;
  final int fieldsCount;
  final Function onSubmit;
  List<String> _pin;
  List<FocusNode> nodes;
  List<TextEditingController> textCtrls;
  String _clp;
  ActionButtonState _actionButtonState = ActionButtonState.delete;

  final _onchangeSinkCtrl = StreamController<FieldModel>();

  final _buttonStateStreamCtrl = StreamController<ActionButtonState>();

  Sink<FieldModel> get onTextChange => _onchangeSinkCtrl.sink;

  Stream<ActionButtonState> get buttonState => _buttonStateStreamCtrl.stream;

  PinPutBloc({this.context, this.fieldsCount, this.onSubmit}) {
    _init();
  }

  void _init() {
    _pin = List<String>(fieldsCount);
    nodes = List.generate(fieldsCount, (int i) => FocusNode());
    textCtrls =
        List.generate(fieldsCount, (int i) => TextEditingController(text: ''));
    _onchangeSinkCtrl.stream
        .distinct()
        .listen((FieldModel m) => _onTextChanged(m));
    _checkClipboard();
  }

  void dispose() {
    nodes.forEach((FocusNode f) => f.dispose());
    textCtrls.forEach((TextEditingController t) => t.dispose());
    _onchangeSinkCtrl.close();
    _buttonStateStreamCtrl.close();
  }

  void _onTextChanged(FieldModel m) {
    _setButtonState();
    _pin[m.index] = m.text;
    _focusNext(m.text, m.index);
  }

  void _checkClipboard() {
    Clipboard.getData('text/plain').then((ClipboardData cl) {
      _clp = cl.text;
      _setButtonState();
    });
  }

  void _focusNext(String s, int i) {
    if (s.isNotEmpty) {
      if (i + 1 == fieldsCount) {
        _submit();
      } else
        FocusScope.of(context).requestFocus(nodes[i + 1]);
    } else {
      if (i > 0) FocusScope.of(context).requestFocus(nodes[i - 1]);
    }
  }

  void _submit() {
    for (int i = 0; i < fieldsCount; ++i) {
      if (_pin[i].isEmpty) {
        FocusScope.of(context).requestFocus(nodes[i]);
        return;
      }
      if (nodes[i].hasFocus) nodes[i].unfocus();
    }
    String pin = _pin.join();
    onSubmit(pin);
  }

  void _setButtonState() {
    print(_isFilled());
    ActionButtonState a = ActionButtonState.paste;
    if (_clp == null || _clp.length != fieldsCount || _isFilled())
      a = ActionButtonState.delete;
    if (_actionButtonState != a) {
      _actionButtonState = a;
      _buttonStateStreamCtrl.add(_actionButtonState);
    }
  }

  void _copyFromClipboard(BuildContext context) {
    if (_clp.length == fieldsCount) {
      for (int i = 0; i < fieldsCount; i++) {
        _pin[i] = _clp[i];
        textCtrls[i].text = _clp[i];
      }
      _submit();
      _setButtonState();
    }
  }

  void onAction() {
    if (_actionButtonState == ActionButtonState.paste) {
      _copyFromClipboard(context);
    } else {
      for (int i = 0; i < fieldsCount; ++i) {
        textCtrls[i].clear();
        _pin[i] = '';
        _setButtonState();
      }
      FocusScope.of(context).requestFocus(nodes[0]);
    }
  }

  void unFocusAll() => nodes.forEach((n) {
        if (n.hasFocus) n.unfocus();
      });

  void focusFirst() => FocusScope.of(context).requestFocus(nodes[0]);

  bool _isFilled() => _pin.join().length == fieldsCount;
}

class FieldModel {
  final int index;
  final String text;

  FieldModel({this.index, this.text});
}

enum ActionButtonState {
  delete,
  paste,
}
