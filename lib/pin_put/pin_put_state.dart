import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put.dart';

final defaultSubmittedFieldDecoration = BoxDecoration(
  border: Border.all(color: Colors.green),
  borderRadius: BorderRadius.circular(20),
);
final defaultSelectedFieldDecoration = BoxDecoration(
  border: Border.all(color: Colors.yellow),
  borderRadius: BorderRadius.circular(10),
);
final defaultFollowingFieldDecoration = BoxDecoration(
  border: Border.all(color: Colors.deepOrange),
  borderRadius: BorderRadius.circular(5),
);
final defaultDisabledFieldDecoration = BoxDecoration(
  border: Border.all(color: Colors.blueGrey),
  borderRadius: BorderRadius.circular(10),
);

enum PinAnimationType {
  none,
  scale,
  fade,
  slide,
  rotation,
}

class PinPutState extends State<PinPut> with WidgetsBindingObserver {
  TextEditingController _controller;
  FocusNode _focusNode;
  ValueNotifier<String> _textControllerValue;

  // UI
  BoxDecoration _submittedFieldDecoration;
  BoxDecoration _selectedFieldDecoration;
  BoxDecoration _followingFieldDecoration;
  BoxDecoration _disabledDecoration;

  int get selectedIndex => _controller.value.text.length;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _textControllerValue = ValueNotifier<String>(_controller.value.text);
    _submittedFieldDecoration =
        widget.submittedFieldDecoration ?? defaultSubmittedFieldDecoration;
    _selectedFieldDecoration =
        widget.selectedFieldDecoration ?? defaultSelectedFieldDecoration;
    _followingFieldDecoration =
        widget.followingFieldDecoration ?? defaultFollowingFieldDecoration;
    _disabledDecoration =
        widget.disabledDecoration ?? defaultDisabledFieldDecoration;
    _controller.addListener(_textChangeListener);
    _focusNode.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _textChangeListener() {
    final String pin = _controller.value.text;
    if (widget.onChanged != null) widget.onChanged(pin);
    if (pin != _textControllerValue.value) {
      _textControllerValue.value = pin;
      if (pin.length == widget.fieldsCount) widget.onSubmit(pin);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
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
    if (clipboardData.text.length == widget.fieldsCount) {
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
    _focusNode.requestFocus();
    if (widget.onTap != null) widget.onTap();
  }

  Widget get _hiddenTextField {
    return TextField(
      controller: _controller,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmit,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      focusNode: _focusNode,
      enabled: widget.enabled,
      maxLengthEnforced: true,
      autofocus: widget.autoFocus,
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
      style: widget.textStyle.copyWith(color: Colors.transparent),
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
    return AnimatedContainer(
      alignment: Alignment.center,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      padding: widget.fieldPadding,
      margin: widget.fieldMargin,
      constraints: widget.fieldConstraints,
      decoration: _fieldDecoration(index),
      child: AnimatedSwitcher(
        switchInCurve: widget.animationCurve,
        switchOutCurve: widget.animationCurve,
        duration: widget.animationDuration,
        transitionBuilder: (child, animation) {
          return _getTransition(child, animation);
        },
        child: Text(
          index < pin.length ? widget.obscureText ?? pin[index] : '',
          key: ValueKey<String>(index < pin.length ? pin[index] : ''),
          style: widget.textStyle,
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration(int index) {
    if (!widget.enabled) return _disabledDecoration;
    if (index < selectedIndex && _focusNode.hasFocus)
      return _submittedFieldDecoration;
    if (index == selectedIndex && _focusNode.hasFocus)
      return _selectedFieldDecoration;
    return _followingFieldDecoration;
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
