import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

const _red = Color(0xFFFF0000);
const _greenAccent = Color(0xFF69F0AE);

void main() {
  testWidgets('Pins are displayed', (WidgetTester tester) async {
    const length = 4;
    await tester.pumpApp(const Pinput(length: length));

    expect(find.byType(Flexible), findsNWidgets(length));
    expect(find.byType(AnimatedContainer), findsNWidgets(length));
    expect(find.byType(Text), findsNWidgets(length));
  });

  testWidgets('Separators retain their indices and order', (
    WidgetTester tester,
  ) async {
    final indices = <int>[];
    await tester.pumpApp(
      Pinput(
        length: 4,
        itemBuilder: (_, item) => Text('pin-${item.index}'),
        layout: PinLayout(
          separatorBuilder: (context, index) {
            indices.add(index);
            return Text('separator-$index');
          },
        ),
      ),
    );

    expect(indices, [0, 1, 2]);
    expect(
      tester
          .widgetList<Text>(
            find.descendant(of: find.byType(Row), matching: find.byType(Text)),
          )
          .map((text) => text.data),
      [
        'pin-0',
        'separator-0',
        'pin-1',
        'separator-1',
        'pin-2',
        'separator-2',
        'pin-3',
      ],
    );
  });

  testWidgets('Should properly handle states', (WidgetTester tester) async {
    const length = 4;
    final focusNode = FocusNode();
    const defaultTheme = PinTheme(decoration: BoxDecoration(color: _red));
    final focusedTheme = PinTheme(
      decoration: BoxDecoration(color: _greenAccent.withValues(alpha: .9)),
    );
    final submittedTheme = PinTheme(
      decoration: BoxDecoration(color: _greenAccent.withValues(alpha: .8)),
    );
    final followingTheme = PinTheme(
      decoration: BoxDecoration(color: _greenAccent.withValues(alpha: .7)),
    );
    final disabledTheme = PinTheme(
      decoration: BoxDecoration(color: _greenAccent.withValues(alpha: .6)),
    );
    final errorTheme = PinTheme(
      decoration: BoxDecoration(color: _greenAccent.withValues(alpha: .5)),
    );

    await tester.pumpApp(
      Pinput(
        length: length,
        focusNode: focusNode,
        theme: PinThemes(
          fallback: defaultTheme,
          focused: focusedTheme,
          filled: submittedTheme,
          empty: followingTheme,
          disabled: disabledTheme,
          error: errorTheme,
        ),
      ),
    );

    void testState(int count, PinTheme theme) {
      expect(
        find.byWidgetPredicate(
          (w) => w is AnimatedContainer && w.decoration == theme.decoration,
        ),
        findsNWidgets(count),
      );
    }

    // Unfocused
    testState(length, followingTheme);
    testState(0, focusedTheme);
    testState(0, submittedTheme);
    testState(0, errorTheme);
    testState(0, disabledTheme);

    //Focused
    focusNode.requestFocus();
    await tester.pump();

    testState(length - 1, followingTheme);
    testState(1, focusedTheme);
    testState(0, submittedTheme);
    testState(0, errorTheme);
    testState(0, disabledTheme);

    // Focused submitted
    await tester.enterText(find.byType(EditableText), '1');
    await tester.pump();

    testState(length - 2, followingTheme);
    testState(1, focusedTheme);
    testState(1, submittedTheme);
    testState(0, errorTheme);
    testState(0, disabledTheme);

    // UnFocused submitted
    focusNode.unfocus();
    await tester.pump();

    testState(length - 1, followingTheme);
    testState(0, focusedTheme);
    testState(1, submittedTheme);
    testState(0, errorTheme);
    testState(0, disabledTheme);
  });

  testWidgets('Should properly handle focused state', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    const defaultTheme = PinTheme(decoration: BoxDecoration());
    const focusedTheme = PinTheme(decoration: BoxDecoration(color: _red));
    await tester.pumpApp(
      Pinput(
        focusNode: focusNode,
        autofocus: true,
        theme: PinThemes(fallback: defaultTheme, focused: focusedTheme),
      ),
    );

    expect(focusNode.hasFocus, isTrue);

    await tester.pump();
    // Cursor
    expect(find.text('|'), findsOneWidget);

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer && w.decoration == focusedTheme.decoration,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Should display custom cursor', (WidgetTester tester) async {
    await tester.pumpApp(
      const Pinput(
        autofocus: true,
        cursor: PinCursor.blinking(child: FlutterLogo()),
      ),
    );

    await tester.pump();
    expect(find.byType(FlutterLogo), findsOneWidget);
  });

  group('onChanged should work properly', () {
    testWidgets('onChanged should work with controller', (
      WidgetTester tester,
    ) async {
      String? fieldValue;
      int called = 0;

      await tester.pumpApp(
        Pinput(
          onChanged: (value) {
            fieldValue = value;
            called++;
          },
        ),
      );

      expect(fieldValue, isNull);
      expect(called, 0);

      Future<void> checkText(String testValue) async {
        await tester.enterText(find.byType(EditableText), testValue);
        expect(fieldValue, equals(testValue));
      }

      await checkText('123');
      expect(called, 1);

      await checkText('123');
      expect(called, 1);

      await checkText('');
      expect(called, 2);
    });

    testWidgets('onChanged should work with controller', (
      WidgetTester tester,
    ) async {
      String? fieldValue;
      int called = 0;
      final TextEditingController controller = TextEditingController();

      await tester.pumpApp(
        Pinput(
          controller: controller,
          onChanged: (value) {
            fieldValue = value;
            called++;
          },
        ),
      );

      expect(fieldValue, isNull);
      expect(called, 0);

      await tester.enterText(find.byType(EditableText), '11');
      expect(fieldValue, equals('11'));
      expect(called, 1);

      controller.setText('12');
      expect(fieldValue, equals('12'));
      expect(called, 2);

      controller.setText('12');
      expect(fieldValue, equals('12'));
      expect(called, 2);

      controller.clear();
      expect(fieldValue, equals(''));
      expect(called, 3);
    });
  });

  group('onCompleted should work properly', () {
    testWidgets('onCompleted works without controller', (
      WidgetTester tester,
    ) async {
      String? fieldValue;
      int called = 0;

      await tester.pumpApp(
        Pinput(
          length: 4,
          onCompleted: (value) {
            fieldValue = value;
            called++;
          },
        ),
      );

      expect(fieldValue, isNull);
      expect(called, 0);

      await tester.enterText(find.byType(EditableText), '1234');
      expect(fieldValue, equals('1234'));
      expect(called, 1);

      fieldValue = null;
      await tester.enterText(find.byType(EditableText), '123');
      expect(fieldValue, isNull);
      expect(called, 1);
    });

    testWidgets('onCompleted callback is called', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      String? fieldValue;
      int called = 0;

      await tester.pumpApp(
        Pinput(
          length: 4,
          controller: controller,
          onCompleted: (value) {
            fieldValue = value;
            called++;
          },
        ),
      );

      expect(fieldValue, isNull);
      expect(called, 0);

      controller.setText('1234');
      expect(fieldValue, equals('1234'));
      expect(called, 1);

      controller.clear();
      expect(fieldValue, equals('1234'));
      expect(called, 1);

      fieldValue = null;
      await tester.enterText(find.byType(EditableText), '123');
      expect(fieldValue, isNull);
      expect(called, 1);

      // Text over the length is cut, the same as typed text.
      controller.setText('12345');
      expect(fieldValue, equals('1234'));
      expect(called, 2);
    });
  });

  testWidgets('onTap is called upon tap', (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpApp(Pinput(onTap: () => ++tapCount));

    expect(tapCount, 0);
    await tester.tap(find.byType(EditableText));
    // Wait a bit so they're all single taps and not double taps.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tapCount, 3);
  });

  group('context menu on tap', () {
    const menuKey = Key('menu');
    Widget menu(BuildContext context, EditableTextState state) =>
        const SizedBox(key: menuKey, width: 10, height: 10);

    Future<void> tapField(WidgetTester tester) async {
      await tester.tap(find.byType(EditableText));
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets(
      'iOS: tap on a focused field toggles the menu, first tap does not show it',
      (tester) async {
        int tapCount = 0;
        await tester.pumpApp(
          Pinput(contextMenuBuilder: menu, onTap: () => ++tapCount),
        );

        await tapField(tester);
        expect(find.byKey(menuKey), findsNothing);

        await tapField(tester);
        expect(find.byKey(menuKey), findsOneWidget);

        await tapField(tester);
        expect(find.byKey(menuKey), findsNothing);
        expect(tapCount, 3);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'iOS: tapping a pin box toggles the menu when the cursor does not move',
      (tester) async {
        await tester.pumpApp(Pinput(contextMenuBuilder: menu));
        final pin = find.descendant(
          of: find.byType(Pinput),
          matching: find.byType(GestureDetector),
        );
        Future<void> tapPin() async {
          await tester.tapAt(tester.getCenter(pin.first));
          await tester.pump(const Duration(milliseconds: 300));
        }

        await tapPin();
        expect(find.byKey(menuKey), findsNothing);
        await tapPin();
        expect(find.byKey(menuKey), findsOneWidget);
        await tapPin();
        expect(find.byKey(menuKey), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'iOS: moving between gap slots with the same offset does not show the menu',
      (tester) async {
        final controller = TextEditingController(text: '1234');
        await tester.pumpApp(
          Pinput(
            controller: controller,
            contextMenuBuilder: menu,
            closeKeyboardWhenCompleted: false,
          ),
        );
        final pins = find.byType(AnimatedContainer);
        await tester.tap(pins.at(1));
        await tester.pump(const Duration(milliseconds: 300));
        tester.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: '234',
            selection: TextSelection.collapsed(offset: 0),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(controller.text, '134');
        final selection = controller.selection;

        await tester.tap(pins.at(2));
        await tester.pump(const Duration(milliseconds: 300));
        expect(controller.selection, selection);
        expect(find.byKey(menuKey), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'iOS: read-only field with a collapsed cursor does not toggle the menu',
      (tester) async {
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        await tester.pumpApp(
          Pinput(
            focusNode: focusNode,
            inputMode: PinInputMode.readOnly,
            contextMenuBuilder: menu,
          ),
        );
        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        await tapField(tester);
        expect(find.byKey(menuKey), findsNothing);
        await tapField(tester);
        expect(find.byKey(menuKey), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('iOS: no menu when contextMenuBuilder is null', (tester) async {
      await tester.pumpApp(const Pinput(contextMenuBuilder: null));
      await tapField(tester);
      await tapField(tester);
      expect(find.byKey(menuKey), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('iOS: mouse tap does not toggle the menu', (tester) async {
      await tester.pumpApp(Pinput(contextMenuBuilder: menu));
      await tapField(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(EditableText)),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(menuKey), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('Android: tap never shows the menu', (tester) async {
      await tester.pumpApp(Pinput(contextMenuBuilder: menu));
      await tapField(tester);
      await tapField(tester);
      expect(find.byKey(menuKey), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  group('floating cursor (iOS keyboard cursor drag)', () {
    Future<TextEditingController> drag(
      WidgetTester tester,
      PinEditMode mode,
      double dx,
    ) async {
      final controller = TextEditingController(text: '123');
      await tester.pumpApp(Pinput(controller: controller, editMode: mode));
      await tester.tap(find.byType(EditableText));
      await tester.pump(const Duration(milliseconds: 300));
      if (mode != PinEditMode.none) {
        controller.selection = const TextSelection.collapsed(offset: 1);
        await tester.pump();
      }

      final state = tester.state<EditableTextState>(find.byType(EditableText));
      state.updateFloatingCursor(
        RawFloatingCursorPoint(
          state: FloatingCursorDragState.Start,
          offset: Offset.zero,
        ),
      );
      state.updateFloatingCursor(
        RawFloatingCursorPoint(
          state: FloatingCursorDragState.Update,
          offset: Offset(dx, 0),
        ),
      );
      state.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      return controller;
    }

    testWidgets('does not move the cursor', (tester) async {
      for (final mode in [PinEditMode.none, PinEditMode.overwrite]) {
        for (final dx in [-200.0, 200.0]) {
          final controller = await drag(tester, mode, dx);
          expect(
            controller.selection.baseOffset,
            mode == PinEditMode.none ? 3 : 1,
          );
        }
      }
    });

    testWidgets('a press without movement keeps the cursor in place', (
      tester,
    ) async {
      final controller = TextEditingController(text: '123');
      await tester.pumpApp(
        Pinput(controller: controller, editMode: PinEditMode.overwrite),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump(const Duration(milliseconds: 300));
      controller.selection = const TextSelection.collapsed(offset: 1);
      await tester.pump();
      controller.selection = const TextSelection.collapsed(offset: 2);
      await tester.pump();

      final state = tester.state<EditableTextState>(find.byType(EditableText));
      state.updateFloatingCursor(
        RawFloatingCursorPoint(
          state: FloatingCursorDragState.Start,
          offset: Offset.zero,
        ),
      );
      state.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selection.baseOffset, 2);
    });

    testWidgets('keeps PinEditMode.none locked without a previous selection', (
      tester,
    ) async {
      final controller = TextEditingController(text: '123');
      await tester.pumpApp(
        Pinput(controller: controller, editMode: PinEditMode.none),
      );
      expect(controller.selection.isValid, isFalse);

      tester
          .state<EditableTextState>(find.byType(EditableText))
          .userUpdateTextEditingValue(
            controller.value.copyWith(
              selection: const TextSelection.collapsed(offset: 1),
            ),
            SelectionChangedCause.forcePress,
          );
      await tester.pump();

      expect(controller.selection.baseOffset, 3);
    });

    testWidgets(
      'arrow keys still move the cursor in PinEditMode.overwrite',
      (tester) async {
        final controller = TextEditingController(text: '123');
        await tester.pumpApp(
          Pinput(controller: controller, editMode: PinEditMode.overwrite),
        );
        await tester.tap(find.byType(EditableText));
        await tester.pump(const Duration(milliseconds: 300));
        controller.selection = const TextSelection.collapsed(offset: 2);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(controller.selection, const TextSelection.collapsed(offset: 1));
      },
      variant: TargetPlatformVariant(const {
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );
  });

  testWidgets('onTap is not called, field is disabled', (
    WidgetTester tester,
  ) async {
    int tapCount = 0;

    await tester.pumpApp(
      Pinput(inputMode: PinInputMode.disabled, onTap: () => ++tapCount),
    );

    expect(tapCount, 0);
    await tester.tap(find.byType(EditableText), warnIfMissed: false);
    await tester.tap(find.byType(EditableText), warnIfMissed: false);
    expect(tapCount, 0);
  });

  testWidgets('onLongPress is called', (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpApp(Pinput(onLongPress: () => ++tapCount));

    expect(tapCount, 0);
    await tester.longPress(find.byType(EditableText));
    // Wait a bit so they're all single taps and not double taps.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.longPress(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.longPress(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tapCount, 3);
  });

  testWidgets('onSubmitted callback is called', (WidgetTester tester) async {
    String? fieldValue;

    await tester.pumpApp(Pinput(onSubmitted: (value) => fieldValue = value));

    expect(fieldValue, isNull);

    await tester.enterText(find.byType(EditableText), '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(fieldValue, equals('123'));
  });

  testWidgets('Context menu renders with decoupled default toolbar', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController(text: '1234');
    await tester.pumpApp(
      Pinput(
        controller: controller,
        length: 4,
        enableInteractiveSelection: true,
      ),
    );

    // Focus the field
    await tester.tap(find.byType(EditableText));
    await tester.pump();

    // Select text to make toolbar options (Copy, Cut, etc.) available
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);
    await tester.pump();

    final editableTextState = tester.state<EditableTextState>(
      find.byType(EditableText),
    );
    editableTextState.toggleToolbar();
    await tester.pump(const Duration(milliseconds: 300));

    // The decoupled toolbar displays contextual buttons (e.g. Copy, Cut, Select All)
    expect(find.text('Copy'), findsOneWidget);
    final copyText = tester.widget<Text>(find.text('Copy'));
    expect(copyText.style?.decoration, equals(TextDecoration.none));
  });
}
