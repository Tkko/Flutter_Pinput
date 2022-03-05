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
      final _separatorPositions =
          separatorPositions ?? List.generate(children.length - 1, (index) => index + 1).toList(growable: false);

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
      mainAxisSize: mainAxisAlignment == MainAxisAlignment.center ? MainAxisSize.min : MainAxisSize.max,
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

class _PinputCursorState extends State<_PinputCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startCursorAnimation();
  }

  void _startCursorAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

class _PasteWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final TextEditingController controller;
  final int length;
  final bool toolbarEnabled;

  _PasteWrapper({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.controller,
    required this.length,
    required this.toolbarEnabled,
  });

  @override
  State<_PasteWrapper> createState() => _PasteWrapperState();
}

class _PasteWrapperState extends State<_PasteWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _layerLink = LayerLink();
  late final OverlayEntry _overlay = createOverlay();
  RenderBox? renderObject;
  String clipboardData = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
  }

  void maybeShowToolbar() async {
    HapticFeedback.lightImpact();
    widget.onLongPress?.call();
    if (renderObject != null) return;
    clipboardData = await getClipboardData();
    final shouldShow = clipboardData.length == widget.length;
    if (!shouldShow) return;

    _animationController.animateTo(1.0);
    Overlay.of(context)?.insert(_overlay);
  }

  void onTap() {
    widget.onTap.call();
    if (renderObject != null) {
      close();
    }
  }

  void close() {
    _animationController.value = 0;
    renderObject = null;
    _overlay.remove();
  }

  void onPaste() {
    close();
    widget.controller.text = clipboardData;
  }

  Future<String> getClipboardData() async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    final String text = clipboardData?.text ?? '';
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: maybeShowToolbar,
      onDoubleTap: maybeShowToolbar,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: widget.child,
      ),
    );
  }

  OverlayEntry createOverlay() {
    // final isiOS = Theme.of(context).platform == TargetPlatform.iOS && false;
    final isiOS = true;
    return OverlayEntry(
      builder: (_) {
        renderObject = context.findRenderObject() as RenderBox;
        return Positioned(
          left: 0,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            followerAnchor: Alignment.center,
            targetAnchor: Alignment.topCenter,
            offset: Offset(0, isiOS ? -20 : -25),
            child: FadeTransition(
              opacity: _animationController,
              child: Material(
                elevation: 0,
                color: Colors.transparent,
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: close,
                  child: isiOS ? _CupertinoPasteButton(onPaste) : _MaterialPasteButton(onPaste),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MaterialPasteButton extends StatelessWidget {
  final VoidCallback onPaste;

  _MaterialPasteButton(this.onPaste);

  final backgroundColor = Color.alphaBlend(const Color(0xEB202020), const Color(0xFF808080));

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      child: InkWell(
        onTap: onPaste,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Text(
            materialLocalizations.pasteButtonLabel,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _CupertinoPasteButton extends StatelessWidget {
  final backgroundColor = Color.alphaBlend(const Color(0xEB202020), const Color(0xFF808080));

  final VoidCallback onPaste;

  _CupertinoPasteButton(this.onPaste);

  @override
  Widget build(BuildContext context) {
    final cupertinoLocalizations = CupertinoLocalizations.of(context);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          bottom: 1,
          child: ClipPath(
            clipper: _TriangleClipper(),
            child: Container(
              height: 8,
              width: 15,
              color: backgroundColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CupertinoButton(
            minSize: 36.5,
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor,
            onPressed: onPaste,
            padding: EdgeInsets.symmetric(horizontal: 18),
            pressedOpacity: 0.95,
            child: Text(
              cupertinoLocalizations.pasteButtonLabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                inherit: false,
                fontSize: 14.0,
                letterSpacing: -0.15,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
