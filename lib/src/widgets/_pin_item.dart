part of '../pinput.dart';

class _PinItem extends StatelessWidget {
  final _PinputState state;
  final int index;

  const _PinItem({required this.state, required this.index});

  @override
  Widget build(BuildContext context) {
    final pinTheme = _pinTheme(index);

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
          alignment: state.widget.pinContentAlignment,
          duration: state.widget.animationDuration,
          curve: state.widget.animationCurve,
          child: AnimatedSwitcher(
            switchInCurve: state.widget.animationCurve,
            switchOutCurve: state.widget.animationCurve,
            duration: state.widget.animationDuration,
            transitionBuilder: _getTransition,
            child: _buildFieldContent(index, pinTheme),
          ),
        ),
      ),
    );
  }

  PinTheme _pinTheme(int index) {
    final theme = switch (state._getState(index)) {
      PinItemStateType.initial => null,
      PinItemStateType.focused => state.widget.focusedPinTheme,
      PinItemStateType.submitted => state.widget.submittedPinTheme,
      PinItemStateType.following => state.widget.followingPinTheme,
      PinItemStateType.disabled => state.widget.disabledPinTheme,
      PinItemStateType.error => state.widget.errorPinTheme,
    };
    return theme ??
        state.widget.defaultPinTheme ??
        PinputConstants._defaultPinTheme;
  }

  Widget _buildFieldContent(int index, PinTheme pinTheme) {
    final char = state._slotValue(index);
    final key = ValueKey<String>('$index-$char');
    final isSubmittedPin = char.isNotEmpty;

    final isActiveField = index == state.selectedIndex;
    final focused =
        state._effectiveFocusNode.hasFocus || !state.widget.useNativeKeyboard;
    final shouldShowCursor =
        state.widget.showCursor && state.isEnabled && isActiveField && focused;

    if (isSubmittedPin) {
      final Widget characterWidget;
      if (state.widget.obscureText && state.widget.obscuringWidget != null) {
        characterWidget = SizedBox(
          key: key,
          child: state.widget.obscuringWidget,
        );
      } else {
        characterWidget = Text(
          state.widget.obscureText ? state.widget.obscuringCharacter : char,
          key: key,
          style: pinTheme.textStyle,
        );
      }

      // With pin editing the filled pin always uses the same wrapper, so moving
      // the cursor on/off a pin does not replay the AnimatedSwitcher transition.
      if (state.widget.pinEditMode != PinEditMode.none) {
        return Stack(
          key: key,
          alignment: state.widget.pinContentAlignment,
          children: [
            characterWidget,
            if (shouldShowCursor) _buildCursor(pinTheme),
          ],
        );
      }

      return characterWidget;
    }

    if (shouldShowCursor) {
      return _buildCursor(pinTheme);
    }

    if (state.widget.preFilledWidget != null) {
      return SizedBox(key: key, child: state.widget.preFilledWidget);
    }

    return Text('', key: key, style: pinTheme.textStyle);
  }

  Widget _buildCursor(PinTheme pinTheme) {
    if (state.widget.isCursorAnimationEnabled) {
      return _PinputAnimatedCursor(
        textStyle: pinTheme.textStyle,
        cursor: state.widget.cursor,
      );
    }

    return _PinputCursor(
      textStyle: pinTheme.textStyle,
      cursor: state.widget.cursor,
    );
  }

  Widget _getTransition(Widget child, Animation<double> animation) {
    if (child is _PinputAnimatedCursor) {
      return child;
    }

    switch (state.widget.pinAnimationType) {
      case PinAnimationType.none:
        return child;
      case PinAnimationType.fade:
        return FadeTransition(opacity: animation, child: child);
      case PinAnimationType.scale:
        return ScaleTransition(scale: animation, child: child);
      case PinAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin:
                state.widget.slideTransitionBeginOffset ?? const Offset(0.8, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case PinAnimationType.rotation:
        return RotationTransition(turns: animation, child: child);
    }
  }
}
