import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_bloc.dart';
import 'package:pinput/pin_put/pin_put_controller.dart';

class PinPutState extends State<PinPut> with WidgetsBindingObserver {
  PinPutBloc _bloc;
  Widget _actionButton;
  AppLifecycleState _appLifecycleState;
  PinPutController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? PinPutController();
    widget.controller.addListener(() {
      print('controller ${_controller.toString()}');
      _bloc.unFocusAll();
    });

    _bloc = _bloc ??
        PinPutBloc(
          context: context,
          fieldsCount: widget.fieldsCount,
          onSubmit: (String p) => widget.onSubmit(p),
          onClear: (String cl) => widget.onClear(cl),
        );
    _actionButton = _buildActionButton();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(PinPut oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null)
      _controller = PinPutController.fromValue(oldWidget.controller.value);
    else if (widget.controller != null && oldWidget.controller == null)
      _controller = null;
    if (widget.clearInput != oldWidget.clearInput &&
        widget.clearInput == true) {
      _bloc.onAction();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (_appLifecycleState != appLifecycleState) {
      if (appLifecycleState == AppLifecycleState.resumed) {
        _bloc.checkClipboard();
      }
      _appLifecycleState = appLifecycleState;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: widget.containerHeight,
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
    return ValueListenableBuilder<ActionButtonState>(
      valueListenable: _bloc.actionButtonState,
      builder: (BuildContext context, buttonState, Widget child) {
        final icons = {
          ActionButtonState.delete: widget.clearButtonIcon,
          ActionButtonState.paste: widget.pasteButtonIcon,
        };

        return IconButton(
          onPressed: () => _bloc.onAction(),
          icon: icons[buttonState],
        );
      },
    );
  }

  Widget _buildTextField(int i, BuildContext context) {
    return Expanded(
      child: TextField(
          autofocus: i == 0 ? widget.autoFocus : false,
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
