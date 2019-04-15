import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_bloc.dart';

class PinPutState extends State<PinPut> {
  PinPutBloc _bloc;
  Widget _actionButton;

  @override
  void initState() {
    _bloc = _bloc ??
        PinPutBloc(
            context: context,
            fieldsCount: widget.fieldsCount,
            onSubmit: (String p) => widget.onSubmit(p));
    _actionButton = _buildActionButton();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinPut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clearInput != oldWidget.clearInput &&
        widget.clearInput == true) {
      _bloc.onAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.unFocusWhen) _bloc.unFocusAll();
    return Container(
      color: Colors.transparent,
      child: _generateTextFields(context),
    );
  }

  Widget _generateTextFields(BuildContext context) {
    List<Widget> fields = List();
    for (int i = 0; i < widget.fieldsCount; ++i) {
      fields.add(_buildTextField(i, context));
      if (i < widget.fieldsCount - 1)
        fields.add(VerticalDivider(
            width: widget.spaceBetween, color: Colors.transparent));
    }
    if (widget.actionButtonsEnabled) fields.add(_actionButton);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: fields);
  }

  Widget _buildActionButton() {
    return StreamBuilder<ActionButtonState>(
        stream: _bloc.buttonState,
        initialData: ActionButtonState.paste,
        builder: (BuildContext context, AsyncSnapshot<ActionButtonState> snap) {
          Widget button = Container();
          if (snap.data == ActionButtonState.paste)
            button = widget.pasteButtonIcon;
          if (snap.data == ActionButtonState.delete)
            button = widget.clearButtonIcon;
          return IconButton(
            onPressed: () => _bloc.onAction(),
            icon: button,
          );
        });
  }

  Widget _buildTextField(int i, BuildContext context) {
    return Expanded(
      child: TextField(
          keyboardType: widget.keyboardType,
          textInputAction: widget.keyboardAction,
          textCapitalization: widget.textCapitalization,
          style: widget.textStyle,
          obscureText: widget.isTextObscure,
          decoration: widget.inputDecoration,
          textAlign: TextAlign.center,
          maxLength: 1,
          controller: _bloc.textCtrls[i],
          focusNode: _bloc.nodes[i],
          onChanged: (String s) {
            _bloc.onTextChange.add(FieldModel(index: i, text: s));
          }),
    );
  }
}
