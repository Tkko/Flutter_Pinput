part of 'pinput.dart';

class HiddenTextSelectionControls extends TextSelectionControls {
  final double height;

  HiddenTextSelectionControls(this.height)
      : _controls = Platform.isIOS ? cupertinoTextSelectionControls : materialTextSelectionControls;

  final TextSelectionControls _controls;

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _controls.buildToolbar(
      context,
      globalEditableRegion.shift(Offset(0, -(height - 20) / 2)),
      textLineHeight,
      selectionMidpoint,
      endpoints,
      delegate,
      clipboardStatus,
      lastSecondaryTapDownPosition,
    );
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return Size.zero;
  }

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap, double? startGlyphHeight, double? endGlyphHeight]) {
    return SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight,
      [double? startGlyphHeight, double? endGlyphHeight]) {
    return Offset.zero;
  }
}
