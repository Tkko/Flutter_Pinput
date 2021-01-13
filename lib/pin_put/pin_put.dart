import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pin_put/pin_put_state.dart';

class PinPut extends StatefulWidget {
  const PinPut({
    Key key,
    @required this.fieldsCount,
    this.onSubmit,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.onClipboardFound,
    this.controller,
    this.focusNode,
    this.preFilledWidget,
    this.separatorPositions = const [],
    this.separator = const SizedBox(width: 15.0),
    this.textStyle,
    this.submittedFieldDecoration,
    this.selectedFieldDecoration,
    this.followingFieldDecoration,
    this.disabledDecoration,
    this.eachFieldWidth,
    this.eachFieldHeight,
    this.fieldsAlignment = MainAxisAlignment.spaceBetween,
    this.eachFieldAlignment = Alignment.center,
    this.eachFieldMargin,
    this.eachFieldPadding,
    this.eachFieldConstraints =
        const BoxConstraints(minHeight: 40.0, minWidth: 40.0),
    this.inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      counterText: '',
    ),
    this.animationCurve = Curves.linear,
    this.animationDuration = const Duration(milliseconds: 160),
    this.pinAnimationType = PinAnimationType.slide,
    this.slideTransitionBeginOffset,
    this.enabled = true,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.withCursor = false,
    this.cursor,
    this.keyboardAppearance,
    this.inputFormatters,
    this.validator,
    this.keyboardType = TextInputType.number,
    this.obscureText,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.toolbarOptions,
    this.mainAxisSize = MainAxisSize.max,
  })  : assert(fieldsCount > 0),
        super(key: key);

  /// Displayed fields count. PIN code length.
  final int fieldsCount;

  /// Same as FormField onFieldSubmitted, called when PinPut submitted.
  final ValueChanged<String> onSubmit;

  /// Signature for being notified when a form field changes value.
  final FormFieldSetter<String> onSaved;

  /// Called every time input value changes.
  final ValueChanged<String> onChanged;

  /// Called when user clicks on PinPut
  final VoidCallback onTap;

  /// Called when Clipboard has value of length fieldsCount.
  final ValueChanged<String> onClipboardFound;

  /// Used to get, modify PinPut value and more.
  final TextEditingController controller;

  /// Defines the keyboard focus for this widget.
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  final FocusNode focusNode;

  /// Widget that is displayed before field submitted.
  final Widget preFilledWidget;

  /// Sets the positions where the separator should be shown
  final List<int> separatorPositions;

  /// Builds a PinPut separator
  final Widget separator;

  /// The style to use for PinPut
  /// If null, defaults to the `subhead` text style from the current [Theme].
  final TextStyle textStyle;

  ///  Box decoration of following properties of [PinPut]
  ///  [submittedFieldDecoration] [selectedFieldDecoration] [followingFieldDecoration] [disabledDecoration]
  ///  You can customize every pixel with it
  ///  properties are being animated implicitly when value changes
  ///  ```dart
  ///  this.color,
  ///  this.image,
  ///  this.border,
  ///  this.borderRadius,
  ///  this.boxShadow,
  ///  this.gradient,
  ///  this.backgroundBlendMode,
  ///  this.shape = BoxShape.rectangle,
  ///  ```

  /// The decoration of each [PinPut] submitted field
  final BoxDecoration submittedFieldDecoration;

  /// The decoration of [PinPut] currently selected field
  final BoxDecoration selectedFieldDecoration;

  /// The decoration of each [PinPut] following field
  final BoxDecoration followingFieldDecoration;

  /// The decoration of each [PinPut] field when [PinPut] ise disabled
  final BoxDecoration disabledDecoration;

  /// width of each [PinPut] field
  final double eachFieldWidth;

  /// height of each [PinPut] field
  final double eachFieldHeight;

  /// Defines how [PinPut] fields are being placed inside [Row]
  final MainAxisAlignment fieldsAlignment;

  /// Defines how each [PinPut] field are being placed within the container
  final AlignmentGeometry eachFieldAlignment;

  /// Empty space to surround the [PinPut] field container.
  final EdgeInsetsGeometry eachFieldMargin;

  /// Empty space to inscribe the [PinPut] field container.
  /// For example space between border and text
  final EdgeInsetsGeometry eachFieldPadding;

  /// Additional constraints to apply to the each field container.
  /// properties
  /// ```dart
  ///  this.minWidth = 0.0,
  ///  this.maxWidth = double.infinity,
  ///  this.minHeight = 0.0,
  ///  this.maxHeight = double.infinity,
  ///  ```
  final BoxConstraints eachFieldConstraints;

  /// The decoration to show around the text [PinPut].
  ///
  /// can be configured to show an icon, border,counter, label, hint text, and error text.
  /// set counterText to '' to remove bottom padding entirely
  final InputDecoration inputDecoration;

  /// curve of every [PinPut] Animation
  final Curve animationCurve;

  /// Duration of every [PinPut] Animation
  final Duration animationDuration;

  /// Animation Type of each [PinPut] field
  /// options:
  /// none, scale, fade, slide, rotation
  final PinAnimationType pinAnimationType;

  /// Begin Offset of ever [PinPut] field when [pinAnimationType] is slide
  final Offset slideTransitionBeginOffset;

  /// Defines [PinPut] state
  final bool enabled;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// If true [validator] function is called when [PinPut] value changes
  /// alternatively you can use [GlobalKey]
  /// ```dart
  ///   final _formKey = GlobalKey<FormState>();
  ///   _formKey.currentState.validate()
  /// ```
  final AutovalidateMode autovalidateMode;

  /// If true the focused field includes fake cursor
  final bool withCursor;

  /// If [withCursor] true the focused field includes cursor widget or '|'
  final Widget cursor;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to the brightness of [ThemeData.primaryColorBrightness].
  final Brightness keyboardAppearance;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter> inputFormatters;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  ///
  /// The returned value is exposed by the [FormFieldState.errorText] property.
  /// The [TextFormField] uses this to override the [InputDecoration.errorText]
  /// value.
  ///
  /// Alternating between error and normal state can cause the height of the
  /// [TextFormField] to change if no other subtext decoration is set on the
  /// field. To create a field whose height is fixed regardless of whether or
  /// not an error is displayed, either wrap the  [TextFormField] in a fixed
  /// height parent like [SizedBox], or set the [TextFormField.helperText]
  /// parameter to a space.
  final FormFieldValidator<String> validator;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// Provide any symbol to obscure each [PinPut] field
  /// Recommended ●
  final String obscureText;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction textInputAction;

  /// Configuration of toolbar options.
  ///
  /// If not set, select all and paste will default to be enabled. Copy and cut
  /// will be disabled if [obscureText] is true. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  final ToolbarOptions toolbarOptions;

  /// Maximize the amount of free space along the main axis.
  final MainAxisSize mainAxisSize;

  @override
  PinPutState createState() => PinPutState();
}

enum PinAnimationType {
  none,
  scale,
  fade,
  slide,
  rotation,
}
