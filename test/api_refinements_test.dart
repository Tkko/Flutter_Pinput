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

    test(
      'lerp keeps custom decoration interpolation within its generic type',
      () {
        const aDecoration = _TestDecoration(1);
        const bDecoration = _TestDecoration(2);
        const a = PinTheme<_TestDecoration>(decoration: aDecoration);
        const b = PinTheme<_TestDecoration>(decoration: bDecoration);

        expect(PinTheme.lerp(a, b, 0.25)?.decoration, same(aDecoration));
        expect(PinTheme.lerp(a, b, 0.75)?.decoration, same(bDecoration));
      },
    );
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
          length: 4,
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
        Pinput(length: 4, controller: controller, onChanged: changed.add),
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
        length: 4,
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
          animation: const PinAnimation.none(),
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

    test('PinThemes has value equality and toString', () {
      const a = PinThemes(fallback: PinTheme(width: 10));
      const b = PinThemes(fallback: PinTheme(width: 10));
      const c = PinThemes(fallback: PinTheme(width: 12));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));

      expect(a.toString(), contains('PinThemes(fallback:'));

      const allA = PinThemes.all(PinTheme(width: 10));
      const allB = PinThemes.all(PinTheme(width: 10));
      expect(allA, allB);
      expect(allA.hashCode, allB.hashCode);
      expect(
        allA.toString(),
        'PinThemes.all(PinTheme(width: 10.0, height: null, textStyle: null, margin: null, padding: null, constraints: null, decoration: null, placeholder: null, alignment: null))',
      );

      final resolver = PinThemes.resolveWith((item, _) => PinTheme.defaults);
      expect(resolver.toString(), 'PinThemes.resolveWith(...)');
    });

    test('PinTheme toString and decoration copyWith', () {
      const base = PinTheme(
        decoration: BoxDecoration(color: Color(0xFF112233)),
      );
      final withBorder = base.copyWith(
        decoration: (base.decoration as BoxDecoration).copyWith(
          border: const BorderDirectional(
            start: BorderSide(color: Color(0xFF00FF00)),
          ),
        ),
      );
      expect(withBorder.decoration, isA<BoxDecoration>());
      expect(
        (withBorder.decoration as BoxDecoration).border,
        isA<BorderDirectional>(),
      );
      expect(base.toString(), contains('PinTheme(width:'));
    });

    test('PinValidationState toString', () {
      const idle = PinValidationState.idle();
      const validating = PinValidationState.validating();
      const valid = PinValidationState.valid();
      const invalid = PinValidationState.invalid('Failed');
      const invalidNoMsg = PinValidationState.invalid();

      expect(idle.toString(), 'PinValidationState.idle()');
      expect(validating.toString(), 'PinValidationState.validating()');
      expect(valid.toString(), 'PinValidationState.valid()');
      expect(invalid.toString(), 'PinValidationState.invalid(Failed)');
      expect(invalidNoMsg.toString(), 'PinValidationState.invalid()');
    });

    test('PinItemState copyWith and toString', () {
      const filled = PinItemState(
        value: '1',
        index: 0,
        type: PinItemStateType.filled,
      );
      const empty = PinItemState(
        value: '',
        index: 1,
        type: PinItemStateType.empty,
      );

      expect(filled.isFilled, isTrue);
      expect(empty.isFilled, isFalse);
      expect(filled.toString(), contains('PinItemState(value: 1, index: 0'));
    });

    test('PinLayout copyWith and toString', () {
      const layout = PinLayout(mainAxisAlignment: MainAxisAlignment.start);
      final copy = layout.copyWith(
        crossAxisAlignment: CrossAxisAlignment.center,
      );
      expect(copy.mainAxisAlignment, MainAxisAlignment.start);
      expect(copy.crossAxisAlignment, CrossAxisAlignment.center);
      expect(layout.toString(), contains('PinLayout(mainAxisAlignment:'));
    });

    test('PinKeyboard copyWith and toString', () {
      const kb = PinKeyboard(keyboardType: TextInputType.phone);
      final copy = kb.copyWith(enableSuggestions: false);
      expect(copy.keyboardType, TextInputType.phone);
      expect(copy.enableSuggestions, isFalse);
      expect(kb.toString(), contains('PinKeyboard(keyboardType:'));
    });

    test('PinAnimation getters and toString', () {
      const scale = PinAnimation.scale();
      expect(scale.toString(), contains('PinAnimation.scale'));

      const slide = PinAnimation.slide(beginOffset: Offset(0.5, 0.5));
      expect(slide.toString(), contains('PinAnimation.slide'));
    });

    test('PinCursor toString', () {
      const blinking = PinCursor.blinking(
        blinkDuration: Duration(milliseconds: 300),
      );
      expect(blinking.toString(), contains('PinCursor.blinking'));

      const staticCursor = PinCursor.static(child: SizedBox());
      expect(staticCursor.toString(), contains('PinCursor.static'));

      const hidden = PinCursor.hidden();
      expect(hidden.toString(), 'PinCursor.hidden()');
    });

    test('PinObscuring copyWith and toString', () {
      const char = PinObscuring.character('*', Duration(milliseconds: 200));
      expect(char.revealDuration, const Duration(milliseconds: 200));
      expect(char.toString(), contains('PinObscuring.character(*'));

      final copyChar = char.copyWith(
        character: '#',
        revealDuration: const Duration(milliseconds: 400),
      );
      expect(copyChar, isNot(char));
      expect(copyChar.revealDuration, const Duration(milliseconds: 400));
      expect(copyChar.toString(), contains('PinObscuring.character(#'));

      const widgetObs = PinObscuring.widget(
        SizedBox(),
        revealDuration: Duration(milliseconds: 100),
      );
      expect(widgetObs.toString(), contains('PinObscuring.widget'));

      final copyWidget = widgetObs.copyWith(
        revealDuration: const Duration(milliseconds: 500),
      );
      expect(copyWidget, isNot(widgetObs));
      expect(copyWidget.revealDuration, const Duration(milliseconds: 500));
    });

    test('PinTheme<T> and PinThemes<T> preserve generic Decoration type T', () {
      const boxTheme = PinTheme<BoxDecoration>(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
      );

      final updated = boxTheme.copyWith(
        decoration: boxTheme.decoration?.copyWith(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(8),
        ),
      );

      expect(updated.decoration?.color, const Color(0xFF000000));
      expect(updated.decoration?.borderRadius, BorderRadius.circular(8));
      expect(updated.width, 50);

      const shapeTheme = PinTheme<ShapeDecoration>(
        width: 50,
        height: 50,
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          color: Color(0xFFEEEEEE),
        ),
      );
      expect(shapeTheme.decoration?.shape, isA<CircleBorder>());

      final lerped = PinTheme.lerp<Decoration>(boxTheme, shapeTheme, 0.5);
      expect(lerped, isNotNull);
      expect(lerped?.width, 50);

      final boxThemes = PinThemes<BoxDecoration>(
        fallback: boxTheme,
        focused: updated,
      );
      final PinTheme<BoxDecoration> resolvedBox = boxThemes.resolve(
        PinItemState(index: 0, value: '', type: PinItemStateType.focused),
        const PinValidationState.idle(),
      );
      expect(resolvedBox.decoration?.color, const Color(0xFF000000));

      final anyThemes = PinThemes<Decoration>(
        fallback: boxTheme,
        focused: shapeTheme,
      );
      expect(
        anyThemes
            .resolve(
              PinItemState(index: 0, value: '', type: PinItemStateType.focused),
              const PinValidationState.idle(),
            )
            .decoration,
        isA<ShapeDecoration>(),
      );
      expect(
        anyThemes
            .resolve(
              PinItemState(index: 0, value: '', type: PinItemStateType.empty),
              const PinValidationState.idle(),
            )
            .decoration,
        isA<BoxDecoration>(),
      );
    });

    test('PinThemes uses only default decorations compatible with T', () {
      final boxThemes = PinThemes<BoxDecoration>();
      final boxTheme = boxThemes.resolve(
        PinItemState(index: 0, value: '', type: PinItemStateType.focused),
        const PinValidationState.idle(),
      );
      expect(boxTheme.decoration, isA<BoxDecoration>());

      final shapeThemes = PinThemes<ShapeDecoration>();
      final shapeTheme = shapeThemes.resolve(
        PinItemState(index: 0, value: '', type: PinItemStateType.focused),
        const PinValidationState.idle(),
      );
      expect(shapeTheme.width, 56);
      expect(shapeTheme.decoration, isNull);
    });
  });
}

class _TestDecoration extends Decoration {
  const _TestDecoration(this.value);

  final int value;

  @override
  Decoration? lerpFrom(Decoration? a, double t) => const BoxDecoration();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      throw UnimplementedError();
}
