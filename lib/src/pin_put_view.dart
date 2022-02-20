part of 'pin_put.dart';

typedef PinPutErrorBuilder<T> = Widget Function(String? errorText);

class _PinPutView extends StatelessWidget {
  const _PinPutView({
    Key? key,
    required this.fieldsCount,
    this.onSubmit,
    this.onSaved,
    this.onChanged,
    this.onTap,
    required this.controller,
    required this.focusNode,
    this.preFilledWidget,
    this.separatorPositions,
    this.separator,
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
    this.eachFieldConstraints,
    this.inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      counter: SizedBox.shrink(),
      counterStyle: TextStyle(fontSize: .000001, height: 0),
      counterText: '',
    ),
    this.animationCurve = Curves.linear,
    this.animationDuration = const Duration(milliseconds: 160),
    this.pinAnimationType = PinAnimationType.scale,
    this.slideTransitionBeginOffset,
    this.enabled = true,
    this.useNativeKeyboard = true,
    this.enableInteractiveSelection = true,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.cursor,
    this.keyboardAppearance,
    this.inputFormatters,
    this.validator,
    this.keyboardType = TextInputType.number,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.toolbarOptions = const ToolbarOptions(paste: true),
    this.autofillHints,
    this.strutStyle,
    this.textDirection,
    this.readOnly = false,
    this.showCursor = false,
    this.obscuringCharacter = '•',
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.selectionControls,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.errorBuilder,
    this.errorText,
    this.errorTextStyle,
    required this.errorWidgetPadding,
  })  : assert(fieldsCount > 0),
        super(key: key);

  final PinPutErrorBuilder? errorBuilder;

  final String? errorText;

  final TextStyle? errorTextStyle;

  final StrutStyle? strutStyle;

  final TextDirection? textDirection;

  /// Displayed fields count. PIN code length.
  final int fieldsCount;

  /// Same as FormField onFieldSubmitted, called when PinPut submitted.
  final ValueChanged<String>? onSubmit;

  /// Signature for being notified when a form field changes value.
  final FormFieldSetter<String>? onSaved;

  /// Called every time input value changes.
  final ValueChanged<String>? onChanged;

  /// Called when user clicks on PinPut
  final VoidCallback? onTap;

  /// Used to get, modify PinPut value and more.
  final TextEditingController controller;

  /// Defines the keyboard focus for this
  /// To give the keyboard focus to this widget, provide a [focusNode] and then
  /// use the current [FocusScope] to request the focus:
  final FocusNode focusNode;

  /// Widget that is displayed before field submitted.
  final Widget? preFilledWidget;

  /// Sets the positions where the separator should be shown
  final List<int>? separatorPositions;

  /// Builds a PinPut separator
  final Widget? separator;

  /// The style to use for PinPut
  /// If null, defaults to the `subhead` text style from the current [Theme].
  final TextStyle? textStyle;

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
  final BoxDecoration? submittedFieldDecoration;

  /// The decoration of [PinPut] currently selected field
  final BoxDecoration? selectedFieldDecoration;

  /// The decoration of each [PinPut] following field
  final BoxDecoration? followingFieldDecoration;

  /// The decoration of each [PinPut] field when [PinPut] ise disabled
  final BoxDecoration? disabledDecoration;

  /// width of each [PinPut] field
  final double? eachFieldWidth;

  /// height of each [PinPut] field
  final double? eachFieldHeight;

  /// Defines how [PinPut] fields are being placed inside [Row]
  final MainAxisAlignment fieldsAlignment;

  /// Defines how each [PinPut] field are being placed within the container
  final AlignmentGeometry eachFieldAlignment;

  /// Empty space to surround the [PinPut] field container.
  final EdgeInsetsGeometry? eachFieldMargin;

  /// Empty space to inscribe the [PinPut] field container.
  /// For example space between border and text
  final EdgeInsetsGeometry? eachFieldPadding;

  /// Additional constraints to apply to the each field container.
  /// properties
  /// ```dart
  ///  this.minWidth = 0.0,
  ///  this.maxWidth = double.infinity,
  ///  this.minHeight = 0.0,
  ///  this.maxHeight = double.infinity,
  ///  ```
  final BoxConstraints? eachFieldConstraints;

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
  final Offset? slideTransitionBeginOffset;

  /// Defines [PinPut] state
  final bool enabled;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// Whether we use Native keyboard or custom `Numpad`
  /// when flag is set to false [PinPut] wont be focusable anymore
  /// so you should set value of [PinPut]'s [TextEditingController] programmatically
  final bool useNativeKeyboard;

  final bool enableInteractiveSelection;

  /// If true [validator] function is called when [PinPut] value changes
  /// alternatively you can use [GlobalKey]
  /// ```dart
  ///   final _formKey = GlobalKey<FormState>();
  ///   _formKey.currentState.validate()
  /// ```
  final AutovalidateMode autovalidateMode;

  /// If true the focused field includes fake cursor
  final bool showCursor;

  /// If [showCursor] true the focused field includes cursor widget or '|'
  final Widget? cursor;

  /// The appearance of the keyboard.
  /// This setting is only honored on iOS devices.
  /// If unset, defaults to [ThemeData.brightness].
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.inputFormatters}
  final List<TextInputFormatter>? inputFormatters;

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
  final FormFieldValidator<String>? validator;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType keyboardType;

  /// Provide any symbol to obscure each [PinPut] field
  /// Recommended ●
  final String obscuringCharacter;

  final bool obscureText;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.newline] if [keyboardType] is
  /// [TextInputType.multiline] and [TextInputAction.done] otherwise.
  final TextInputAction? textInputAction;

  /// Configuration of toolbar options.
  ///
  /// If not set, select all and paste will default to be enabled. Copy and cut
  /// will be disabled if [obscureText] is true. If [readOnly] is true,
  /// paste and cut will be disabled regardless.
  final ToolbarOptions? toolbarOptions;

  /// lists of auto fill hints
  final Iterable<String>? autofillHints;

  final bool readOnly;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final TextSelectionControls? selectionControls;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final EdgeInsetsGeometry errorWidgetPadding;

  String get pin => controller.value.text;

  int get selectedIndex => pin.length;

  bool get hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _fields(context),
          _hiddenTextField(context),
        ],
      ),
    );
  }

  TextStyle _textStyle(BuildContext context) {
    final defaultTextStyle =
        Theme.of(context).textTheme.bodyText2 ?? TextStyle();
    return textStyle ?? defaultTextStyle;
  }

  void _handleTap(BuildContext context) {
    final focus = FocusScope.of(context);
    if (focusNode.hasFocus) focusNode.unfocus();
    if (focus.hasFocus) focus.unfocus();
    focus.requestFocus(FocusNode());
    Future.delayed(Duration.zero, () => focus.requestFocus(focusNode));
    onTap?.call();
  }

  Widget _hiddenTextField(BuildContext context) {
    return TextField(
      controller: controller,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: textInputAction,
      focusNode: focusNode,
      enabled: enabled,
      enableSuggestions: enableSuggestions,
      autofocus: autofocus,
      readOnly: readOnly || !useNativeKeyboard,
      obscureText: obscureText,
      autocorrect: false,
      autofillHints: autofillHints,
      keyboardAppearance: keyboardAppearance,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      enableInteractiveSelection: enableInteractiveSelection,
      toolbarOptions: toolbarOptions,
      maxLength: fieldsCount,
      showCursor: false,
      scrollPadding: EdgeInsets.zero,
      decoration: inputDecoration.copyWith(
        errorStyle: TextStyle(fontSize: .000001, height: 0),
        errorText: '',
      ),
      style: _textStyle(context).copyWith(color: Colors.transparent),
      restorationId: restorationId,
      strutStyle: strutStyle,
      textDirection: textDirection,
      obscuringCharacter: obscuringCharacter,
      smartDashesType: smartDashesType ??
          (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
      smartQuotesType: smartQuotesType ??
          (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
      onEditingComplete: onEditingComplete,
      onSubmitted: onFieldSubmitted,
      selectionControls: selectionControls,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
    );
  }

  Widget _fields(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: animationDuration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SeparatedRaw(
            children:
                Iterable<int>.generate(fieldsCount).map(_getField).toList(),
            separator: separator,
            separatorPositions: separatorPositions,
            mainAxisAlignment: fieldsAlignment,
          ),
          if (hasError) _errorWidget(context),
        ],
      ),
    );
  }

  Widget _errorWidget(BuildContext context) {
    final _style = errorTextStyle ??
        _textStyle(context).copyWith(color: Theme.of(context).errorColor);

    return Padding(
      padding: errorWidgetPadding,
      child: errorBuilder != null
          ? errorBuilder!.call(errorText)
          : Text(errorText!, style: _style),
    );
  }

  Widget _getField(int index) {
    return Flexible(
      child: AnimatedContainer(
        height: eachFieldHeight,
        width: eachFieldWidth,
        constraints: eachFieldConstraints,
        alignment: eachFieldAlignment,
        duration: animationDuration,
        curve: animationCurve,
        padding: eachFieldPadding,
        margin: eachFieldMargin,
        decoration: _fieldDecoration(index),
        child: AnimatedSwitcher(
          switchInCurve: animationCurve,
          switchOutCurve: animationCurve,
          duration: animationDuration,
          transitionBuilder: (child, animation) {
            return _getTransition(child, animation);
          },
          child: _buildFieldContent(index, pin),
        ),
      ),
    );
  }

  Widget _buildFieldContent(int index, String pin) {
    final key = ValueKey<String>(index < pin.length ? pin[index] : '');

    if (index < pin.length) {
      return Text(
        obscureText ? obscuringCharacter : pin[index],
        key: key,
        style: textStyle,
      );
    }

    final isActiveField = index == pin.length;
    final focused = focusNode.hasFocus || !useNativeKeyboard;

    if (showCursor && isActiveField && focused) {
      return _PinPutCursor(textStyle: textStyle, cursor: cursor);
    }

    if (preFilledWidget != null) {
      return SizedBox(key: key, child: preFilledWidget);
    }

    return Text('', key: key, style: textStyle);
  }

  BoxDecoration? _fieldDecoration(int index) {
    if (!enabled) return disabledDecoration;
    if (index < selectedIndex && (focusNode.hasFocus || !useNativeKeyboard)) {
      return submittedFieldDecoration;
    }
    if (index == selectedIndex && (focusNode.hasFocus || !useNativeKeyboard)) {
      return selectedFieldDecoration;
    }
    return followingFieldDecoration;
  }

  Widget _getTransition(Widget child, Animation animation) {
    switch (pinAnimationType) {
      case PinAnimationType.none:
        return child;
      case PinAnimationType.fade:
        return FadeTransition(
          opacity: animation as Animation<double>,
          child: child,
        );
      case PinAnimationType.scale:
        return ScaleTransition(
          scale: animation as Animation<double>,
          child: child,
        );
      case PinAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: slideTransitionBeginOffset ?? Offset(0.8, 0),
            end: Offset.zero,
          ).animate(animation as Animation<double>),
          child: child,
        );
      case PinAnimationType.rotation:
        return RotationTransition(
          turns: animation as Animation<double>,
          child: child,
        );
    }
  }
}
