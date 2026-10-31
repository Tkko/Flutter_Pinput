import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

void main() {
  group('PinEditMode.overwrite (default)', () {
    testWidgets('Tapping a previous pin focuses that pin', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.overwrite,
        ),
      );

      final containers = find.byType(AnimatedContainer);
      expect(containers, findsNWidgets(4));

      // Tap pin at index 1 (digit '2')
      await tester.tap(containers.at(1));
      await tester.pump();

      expect(controller.selection.baseOffset, equals(1));
    });

    testWidgets('Tapping an empty pin clamps to the next empty slot', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '12');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.overwrite,
        ),
      );

      final containers = find.byType(AnimatedContainer);
      expect(containers, findsNWidgets(4));

      // Tap pin at index 3 (which is empty since text length is 2)
      await tester.tap(containers.at(3));
      await tester.pump();

      expect(controller.selection.baseOffset, equals(2));
      expect(controller.selection.isCollapsed, isTrue);
    });

    testWidgets('Typing on a selected previous pin overwrites in-place and advances', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.overwrite,
        ),
      );

      final containers = find.byType(AnimatedContainer);

      // Tap index 1 (which holds '2')
      await tester.tap(containers.at(1));
      await tester.pump();
      expect(controller.selection.baseOffset, equals(1));

      // Type '9' via enterText
      await tester.enterText(find.byType(EditableText), '1934');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(controller.text, equals('1934'));
      expect(find.text('9'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('Pin theme states when editing a previous pin', (
      WidgetTester tester,
    ) async {
      const red = Color(0xFFFF0000);
      const green = Color(0xFF00FF00);
      const blue = Color(0xFF0000FF);

      const defaultTheme = PinTheme(decoration: BoxDecoration(color: red));
      final focusedTheme = defaultTheme.copyDecorationWith(color: green);
      final submittedTheme = defaultTheme.copyDecorationWith(color: blue);

      final controller = TextEditingController(text: '1234');
      final focusNode = FocusNode();

      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          length: 4,
          defaultPinTheme: defaultTheme,
          focusedPinTheme: focusedTheme,
          submittedPinTheme: submittedTheme,
          pinEditMode: PinEditMode.overwrite,
          closeKeyboardWhenCompleted: false,
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      final containers = find.byType(AnimatedContainer);

      // Tap pin 1
      await tester.tap(containers.at(1));
      await tester.pump();

      // Pin 1 must have focused theme (green)
      final pin1 = tester.widget<AnimatedContainer>(containers.at(1));
      expect(pin1.decoration, equals(focusedTheme.decoration));

      // Pin 0, 2, 3 must retain submitted theme (blue)
      final pin0 = tester.widget<AnimatedContainer>(containers.at(0));
      final pin2 = tester.widget<AnimatedContainer>(containers.at(2));
      final pin3 = tester.widget<AnimatedContainer>(containers.at(3));

      expect(pin0.decoration, equals(submittedTheme.decoration));
      expect(pin2.decoration, equals(submittedTheme.decoration));
      expect(pin3.decoration, equals(submittedTheme.decoration));
    });

    testWidgets('Pinput.builder supports pin tap with pinEditMode', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      int? tappedIndex;

      await tester.pumpApp(
        Pinput.builder(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.overwrite,
          builder: (context, state) {
            return Text(
              '${state.index}:${state.value}',
              key: ValueKey(state.index),
            );
          },
          onTap: () => tappedIndex = controller.selection.baseOffset,
        ),
      );

      // Tap the item for index 2
      await tester.tap(find.byKey(const ValueKey(2)));
      await tester.pump();

      expect(controller.selection.baseOffset, equals(2));
      expect(tappedIndex, equals(2));
    });

    testWidgets('Overwrites digit in-place through testTextInput', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.overwrite,
          closeKeyboardWhenCompleted: false,
        ),
      );

      final containers = find.byType(AnimatedContainer);
      await tester.tap(containers.at(1));
      await tester.pump();

      // Platform sends '19234' with cursor at 2 when user types '9' at offset 1
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '19234',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.text, equals('1934'));
      expect(controller.selection.baseOffset, equals(2));
    });

    testWidgets('Pasting full code replaces text from the start', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.overwrite,
          closeKeyboardWhenCompleted: false,
        ),
      );

      final containers = find.byType(AnimatedContainer);
      await tester.tap(containers.at(1));
      await tester.pump();

      // Paste '5678'
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '15678234',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.text, equals('5678'));
    });

    testWidgets('Does not close keyboard when editing in the middle', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      final focusNode = FocusNode();

      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          length: 4,
          closeKeyboardWhenCompleted: true,
          pinEditMode: PinEditMode.overwrite,
        ),
      );

      final containers = find.byType(AnimatedContainer);
      await tester.tap(containers.at(1));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      // Type '9' into slot 1
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '19234',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Cursor is at offset 2 (middle), keyboard should remain open!
      expect(controller.selection.baseOffset, equals(2));
      expect(focusNode.hasFocus, isTrue);
    });
  });

  group('PinEditMode.clearFollowing', () {
    testWidgets('Preserves pins on tap, but truncates following pins upon typing', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      final focusNode = FocusNode();
      int completedCount = 0;

      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          length: 4,
          pinEditMode: PinEditMode.clearFollowing,
          onCompleted: (_) => completedCount++,
        ),
      );

      final containers = find.byType(AnimatedContainer);

      // Tap slot 1 ('2')
      await tester.tap(containers.at(1));
      await tester.pump();

      // On tap: digits are still preserved!
      expect(controller.text, equals('1234'));
      expect(controller.selection.baseOffset, equals(1));
      expect(completedCount, equals(0));

      // Type '9' into slot 1
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '19234',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Following digits '3' and '4' were cleared! Text is now '19'
      expect(controller.text, equals('19'));
      expect(controller.selection.baseOffset, equals(2));

      // onCompleted did NOT fire because length is only 2 of 4!
      expect(completedCount, equals(0));

      // Now type '5' into slot 2
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '195',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.text, equals('195'));
      expect(completedCount, equals(0));

      // Now type '6' into slot 3 (final slot)
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '1956',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Now onCompleted fires naturally!
      expect(controller.text, equals('1956'));
      expect(completedCount, equals(1));
    });
  });

  group('Edge cases / regressions', () {
    testWidgets('Whole-value replacement (autofill) is not treated as an insertion', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(Pinput(controller: controller, length: 6));
      await tester.tap(find.byType(AnimatedContainer).at(1));
      await tester.pump();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '567890',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(controller.text, equals('567890'));
    });

    testWidgets('readOnly pin tap still calls onTap and keeps the selection', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      int taps = 0;
      await tester.pumpApp(
        Pinput(
          controller: controller,
          readOnly: true,
          length: 4,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.byType(AnimatedContainer).at(1));
      await tester.pump(const Duration(milliseconds: 300));

      expect(taps, equals(1));
      expect(controller.selection.baseOffset, isNot(equals(1)));
    });

    testWidgets('Pinput.builder works when the builder returns Expanded', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(
        Pinput.builder(
          length: 4,
          builder: (context, s) => Expanded(child: Text('${s.index}')),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Tapping a separator does not move the cursor', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          separatorBuilder: (_) => const SizedBox(width: 40),
        ),
      );
      final first = tester.getRect(find.byType(AnimatedContainer).at(0));
      final second = tester.getRect(find.byType(AnimatedContainer).at(1));
      await tester.tapAt(
        Offset((first.right + second.left) / 2, first.center.dy),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.selection.baseOffset, equals(4));
    });
  });

  group('onCompleted only when the cursor is at the end', () {
    testWidgets('Editing a middle pin of a full PIN does not call onCompleted', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      final focusNode = FocusNode();
      int completed = 0;
      String? validated;
      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          length: 4,
          onCompleted: (_) => completed++,
          validator: (v) {
            validated = v;
            return null;
          },
        ),
      );
      await tester.tap(find.byType(AnimatedContainer).at(0));
      await tester.pump();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '91234',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.text, equals('9234'));
      expect(completed, equals(0));
      // Validation still runs so the error state does not go stale.
      expect(validated, equals('9234'));
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('Editing the last pin of a full PIN calls onCompleted', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      int completed = 0;
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          onCompleted: (_) => completed++,
        ),
      );
      await tester.tap(find.byType(AnimatedContainer).at(3));
      await tester.pump();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '12394',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.text, equals('1239'));
      expect(completed, equals(1));
    });
  });

  group('Selection edge cases', () {
    testWidgets('Range selection uses its leading edge, even when backwards', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      final focusNode = FocusNode();
      const red = Color(0xFFFF0000);
      const green = Color(0xFF00FF00);
      const base = PinTheme(decoration: BoxDecoration(color: red));
      final focused = base.copyDecorationWith(color: green);
      await tester.pumpApp(
        Pinput(
          controller: controller,
          focusNode: focusNode,
          length: 4,
          defaultPinTheme: base,
          focusedPinTheme: focused,
          closeKeyboardWhenCompleted: false,
        ),
      );
      focusNode.requestFocus();
      await tester.pump();

      // Backwards range 3 -> 1: leading edge is 1.
      controller.selection = const TextSelection(baseOffset: 3, extentOffset: 1);
      await tester.pump();

      final pin1 = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).at(1),
      );
      expect(pin1.decoration, equals(focused.decoration));
    });

    testWidgets('Moving the cursor between filled pins keeps digits visible', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(controller: controller, length: 4, closeKeyboardWhenCompleted: false),
      );
      final containers = find.byType(AnimatedContainer);
      await tester.tap(containers.at(0));
      await tester.pump();
      await tester.tap(containers.at(2));
      await tester.pump();

      // No transition is replayed, so exactly one Text per digit exists right away.
      for (final d in ['1', '2', '3', '4']) {
        expect(find.text(d), findsOneWidget);
      }
    });
  });

  group('PinEditMode.none', () {
    testWidgets('Tapping previous pin does not change selection to that pin', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          length: 4,
          pinEditMode: PinEditMode.none,
        ),
      );

      final containers = find.byType(AnimatedContainer);

      // Tap pin at index 1
      await tester.tap(containers.at(1));
      await tester.pump();

      // Selection must remain clamped to the end (4)
      expect(controller.selection.baseOffset, equals(4));
    });
  });
}
