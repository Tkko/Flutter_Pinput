part of '../pinput.dart';

class _PinItem extends StatelessWidget {
  final _PinputState state;
  final int index;

  const _PinItem({required this.state, required this.index});

  @override
  Widget build(BuildContext context) {
    final item = state._pinItemState(index);
    final themes =
        state.widget.theme ??
        DefaultPinThemes.maybeOf(context) ??
        const PinThemes();
    final pinTheme = themes.resolve(item, state.widget.validationState);
    final duration = state._animationDuration(context);

    return state._wrapWithPinTap(
      index,
      Flexible(
        child: AnimatedContainer(
          height: pinTheme.height,
          width: pinTheme.width,
          constraints: pinTheme.constraints,
          padding: pinTheme.padding,
          margin: pinTheme.margin,
          decoration: pinTheme.decoration,
          alignment: pinTheme.alignment ?? Alignment.center,
          duration: duration,
          curve: state.widget.animation.curve,
          child: AnimatedSwitcher(
            switchInCurve: state.widget.animation.curve,
            switchOutCurve: state.widget.animation.curve,
            duration: duration,
            transitionBuilder: _getTransition,
            child: _buildFieldContent(context, item, pinTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContent(
    BuildContext context,
    PinItemState item,
    PinTheme pinTheme,
  ) {
    final char = item.value;
    final key = ValueKey<String>('$index-$char');
    final shouldShowCursor =
        state.widget.cursor._type != _PinCursorType.hidden && item.showCursor;

    if (item.isFilled) {
      final Widget characterWidget;
      final obscuring = index == state._revealedSlot
          ? null
          : state.widget.obscuring;
      if (obscuring?._widget != null) {
        characterWidget = SizedBox(key: key, child: obscuring!._widget);
      } else {
        characterWidget = Text(
          obscuring?._character ?? char,
          key: key,
          style: pinTheme.textStyle,
        );
      }

      // With pin editing the filled pin always uses the same wrapper, so moving
      // the cursor on/off a pin does not replay the AnimatedSwitcher transition.
      if (state.widget.editMode != PinEditMode.none) {
        return Stack(
          key: key,
          alignment: pinTheme.alignment ?? Alignment.center,
          children: [
            characterWidget,
            if (shouldShowCursor) _buildCursor(context, pinTheme),
          ],
        );
      }

      return characterWidget;
    }

    if (shouldShowCursor) {
      return _buildCursor(context, pinTheme);
    }

    if (pinTheme.placeholder != null) {
      return SizedBox(key: key, child: pinTheme.placeholder);
    }

    return Text('', key: key, style: pinTheme.textStyle);
  }

  Widget _buildCursor(BuildContext context, PinTheme pinTheme) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (state.widget.cursor._type == _PinCursorType.blinking && !reduceMotion) {
      return _PinputAnimatedCursor(
        textStyle: pinTheme.textStyle,
        cursor: state.widget.cursor._child,
        blinkDuration: state.widget.cursor._blinkDuration,
      );
    }

    return _PinputCursor(
      textStyle: pinTheme.textStyle,
      cursor: state.widget.cursor._child,
    );
  }

  Widget _getTransition(Widget child, Animation<double> animation) {
    if (child is _PinputAnimatedCursor) {
      return child;
    }

    switch (state.widget.animation._type) {
      case _PinAnimationType.none:
        return child;
      case _PinAnimationType.fade:
        return FadeTransition(opacity: animation, child: child);
      case _PinAnimationType.scale:
        return ScaleTransition(scale: animation, child: child);
      case _PinAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: state.widget.animation._beginOffset!,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case _PinAnimationType.rotation:
        return RotationTransition(turns: animation, child: child);
      case _PinAnimationType.custom:
        return state.widget.animation._transitionBuilder!(child, animation);
    }
  }
}
