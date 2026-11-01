import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

void main() {
  test('Presentation configurations have non-const value equality', () {
    final slide = PinAnimation.slide(beginOffset: const Offset(0, 0.5));
    final sameSlide = PinAnimation.slide(beginOffset: const Offset(0, 0.5));
    expect(slide, sameSlide);
    expect(slide.hashCode, sameSlide.hashCode);
    expect(slide, isNot(PinAnimation.slide(beginOffset: const Offset(0, 1))));
    expect(PinAnimation.scale(), isNot(PinAnimation.fade()));
    expect(PinAnimation.none(), PinAnimation.none());
    expect(PinAnimation.rotation(), PinAnimation.rotation());
    final mask = PinObscuring.character('*');
    final sameMask = PinObscuring.character('*');
    expect(mask, sameMask);
    expect(mask.hashCode, sameMask.hashCode);
    expect(mask, isNot(PinObscuring.character('#')));
    final widget = SizedBox(width: 8);
    final widgetMask = PinObscuring.widget(widget);
    final sameWidgetMask = PinObscuring.widget(widget);
    expect(widgetMask, sameWidgetMask);
    expect(widgetMask.hashCode, sameWidgetMask.hashCode);
    expect(widgetMask, isNot(PinObscuring.widget(SizedBox(width: 8))));
    expect(widgetMask, isNot(PinObscuring.character()));
  });

  testWidgets('Mounted selection policy follows current widget settings', (
    tester,
  ) async {
    final key = GlobalKey();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    for (final config in [
      (selection: null, readOnly: false, obscured: false, expected: true),
      (selection: false, readOnly: false, obscured: false, expected: false),
      (selection: true, readOnly: true, obscured: true, expected: true),
      (selection: null, readOnly: true, obscured: true, expected: false),
      (selection: null, readOnly: true, obscured: false, expected: true),
      (selection: null, readOnly: false, obscured: true, expected: true),
    ]) {
      await tester.pumpApp(
        Pinput(
          key: key,
          focusNode: focusNode,
          enableInteractiveSelection: config.selection,
          inputMode: config.readOnly
              ? PinInputMode.readOnly
              : PinInputMode.editable,
          obscuring: config.obscured ? const PinObscuring.character() : null,
          cursor: const PinCursor.hidden(),
        ),
      );
      final delegate =
          key.currentState! as TextSelectionGestureDetectorBuilderDelegate;
      expect(delegate.selectionEnabled, config.expected);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).selectionEnabled,
        config.expected,
      );
    }
  });

  testWidgets('Cursor behavior controls visibility and motion independently', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    const cursorKey = ValueKey('custom-cursor');
    const child = SizedBox(key: cursorKey, width: 2, height: 12);
    final cursors = <String, PinCursor>{
      'blinking': const PinCursor.blinking(child: child),
      'static': const PinCursor.static(child: child),
      'hidden': const PinCursor.hidden(),
    };
    for (final entry in cursors.entries) {
      await tester.pumpApp(Pinput(focusNode: focusNode, cursor: entry.value));
      focusNode.requestFocus();
      await tester.pump();
      expect(
        find.byKey(cursorKey),
        entry.key == 'hidden' ? findsNothing : findsOneWidget,
      );
      if (entry.key != 'hidden') {
        expect(
          find.ancestor(
            of: find.byKey(cursorKey),
            matching: find.byType(FadeTransition),
          ),
          entry.key == 'blinking' ? findsOneWidget : findsNothing,
        );
      }
    }
  });

  test(
    'Character masking enforces the native single-code-unit requirement',
    () {
      expect(() => PinObscuring.character(''), throwsAssertionError);
      expect(() => PinObscuring.character('ab'), throwsAssertionError);
    },
  );

  testWidgets('Masking affects visible and native text, not the controller', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1234');
    addTearDown(controller.dispose);
    const maskKey = ValueKey('mask');
    for (final mask in [
      null,
      const PinObscuring.character(),
      const PinObscuring.character('*'),
      const PinObscuring.widget(SizedBox(key: maskKey, width: 8, height: 8)),
    ]) {
      await tester.pumpApp(
        Pinput(
          controller: controller,
          obscuring: mask,
          cursor: const PinCursor.hidden(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, mask != null);
      expect(controller.text, '1234');
      if (mask == null) {
        expect(find.text('1'), findsOneWidget);
      } else {
        expect(find.text('1'), findsNothing);
        if (mask == const PinObscuring.character('*')) {
          expect(editable.obscuringCharacter, '*');
          expect(find.text('*'), findsNWidgets(4));
        } else if (mask == const PinObscuring.character()) {
          expect(editable.obscuringCharacter, '•');
          expect(find.text('•'), findsNWidgets(4));
        } else {
          expect(find.byKey(maskKey), findsNWidgets(4));
          expect(editable.obscuringCharacter, '•');
        }
      }
    }
  });

  testWidgets('Custom item builders retain native obscuring', (tester) async {
    await tester.pumpApp(
      Pinput.builder(
        obscuring: const PinObscuring.character('*'),
        builder: (_, item) => const Text('*'),
      ),
    );
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
    expect(editable.obscuringCharacter, '*');
  });

  testWidgets('Pin animation selects transitions and carries slide offset', (
    tester,
  ) async {
    final animations = <PinAnimation, Type?>{
      const PinAnimation.none(): null,
      const PinAnimation.scale(): ScaleTransition,
      const PinAnimation.fade(): FadeTransition,
      const PinAnimation.rotation(): RotationTransition,
      const PinAnimation.slide(): SlideTransition,
      const PinAnimation.slide(beginOffset: Offset(0, 0.5)): SlideTransition,
    };
    for (final entry in animations.entries) {
      await tester.pumpApp(
        Pinput(pinAnimation: entry.key, cursor: const PinCursor.hidden()),
      );
      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher).first,
      );
      const child = SizedBox();
      final transition = switcher.transitionBuilder(
        child,
        const AlwaysStoppedAnimation(0),
      );
      if (entry.value == null) {
        expect(transition, same(child));
      } else {
        expect(transition.runtimeType, entry.value);
      }
      if (transition is SlideTransition) {
        expect(
          transition.position.value,
          entry.key == const PinAnimation.slide()
              ? const Offset(0.8, 0)
              : const Offset(0, 0.5),
        );
      }
    }
  });

  testWidgets('Null context menu preserves selection without showing toolbar', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1234');
    addTearDown(controller.dispose);
    await tester.pumpApp(
      Pinput(
        controller: controller,
        enableInteractiveSelection: true,
        contextMenuBuilder: null,
        cursor: const PinCursor.hidden(),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);
    final editable = tester.state<EditableTextState>(find.byType(EditableText));
    expect(editable.widget.selectionEnabled, isTrue);
    editable.showToolbar();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Copy'), findsNothing);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 4),
    );
  });

  testWidgets('Disabled interactive selection prevents gesture menus', (
    tester,
  ) async {
    int menus = 0;
    await tester.pumpApp(
      Pinput(
        enableInteractiveSelection: false,
        cursor: const PinCursor.hidden(),
        contextMenuBuilder: (_, _) {
          menus++;
          return const Text('Custom menu');
        },
      ),
    );
    await tester.longPress(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    expect(menus, 0);
    expect(find.text('Custom menu'), findsNothing);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).selectionEnabled,
      isFalse,
    );
  });

  testWidgets('Selection shortcuts follow enablement, not menu availability', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1234');
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    for (final enabled in [true, false]) {
      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          enableInteractiveSelection: enabled,
          contextMenuBuilder: null,
          cursor: const PinCursor.hidden(),
        ),
      );
      focusNode.requestFocus();
      controller.selection = const TextSelection.collapsed(offset: 4);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      expect(
        controller.selection,
        enabled
            ? const TextSelection(baseOffset: 0, extentOffset: 4)
            : const TextSelection.collapsed(offset: 4),
      );
    }
  }, variant: TargetPlatformVariant({TargetPlatform.macOS}));

  group('PinThemes', () {
    const initial = PinTheme(width: 1);
    const focused = PinTheme(width: 2);

    test('named parameters fall back to the initial theme', () {
      const themes = PinThemes(initial: initial, focused: focused);
      expect(themes.resolve(PinItemStateType.focused), focused);
      expect(themes.resolve(PinItemStateType.error), initial);
    });

    test('all and resolveWith resolve per state', () {
      expect(
        const PinThemes.all(focused).resolve(PinItemStateType.following),
        focused,
      );
      final themes = PinThemes.resolveWith(
        (state) => state == PinItemStateType.error ? focused : initial,
      );
      expect(themes.resolve(PinItemStateType.error), focused);
      expect(themes.resolve(PinItemStateType.submitted), initial);
    });

    testWidgets(
      'placeholder shows in empty pins and duration is configurable',
      (tester) async {
        const key = ValueKey('placeholder');
        await tester.pumpApp(
          const Pinput(
            length: 3,
            cursor: PinCursor.hidden(),
            pinAnimation: PinAnimation.fade(duration: Duration(seconds: 1)),
            theme: PinThemes.all(PinTheme(placeholder: SizedBox(key: key))),
          ),
        );
        expect(find.byKey(key), findsNWidgets(3));
        expect(
          tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer).first)
              .duration,
          const Duration(seconds: 1),
        );
      },
    );
  });

  testWidgets('customKeyboard is not focusable and mirrors programmatic text', (
    tester,
  ) async {
    final focusNode = FocusNode();
    final controller = TextEditingController(text: '12');
    addTearDown(focusNode.dispose);
    addTearDown(controller.dispose);
    await tester.pumpApp(
      Pinput(
        focusNode: focusNode,
        controller: controller,
        inputMode: PinInputMode.customKeyboard,
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
