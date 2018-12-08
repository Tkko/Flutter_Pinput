import 'package:flutter/material.dart';
import './pin_put_view.dart';

class PinPut extends StatefulWidget {
  final bool isTextObscure;
  final bool clearButtonEnabled;
  final int fieldsCount;
  final int clearButtonColor;
  final double fontSize;
  final double borderRadius;
  final TextInputType keybaordType;
  final TextInputAction keyboardAction;
  final IconData clearButtonIcon;
  final Function onSubmit;
  final bool autoFocus;
  final bool collapsed;
  final Color color;
  // final double contentPadding;
  final String hintText;

  PinPut(
      {this.onSubmit,
      this.fieldsCount = 4,
      this.isTextObscure = false,
      this.fontSize = 40.0,
      this.borderRadius = 5.0,
      this.keybaordType = TextInputType.number,
      this.keyboardAction = TextInputAction.next,
      this.clearButtonIcon = Icons.backspace,
      this.clearButtonEnabled = true,
      this.clearButtonColor = 0xFF66BB6A,
      this.collapsed = false,
      this.hintText = '-',
      this.color = Colors.black,
      // this.contentPadding = 3.0,
      this.autoFocus = true})
      : assert(fieldsCount > 0 && borderRadius > 0);

  @override
  PinPutView createState() => PinPutView();
}
