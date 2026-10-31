part of '../pinput.dart';

class _PinItem extends StatelessWidget {
  final _PinputState state;
  final int index;

  const _PinItem({required this.state, required this.index});

  @override
  Widget build(BuildContext context) {
    final pinTheme = _pinTheme(index);

    final item = AnimatedContainer(
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
    );

    return Flexible(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => state._onPinTap(index),
        child: item,
      ),
    );
  }

  PinTheme _pinTheme(int index) {
    final pintState = state._getState(index);
    switch (pintState) {
      case PinItemStateType.initial:
        return _getDefaultPinTheme();
      case PinItemStateType.focused:
        return _pinThemeOrDefault(state.widget.focusedPinTheme);
      case PinItemStateType.submitted:
        return _pinThemeOrDefault(state.widget.submittedPinTheme);
      case PinItemStateType.following:
        return _pinThemeOrDefault(state.widget.followingPinTheme);
      case PinItemStateType.disabled:
        return _pinThemeOrDefault(state.widget.disabledPinTheme);
      case PinItemStateType.error:
        return _pinThemeOrDefault(state.widget.errorPinTheme);
    }
  }

  PinTheme _getDefaultPinTheme() =>
      state.widget.defaultPinTheme ?? PinputConstants._defaultPinTheme;

  PinTheme _pinThemeOrDefault(PinTheme? theme) =>
      theme ?? _getDefaultPinTheme();

  Widget _buildFieldContent(int index, PinTheme pinTheme) {
    final pin = state.pin;
    final key = ValueKey<String>(index < pin.length ? pin[index] : '');
    final isSubmittedPin = index < pin.length;

    final isActiveField = state.widget.pinEditMode != PinEditMode.none
        ? index == state.selectedIndex
        : index == pin.length;
    final focused =
        state._effectiveFocusNode.hasFocus || !state.widget.useNativeKeyboard;
    final shouldShowCursor =
        state.widget.showCursor && state.isEnabled && isActiveField && focused;

    if (isSubmittedPin) {
      final Widget characterWidget;
      if (state.widget.obscureText && state.widget.obscuringWidget != null) {
        characterWidget = SizedBox(key: key, child: state.widget.obscuringWidget);
      } else {
        characterWidget = Text(
          state.widget.obscureText ? state.widget.obscuringCharacter : pin[index],
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
