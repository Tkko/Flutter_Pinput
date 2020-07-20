import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';

class PinPutState extends State<PinPut> with WidgetsBindingObserver {
  TextEditingController _controller;
  FocusNode _focusNode;
  ValueNotifier<String> _textControllerValue;

  int get selectedIndex => _controller.value.text.length;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _textControllerValue = ValueNotifier<String>(_controller.value.text);
    _controller?.addListener(_textChangeListener);
    _focusNode?.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _textChangeListener() {
    final String pin = _controller.value.text;
    if (widget.onChanged != null) widget.onChanged(pin);
    if (pin != _textControllerValue.value) {
      try {
        _textControllerValue.value = pin;
      } catch (e) {
        _textControllerValue = ValueNotifier(_controller.value.text);
      }
      if (pin.length == widget.fieldsCount && widget.onSubmit != null)
        widget.onSubmit(pin);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();

    if (widget.focusNode == null) _focusNode.dispose();

    _textControllerValue.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (appLifecycleState == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  void _checkClipboard() async {
    ClipboardData clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text?.length == widget.fieldsCount) {
      widget.onClipboardFound(clipboardData.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _hiddenTextField,
        _fields,
      ],
    );
  }

  void _handleTap() {
    final focus = FocusScope.of(context);
    if (_focusNode.hasFocus) _focusNode.unfocus();
    if (focus.hasFocus) focus.unfocus();
    focus.requestFocus(FocusNode());
    Future.delayed(Duration.zero, () => focus.requestFocus(_focusNode));
    if (widget.onTap != null) widget.onTap();
  }

  Widget get _hiddenTextField {
    return TextFormField(
      controller: _controller,
      onTap: widget.onTap,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autovalidate: widget.autoValidate,
      textInputAction: widget.textInputAction,
      focusNode: _focusNode,
      enabled: widget.enabled,
      enableSuggestions: false,
      maxLengthEnforced: true,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText != null,
      autocorrect: false,
      keyboardAppearance: widget.keyboardAppearance,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      enableInteractiveSelection: false,
      maxLength: widget.fieldsCount,
      showCursor: false,
      scrollPadding: EdgeInsets.all(0),
      decoration: widget.inputDecoration,
      style: widget.textStyle != null
          ? widget.textStyle.copyWith(color: Colors.transparent)
          : TextStyle(color: Colors.transparent),
    );
  }

  Widget get _fields {
    return ValueListenableBuilder<String>(
      valueListenable: _textControllerValue,
      builder: (BuildContext context, value, Widget child) {
        return GestureDetector(
          onTap: _handleTap,
          child: Row(
            mainAxisAlignment: widget.fieldsAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: Iterable<int>.generate(widget.fieldsCount).map((index) {
              return _getField(index);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _getField(int index) {
    final String pin = _controller.value.text;
    return Flexible(
      child: AnimatedContainer(
        width: widget.eachFieldWidth,
        height: widget.eachFieldHeight,
        alignment: Alignment.center,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        padding: widget.eachFieldPadding,
        margin: widget.eachFieldMargin,
        constraints: widget.eachFieldConstraints,
        decoration: _fieldDecoration(index),
        child: AnimatedSwitcher(
          switchInCurve: widget.animationCurve,
          switchOutCurve: widget.animationCurve,
          duration: widget.animationDuration,
          transitionBuilder: (child, animation) {
            return _getTransition(child, animation);
          },
          child: index < pin.length
              ? Text(
                  widget.obscureText ?? pin[index],
                  key: ValueKey<String>(index < pin.length ? pin[index] : ''),
                  style: widget.textStyle,
                )
              : Text(
                  widget.preFilledChar ?? '',
                  key: ValueKey<String>(index < pin.length ? pin[index] : ''),
                  style: widget.preFilledCharStyle ?? widget.textStyle,
                ),
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration(int index) {
    if (!widget.enabled) return widget.disabledDecoration;
    if (index < selectedIndex && _focusNode.hasFocus)
      return widget.submittedFieldDecoration;
    if (index == selectedIndex && _focusNode.hasFocus)
      return widget.selectedFieldDecoration;
    return widget.followingFieldDecoration;
  }

  Widget _getTransition(Widget child, Animation animation) {
    switch (widget.pinAnimationType) {
      case PinAnimationType.none:
        return child;
      case PinAnimationType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case PinAnimationType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      case PinAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: widget.slideTransitionBeginOffset ?? Offset(0.8, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case PinAnimationType.rotation:
        return RotationTransition(
          turns: animation,
          child: child,
        );
    }
    return child;
  }
}
