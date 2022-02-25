part of 'pinput.dart';

const _hiddenTextStyle =
    TextStyle(fontSize: 1, height: 1, color: Colors.transparent);
const _hiddenInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.zero,
  border: InputBorder.none,
  focusedBorder: InputBorder.none,
  enabledBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  errorText: '',
  counter: SizedBox.shrink(),
  counterStyle: _hiddenTextStyle,
  helperStyle: _hiddenTextStyle,
  errorStyle: _hiddenTextStyle,
  floatingLabelStyle: _hiddenTextStyle,
  suffixStyle: _hiddenTextStyle,
  hintStyle: _hiddenTextStyle,
  labelStyle: _hiddenTextStyle,
  prefixStyle: _hiddenTextStyle,
  counterText: '',
  // filled: true,
);

const _defaultPinFillColor = Color.fromRGBO(222, 231, 240, .57);

const _defaultPinputDecoration = BoxDecoration(
  color: _defaultPinFillColor,
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

const _defaultPinTheme = PinTheme(
  width: 56,
  height: 60,
  textStyle: TextStyle(),
  decoration: _defaultPinputDecoration,
);
