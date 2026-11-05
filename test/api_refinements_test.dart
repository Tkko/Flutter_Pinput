import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

Decoration? _decoration(WidgetTester tester, [int index = 0]) => tester
    .widget<AnimatedContainer>(find.byType(AnimatedContainer).at(index))
    .decoration;

/// [find.text] also matches the hidden EditableText.
Finder _pinText(String text) => find.descendant(
  of: find.byType(AnimatedContainer),
  matching: find.text(text),
);

void main() {
  group('Default themes', () {
    testWidgets('invalid is visible without a theme', (tester) async {
      await tester.pumpApp(const Pinput());
      final idle = _decoration(tester);
      await tester.pumpApp(
        const Pinput(validationState: PinValidationState.invalid()),
      );
      await tester.pumpAndSettle();
      expect(_decoration(tester), isNot(idle));
    });

    testWidgets('disabled is visible without a theme', (tester) async {
      await tester.pumpApp(const Pinput());
      final idle = _decoration(tester);
      await tester.pumpApp(const Pinput(inputMode: PinInputMode.disabled));
      await tester.pumpAndSettle();
      expect(_decoration(tester), isNot(idle));
    });

    testWidgets('a fallback replaces the built-in state looks', (tester) async {
      const base = PinTheme(width: 10, height: 10);
      await tester.pumpApp(
        const Pinput(
          theme: PinThemes(fallback: base),
          validationState: PinValidationState.invalid(),
        ),
      );
      await tester.pumpAndSettle();
      expect(_decoration(tester), isNull);
    });

    testWidgets('DefaultPinThemes applies unless theme is set', (tester) async {
      const inherited = PinTheme(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: Color(0xFF112233)),
      );
      const own = PinTheme(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: Color(0xFF445566)),
      );
      await tester.pumpApp(
        const DefaultPinThemes(
          themes: PinThemes.all(inherited),
          child: Column(
            children: [
              Pinput(length: 1),
              Pinput(length: 1, theme: PinThemes.all(own)),
            ],
          ),
        ),
      );
      expect(_decoration(tester), inherited.decoration);
      expect(_decoration(tester, 1), own.decoration);
    });
  });

  group('PinTheme', () {
    test('has value equality', () {
      const a = PinTheme(width: 10, textStyle: TextStyle(fontSize: 12));
      const b = PinTheme(width: 10, textStyle: TextStyle(fontSize: 12));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(a.copyWith(width: 11)));
    });

    test('lerp interpolates values and switches the placeholder', () {
      const a = PinTheme(width: 10, placeholder: Text('a'));
      const b = PinTheme(width: 20, placeholder: Text('b'));
      expect(PinTheme.lerp(a, b, 0.5)!.width, 15);
      expect(PinTheme.lerp(a, b, 0.25)!.placeholder, a.placeholder);
      expect(PinTheme.lerp(a, b, 0.75)!.placeholder, b.placeholder);
      expect(PinTheme.lerp(null, null, 0.5), isNull);
    });
  });

  group('Programmatic text', () {
    testWidgets('over-long text is cut to length and completes', (
      tester,
    ) async {
      final controller = TextEditingController();
      final changed = <String>[];
      final completed = <String>[];
      await tester.pumpApp(
        Pinput(
          controller: controller,
          onChanged: changed.add,
          onCompleted: completed.add,
        ),
      );
      controller.setText('12345');
      await tester.pump();

      expect(controller.text, '1234');
      expect(controller.selection.baseOffset, 4);
      expect(changed, ['1234']);
      expect(completed, ['1234']);
      controller.dispose();
    });

    testWidgets('initial over-long text is cut without callbacks', (
      tester,
    ) async {
      final controller = TextEditingController(text: '123456');
      final changed = <String>[];
      await tester.pumpApp(
        Pinput(controller: controller, onChanged: changed.add),
      );
      await tester.pump();

      expect(controller.text, '1234');
      expect(changed, isEmpty);
      controller.dispose();
    });

    testWidgets('shrinking length cuts the text', (tester) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(Pinput(controller: controller));
      await tester.pumpApp(Pinput(controller: controller, length: 2));
      await tester.pump();

      expect(controller.text, '12');
      controller.dispose();
    });
  });

  group('Controller helpers', () {
    test('count user-perceived characters', () {
      final controller = TextEditingController(text: '1😀');
      expect(controller.pinLength, 2);
      controller.deleteLastPin();
      expect(controller.text, '1');
      controller.dispose();
    });

    test('appendPin never exceeds maxLength', () {
      final controller = TextEditingController(text: '12');
      controller.appendPin('345', 4);
      expect(controller.text, '1234');
      controller.appendPin('5', 4);
      expect(controller.text, '1234');
      controller.dispose();
    });
  });

  group('Accessibility', () {
    testWidgets('pin content is only exposed as the value', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController(text: '12');
      await tester.pumpApp(
        Pinput(controller: controller, semanticsLabel: 'Code'),
      );
      final data = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();

      expect(data.label, 'Code');
      expect(data.value, '12');
      controller.dispose();
      handle.dispose();
    });

    testWidgets('validation is exposed and the error stays a live region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        const Pinput(validationState: PinValidationState.invalid('Bad')),
      );
      await tester.pump();

      final field = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();
      expect(field.validationResult, SemanticsValidationResult.invalid);
      expect(
        tester.getSemantics(find.text('Bad')).flagsCollection.isLiveRegion,
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('reduced motion removes animations and blinking', (
      tester,
    ) async {
      final focusNode = FocusNode();
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Pinput(focusNode: focusNode, autofocus: true),
        ),
      );
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(container.duration, Duration.zero);
      expect(
        find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_PinputAnimatedCursor',
        ),
        findsNothing,
      );
      expect(_pinText('|'), findsOneWidget);
      await tester.pumpApp(const SizedBox.shrink());
      focusNode.dispose();
    });
  });

  group('PinItemState', () {
    testWidgets('keeps focus and cursor apart from the type', (tester) async {
      final controller = TextEditingController(text: '12');
      final focusNode = FocusNode();
      final items = <int, PinItemState>{};
      Widget input() => Pinput(
        controller: controller,
        focusNode: focusNode,
        closeKeyboardWhenCompleted: false,
        validationState: const PinValidationState.invalid(),
        itemBuilder: (_, item) {
          items[item.index] = item;
          return const SizedBox(width: 10, height: 10);
        },
      );
      await tester.pumpApp(input());
      focusNode.requestFocus();
      await tester.pump();

      expect(items[2]!.type, PinItemStateType.error);
      expect(items[2]!.isFocused, isTrue);
      expect(items[2]!.showCursor, isTrue);
      expect(items[0]!.isFocused, isFalse);
      expect(items[0]!.isFilled, isTrue);

      controller.setText('1234');
      await tester.pump();
      expect(items[3]!.isFocused, isTrue);
      expect(items[3]!.showCursor, isFalse);
      await tester.pumpApp(const SizedBox.shrink());
      controller.dispose();
      focusNode.dispose();
    });

    test('has value equality', () {
      const a = PinItemState(
        value: '1',
        index: 0,
        type: PinItemStateType.filled,
      );
      const b = PinItemState(
        value: '1',
        index: 0,
        type: PinItemStateType.filled,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('PinKeyboard', () {
    test('compares autofillHints by content', () {
      final a = PinKeyboard(autofillHints: ['one']);
      final b = PinKeyboard(autofillHints: ['one']);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const PinKeyboard(autofillHints: null)));
    });
  });

  group('Small additions', () {
    testWidgets('PinAnimation.custom uses the transition builder', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        Pinput(
          controller: controller,
          animation: PinAnimation.custom(
            transitionBuilder: (child, animation) =>
                SizedBox(key: const ValueKey('custom'), child: child),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('custom')), findsWidgets);
      controller.dispose();
    });

    test('PinCursor compares the blink duration', () {
      expect(const PinCursor.blinking(), const PinCursor.blinking());
      expect(
        const PinCursor.blinking(),
        isNot(const PinCursor.blinking(blinkDuration: Duration(seconds: 1))),
      );
    });

    testWidgets('revealDuration masks a typed pin afterwards', (tester) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        Pinput(
          controller: controller,
          animation: const PinAnimation.none(duration: Duration.zero),
          obscuring: const PinObscuring.character(
            '*',
            Duration(milliseconds: 500),
          ),
        ),
      );
      controller.setText('1');
      await tester.pump();
      expect(_pinText('1'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(_pinText('1'), findsNothing);
      expect(_pinText('*'), findsOneWidget);

      // Several pins at once, like a paste, are never revealed.
      controller.setText('123');
      await tester.pump();
      expect(_pinText('3'), findsNothing);
      controller.dispose();
    });

    testWidgets('PinLayout.textDirection overrides the ambient direction', (
      tester,
    ) async {
      await tester.pumpApp(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Pinput(layout: PinLayout(textDirection: TextDirection.ltr)),
        ),
      );
      final first = tester.getCenter(find.byType(AnimatedContainer).first);
      final last = tester.getCenter(find.byType(AnimatedContainer).last);
      expect(first.dx, lessThan(last.dx));
    });

    testWidgets('builders receive a context', (tester) async {
      BuildContext? separator;
      BuildContext? error;
      await tester.pumpApp(
        Pinput(
          length: 2,
          layout: PinLayout(
            separatorBuilder: (context, _) {
              separator = context;
              return const SizedBox(width: 4);
            },
          ),
          validationState: const PinValidationState.invalid(),
          errorBuilder: (context, _, _) {
            error = context;
            return const SizedBox.shrink();
          },
        ),
      );
      expect(separator, isNotNull);
      expect(error, isNotNull);
    });
  });
}
