import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platforms = TargetPlatformVariant({
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  });
  String? clipboardText;
  setUp(() {
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              clipboardText = (call.arguments as Map)['text'] as String?;
              return null;
            case 'Clipboard.getData':
              return {'text': clipboardText};
            case 'Clipboard.hasStrings':
              return {'value': clipboardText?.isNotEmpty ?? false};
            default:
              return null;
          }
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  for (final mode in PinEditMode.values) {
    testWidgets('Copy and cut operate on the selected PIN in $mode', (
      tester,
    ) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          pinEditMode: mode,
          enableInteractiveSelection: true,
          closeKeyboardWhenCompleted: false,
        ),
      );
      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      Future<void> showMenu() async {
        tester
            .state<EditableTextState>(find.byType(EditableText))
            .userUpdateTextEditingValue(
              controller.value.copyWith(
                selection: const TextSelection(baseOffset: 0, extentOffset: 4),
              ),
              SelectionChangedCause.keyboard,
            );
        await tester.pump();
        tester
            .state<EditableTextState>(find.byType(EditableText))
            .showToolbar();
        await tester.pump(const Duration(milliseconds: 300));
      }

      await showMenu();
      await tester.tap(find.text('Copy'));
      await tester.pump();
      expect(clipboardText, '1234');
      expect(controller.text, '1234');

      await showMenu();
      await tester.tap(find.text('Cut'));
      await tester.pump();
      expect(clipboardText, '1234');
      expect(controller.text, '');
      expect(controller.selection.baseOffset, 0);
    }, variant: platforms);

    testWidgets('Select all and paste replace the selected PIN in $mode', (
      tester,
    ) async {
      clipboardText = '9876';
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          pinEditMode: mode,
          enableInteractiveSelection: true,
          closeKeyboardWhenCompleted: false,
        ),
      );
      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final editable = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      editable.userUpdateTextEditingValue(
        controller.value.copyWith(
          selection: const TextSelection.collapsed(offset: 4),
        ),
        SelectionChangedCause.keyboard,
      );
      await tester.pump();
      editable.showToolbar();
      await tester.pump(const Duration(milliseconds: 300));
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        expect(find.text('Select all'), findsNothing);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      } else {
        await tester.tap(find.text('Select all'));
      }
      await tester.pump();
      expect(controller.selection.start, 0);
      expect(controller.selection.end, 4);

      editable.showToolbar();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Paste'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(controller.text, '9876');
      expect(controller.selection.baseOffset, 4);
      for (final digit in ['9', '8', '7', '6']) {
        expect(find.text(digit), findsOneWidget);
      }
    }, variant: platforms);
  }

  testWidgets('Long pressing a visible pin opens the selection toolbar', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1234');
    await tester.pumpApp(
      Pinput(
        controller: controller,
        enableInteractiveSelection: true,
        closeKeyboardWhenCompleted: false,
      ),
    );
    await tester.longPress(find.byType(AnimatedContainer).at(1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.selection.isCollapsed, isFalse);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets(
    'Cutting a backwards partial selection preserves unselected text',
    (tester) async {
      final controller = TextEditingController(text: '1234');
      await tester.pumpApp(
        Pinput(
          controller: controller,
          enableInteractiveSelection: true,
          closeKeyboardWhenCompleted: false,
        ),
      );
      await tester.tap(find.byType(AnimatedContainer).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      tester
          .state<EditableTextState>(find.byType(EditableText))
          .userUpdateTextEditingValue(
            controller.value.copyWith(
              selection: const TextSelection(baseOffset: 3, extentOffset: 1),
            ),
            SelectionChangedCause.keyboard,
          );
      await tester.pump();
      tester.state<EditableTextState>(find.byType(EditableText)).showToolbar();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Cut'));
      await tester.pump();
      expect(clipboardText, '23');
      expect(controller.text, '14');
      expect(controller.selection.baseOffset, 1);
    },
  );
}
