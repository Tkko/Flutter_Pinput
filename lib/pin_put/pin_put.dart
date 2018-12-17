import 'package:flutter/material.dart';
import './pin_put_view.dart';

class PinPut extends StatefulWidget {
  PinPut(
      {this.onSubmit,
      this.fieldsCount = 4,
      this.isTextObscure = false,
      this.fontSize = 40.0,
      this.borderRadius = 5.0,
      this.keybaordType = TextInputType.number,
      this.keyboardAction = TextInputAction.next,
      this.clearButtonIcon = Icons.backspace,
      this.pasteButtonIcon = Icons.content_paste,
      this.clearButtonEnabled = true,
      this.clearButtonColor = 0xFF66BB6A,
      this.autoFocus = true})
      : assert(fieldsCount > 0 && borderRadius > 0);

  final bool isTextObscure;
  final bool clearButtonEnabled;
  final int fieldsCount;
  final int clearButtonColor;
  final double fontSize;
  final double borderRadius;
  final TextInputType keybaordType;
  final TextInputAction keyboardAction;
  final IconData clearButtonIcon;
  final IconData pasteButtonIcon;
  final Function onSubmit;
  final bool autoFocus;

  @override
  PinPutView createState() => PinPutView();
}
