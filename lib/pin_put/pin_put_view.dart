import 'package:flutter/material.dart';
import './pin_put_view_model.dart';

class PinPutView extends PinPutViewModel {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: generateTextFields(context),
    );
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fieldsCount, (int i) {
      return buildTextField(i, context);
    });
    if (widget.clearButtonEnabled)
      textFields.add(Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: GestureDetector(
            onTap: () => clearWidget(context),
            child: Icon(
              Icons.backspace,
              color: Color(widget.clearButtonColor),
              size: 30.0,
            )),
      ));
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields);
  }
}
