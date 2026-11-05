part of '../pinput.dart';

/// Masks filled pins and enables native text obscuring.
@immutable
class PinObscuring {
  /// Masks pins with one UTF-16 code unit, as required by [EditableText].
  ///
  /// With a [revealDuration] the pin the user just typed stays visible for that
  /// long before it is masked.
  const PinObscuring.character([
    String character = '•',
    this.revealDuration = Duration.zero,
  ]) : assert(character.length == 1),
       _character = character,
       _widget = null;

  /// Masks visible pins with [widget], using a bullet for native text obscuring.
  ///
  /// Each filled slot mounts the widget separately, including independent State
  /// for stateful widgets. Do not supply a widget containing a shared GlobalKey.
  ///
  /// With a [revealDuration] the pin the user just typed stays visible for that
  /// long before it is masked.
  const PinObscuring.widget(
    Widget widget, {
    this.revealDuration = Duration.zero,
  }) : _widget = widget,
       _character = '•';

  /// How long a newly typed pin stays visible before it is masked.
  final Duration revealDuration;

  final String _character;
  final Widget? _widget;

  @override
  bool operator ==(Object other) =>
      other is PinObscuring &&
      runtimeType == other.runtimeType &&
      _character == other._character &&
      _widget == other._widget &&
      revealDuration == other.revealDuration;

  @override
  int get hashCode =>
      Object.hash(runtimeType, _character, _widget, revealDuration);
}
