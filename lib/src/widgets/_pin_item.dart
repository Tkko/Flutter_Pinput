part of '../pinput.dart';

class _PinItem extends StatelessWidget {
  final _PinputState state;
  final int index;

  _PinItem({required this.state, required this.index});

  @override
  Widget build(BuildContext context) {
    final pinTheme = _pinTheme(index);

    return Flexible(
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
          transitionBuilder: (child, animation) {
            return _getTransition(child, animation);
          },
          child: _buildFieldContent(index, pinTheme),
        ),
      ),
    );
  }

  PinTheme _pinTheme(int index) {
    /// Disabled pin or default
    if (!state.isEnabled) {
      return _pinThemeOrDefault(state.widget.disabledPinTheme);
    }

    if (state.showErrorState) {
      return _pinThemeOrDefault(state.widget.errorPinTheme);
    }

    /// Focused pin or default
    if (state.hasFocus &&
        index == state.selectedIndex.clamp(0, state.widget.length - 1)) {
      return _pinThemeOrDefault(state.widget.focusedPinTheme);
    }

    /// Submitted pin or default
    if (index < state.selectedIndex) {
      return _pinThemeOrDefault(state.widget.submittedPinTheme);
    }

    /// Following pin or default
    return _pinThemeOrDefault(state.widget.followingPinTheme);
  }

  PinTheme _getDefaultPinTheme() =>
      state.widget.defaultPinTheme ?? _defaultPinTheme;

  PinTheme _pinThemeOrDefault(PinTheme? theme) =>
      theme ?? _getDefaultPinTheme();

  Widget _buildFieldContent(int index, PinTheme pinTheme) {
    final pin = state.pin;
    final key = ValueKey<String>(index < pin.length ? pin[index] : '');
    final isSubmittedPin = index < pin.length;

    if (isSubmittedPin) {
      if (state.widget.obscureText && state.widget.obscuringWidget != null) {
        return SizedBox(key: key, child: state.widget.obscuringWidget);
      }

      return Text(
        state.widget.obscureText ? state.widget.obscuringCharacter : pin[index],
        key: key,
        style: pinTheme.textStyle,
      );
    }

    final isActiveField = index == pin.length;
    final focused =
        state.effectiveFocusNode.hasFocus || !state.widget.useNativeKeyboard;

    if (state.widget.showCursor &&
        state.isEnabled &&
        isActiveField &&
        focused) {
      return _PinputCursor(
          textStyle: pinTheme.textStyle, cursor: state.widget.cursor);
    }

    if (state.widget.preFilledWidget != null) {
      return SizedBox(key: key, child: state.widget.preFilledWidget);
    }

    return Text('', key: key, style: pinTheme.textStyle);
  }

  Widget _getTransition(Widget child, Animation animation) {
    if (child is _PinputCursor) {
      return child;
    }

    switch (state.widget.pinAnimationType) {
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
            begin: state.widget.slideTransitionBeginOffset ?? Offset(0.8, 0),
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
