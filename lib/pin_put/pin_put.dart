import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put_state.dart';

class PinPut extends StatefulWidget {
  PinPut({
    Key key,
    @required this.fieldsCount,
    @required this.onSubmit,
    this.animationCurve = Curves.linear,
    this.fieldMargin,
    this.fieldPadding,
    this.fieldConstraints = const BoxConstraints(minHeight: 40, minWidth: 40),
    this.animationDuration = const Duration(milliseconds: 160),
    this.autoFocus = false,
    this.controller,
    this.enabled = true,
    this.submittedFieldDecoration,
    this.selectedFieldDecoration,
    this.pinAnimationType = PinAnimationType.slide,
    this.followingFieldDecoration,
    this.disabledDecoration,
    this.focusNode,
    this.inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.all(0),
      border: InputBorder.none,
      counterText: '',
    ),
    this.inputFormatters,
    this.keyboardAppearance,
    this.keyboardType = TextInputType.number,
    this.obscureText,
    this.onChanged,
    this.onTap,
    this.slideTransitionBeginOffset,
    this.onClipboardFound,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.textStyle = const TextStyle(fontSize: 30),
    this.fieldsAlignment = MainAxisAlignment.spaceBetween,
    this.toolbarOptions,
  }) : assert(fieldsCount > 0);

  final Offset slideTransitionBeginOffset;
  final PinAnimationType pinAnimationType;
  final MainAxisAlignment fieldsAlignment;
  final EdgeInsetsGeometry fieldPadding;
  final EdgeInsetsGeometry fieldMargin;
  final BoxConstraints fieldConstraints;
  final Curve animationCurve;
  final BoxDecoration submittedFieldDecoration;
  final BoxDecoration selectedFieldDecoration;
  final BoxDecoration followingFieldDecoration;
  final BoxDecoration disabledDecoration;
  final Brightness keyboardAppearance;
  final Duration animationDuration;
  final FocusNode focusNode;
  final InputDecoration inputDecoration;
  final List<TextInputFormatter> inputFormatters;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final TextStyle textStyle;
  final ToolbarOptions toolbarOptions;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String> onClipboardFound;
  final VoidCallback onTap;
  final bool autoFocus;
  final bool enabled;

  //Recommended ●
  final String obscureText;
  final int fieldsCount;

  @override
  PinPutState createState() => PinPutState();
}
