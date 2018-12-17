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
    List<Widget> widgets = List.generate(widget.fieldsCount, (int i) {
      return buildTextField(i, context);
    });
    if (widget.clearButtonEnabled) widgets.add(_actionButton());
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: widgets);
  }

  Widget _actionButton() {
    return StreamBuilder(
      stream: bloc.onActionChanged,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot snap) {
        return IconButton(
            onPressed: () => onAction(context, snap.data),
            icon: Icon(
              snap.data ? widget.pasteButtonIcon : widget.clearButtonIcon,
              color: Color(widget.clearButtonColor),
              size: 30,
            ));
      },
    );
  }
}
