part of '../pinput.dart';

class _PinputFormField extends FormField<String> {
  _PinputFormField({
    required final FormFieldValidator<String>? validator,
    required final bool enabled,
    required final Widget child,
    Key? key,
  }) : super(
          key: key,
          enabled: enabled,
          validator: validator,
          autovalidateMode: AutovalidateMode.disabled,
          builder: (FormFieldState<String> field) => child,
        );
}

class _SeparatedRaw extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final List<int>? separatorPositions;
  final Widget? separator;

  _SeparatedRaw({
    required this.children,
    required this.mainAxisAlignment,
    this.separator,
    this.separatorPositions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      final _separatorPositions = separatorPositions ??
          List.generate(children.length - 1, (index) => index + 1)
              .toList(growable: false);

      final separatorsCount = _separatorPositions.length;

      for (int i = 0; i < separatorsCount; ++i) {
        final index = i + _separatorPositions[i];
        if (index <= children.length) {
          children.insert(index, separator!);
        }
      }
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

class _PinputCursor extends StatefulWidget {
  final Widget? cursor;
  final TextStyle? textStyle;

  _PinputCursor({
    this.textStyle,
    this.cursor,
  });

  @override
  State<_PinputCursor> createState() => _PinputCursorState();
}

class _PinputCursorState extends State<_PinputCursor>
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        return Center(
          child: Opacity(
            opacity: _animationController.value,
            child: widget.cursor ?? Text('|', style: widget.textStyle),
          ),
        );
      },
    );
  }
}
