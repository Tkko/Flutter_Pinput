part of '../pinput.dart';

class _PinputFormField extends FormField<String> {
  const _PinputFormField({
    required final FormFieldValidator<String>? validator,
    required final bool enabled,
    required final String? initialValue,
    required final Widget Function(FormFieldState<String> field) builder,
    Key? key,
  }) : super(
          key: key,
          enabled: enabled,
          validator: validator,
          autovalidateMode: AutovalidateMode.disabled,
          initialValue: initialValue,
          builder: builder,
        );
}

class _SeparatedRaw extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final Widget Function(int index)? separatorBuilder;

  const _SeparatedRaw({
    required this.children,
    required this.mainAxisAlignment,
    this.separatorBuilder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final separators = <Widget>[];
    separators.addAll(
      List.generate(
        children.length - 1,
        separatorBuilder == null
            ? (index) => PinputConstants._defaultSeparator
            : separatorBuilder!,
      ),
    );

    final actualSeparatorPositions =
        List.generate(children.length - 1, (index) => index + 1)
            .toList(growable: false);

    for (int i = 0; i < separators.length; i++) {
      final separator = separators[i];
      final index = i + actualSeparatorPositions[i];
      children.insert(index, separator);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisAlignment == MainAxisAlignment.center
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: children,
    );
  }
}

class _PinputCursor extends StatelessWidget {
  final Widget? cursor;
  final TextStyle? textStyle;

  const _PinputCursor({required this.textStyle, required this.cursor});

  @override
  Widget build(BuildContext context) => cursor ?? Text('|', style: textStyle);
}

class _PinputAnimatedCursor extends StatefulWidget {
  final Widget? cursor;
  final TextStyle? textStyle;

  const _PinputAnimatedCursor({
    required this.textStyle,
    required this.cursor,
  });

  @override
  State<_PinputAnimatedCursor> createState() => _PinputAnimatedCursorState();
}

class _PinputAnimatedCursorState extends State<_PinputAnimatedCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startCursorAnimation();
  }

  void _startCursorAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat(reverse: true);
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: _PinputCursor(textStyle: widget.textStyle, cursor: widget.cursor),
    );
  }
}
