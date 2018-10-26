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
      this.clearButtonColor = 0xFF66BB6A})
      : assert(fieldsCount > 0 && borderRadius > 0);

  @override
  PinPutView createState() => PinPutView();
}
