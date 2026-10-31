part of '../pinput.dart';

/// Signature for a function that creates a widget for a given index, e.g., in a
/// list.
typedef JustIndexedWidgetBuilder = Widget Function(int index);

class _PinputFormField extends FormField<String> {
  const _PinputFormField({
    required super.validator,
    required super.enabled,
    required super.initialValue,
    required super.builder,
  }) : super(autovalidateMode: AutovalidateMode.disabled);

  @override
  FormFieldState<String> createState() => _PinputFormFieldState();
}

class _PinputFormFieldState extends FormFieldState<String> {
  @override
  void didChange(String? value) {
    setValue(value);
  }
}

class _SeparatedRaw extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final JustIndexedWidgetBuilder? separatorBuilder;

  const _SeparatedRaw({
    required this.children,
    required this.mainAxisAlignment,
    this.separatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = max(0, children.length * 2 - 1);
    final indexedList = [for (int i = 0; i < itemCount; i += 1) i];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisAlignment == MainAxisAlignment.center
          ? MainAxisSize.min
          : MainAxisSize.max,
      children: indexedList
          .map((index) {
            final itemIndex = index ~/ 2;
            return index.isEven ? children[itemIndex] : _separator(itemIndex);
          })
          .toList(growable: false),
    );
  }

  Widget _separator(int index) =>
      separatorBuilder?.call(index) ?? PinputConstants._defaultSeparator;
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

  const _PinputAnimatedCursor({required this.textStyle, required this.cursor});

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

class _PinputSelectionControls extends EmptyTextSelectionControls
    with TextSelectionHandleControls {}

final TextSelectionControls _pinputSelectionControls =
    _PinputSelectionControls();

class _PinputDefaultContextMenu extends StatelessWidget {
  const _PinputDefaultContextMenu({
    required this.anchors,
    required this.buttonItems,
  });

  final TextSelectionToolbarAnchors anchors;
  final List<ContextMenuButtonItem> buttonItems;

  static String _getLabel(BuildContext context, ContextMenuButtonItem item) {
    if (item.label != null) return item.label!;
    final localizations =
        Localizations.of<WidgetsLocalizations>(context, WidgetsLocalizations) ??
        const DefaultWidgetsLocalizations();
    return switch (item.type) {
      ContextMenuButtonType.cut => localizations.cutButtonLabel,
      ContextMenuButtonType.copy => localizations.copyButtonLabel,
      ContextMenuButtonType.paste => localizations.pasteButtonLabel,
      ContextMenuButtonType.selectAll => localizations.selectAllButtonLabel,
      ContextMenuButtonType.lookUp => localizations.lookUpButtonLabel,
      ContextMenuButtonType.searchWeb => localizations.searchWebButtonLabel,
      ContextMenuButtonType.share => localizations.shareButtonLabel,
      // Matches Flutter's CupertinoTextSelectionToolbarButton and SystemContextMenu:
      // - [custom] items supply their own [item.label] above.
      // - [delete] is only used in spell check suggestions, not text selection.
      // - [liveTextInput] is platform-specific and has no generic text label.
      // Unlabeled items return an empty string and are filtered out in [build].
      ContextMenuButtonType.liveTextInput ||
      ContextMenuButtonType.delete ||
      ContextMenuButtonType.custom => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = buttonItems
        .where((item) => _getLabel(context, item).isNotEmpty)
        .toList(growable: false);
    if (visibleItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark =
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    final backgroundColor = isDark
        ? PinputConstants._menuDarkBackground
        : PinputConstants._menuLightBackground;
    final foregroundColor = isDark
        ? PinputConstants._menuDarkForeground
        : PinputConstants._menuLightForeground;
    final shadowColor = isDark
        ? PinputConstants._menuDarkShadow
        : PinputConstants._menuLightShadow;
    final borderColor = isDark
        ? PinputConstants._menuDarkBorder
        : PinputConstants._menuLightBorder;

    return CustomSingleChildLayout(
      delegate: TextSelectionToolbarLayoutDelegate(
        anchorAbove: anchors.primaryAnchor,
        anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: foregroundColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: borderColor, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final item in visibleItems)
                  _PinputContextMenuButton(
                    label: _getLabel(context, item),
                    textColor: foregroundColor,
                    onPressed: item.onPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinputContextMenuButton extends StatefulWidget {
  const _PinputContextMenuButton({
    required this.label,
    required this.onPressed,
    required this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color textColor;

  @override
  State<_PinputContextMenuButton> createState() =>
      _PinputContextMenuButtonState();
}

class _PinputContextMenuButtonState extends State<_PinputContextMenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.maybePlatformBrightnessOf(context) == Brightness.dark;
    final highlightColor = isDark
        ? PinputConstants._menuDarkHighlight
        : PinputConstants._menuLightHighlight;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: widget.onPressed != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: _isHovered ? highlightColor : PinputConstants._transparent,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 14,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
