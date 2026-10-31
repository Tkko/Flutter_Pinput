import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

class _PendingSmsRetriever implements SmsRetriever {
  final result = Completer<String?>();
  int requests = 0;
  int disposals = 0;

  @override
  bool get listenForMultipleSms => true;

  @override
  Future<String?> getSmsCode() {
    requests++;
    return result.future;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

void main() {
  testWidgets('Late SMS results do not update or restart after disposal', (
    tester,
  ) async {
    final retriever = _PendingSmsRetriever();
    final controller = TextEditingController();
    await tester.pumpApp(
      Pinput(controller: controller, smsRetriever: retriever),
    );
    await tester.pumpApp(const SizedBox.shrink());
    retriever.result.complete('1234');
    await tester.pump();

    expect(controller.text, '');
    expect(retriever.requests, 1);
    expect(retriever.disposals, 1);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  for (final removeWidget in [false, true]) {
    testWidgets('Pending clipboard is ignored after removal: $removeWidget', (
      tester,
    ) async {
      final result = Completer<Object?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') return result.future;
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });
      var callbacks = 0;
      await tester.pumpApp(Pinput(onClipboardFound: (_) => callbacks++));
      await tester.pumpApp(
        removeWidget ? const SizedBox.shrink() : const Pinput(),
      );
      result.complete({'text': '1234'});
      await tester.pump();

      expect(callbacks, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Replacing a controller does not turn selection into text change',
    (tester) async {
      final first = TextEditingController(text: '12');
      final second = TextEditingController(text: '5678');
      var changes = 0;
      var completions = 0;
      Widget input(TextEditingController controller) => Pinput(
        controller: controller,
        onChanged: (_) => changes++,
        onCompleted: (_) => completions++,
      );
      await tester.pumpApp(input(first));
      await tester.pumpApp(input(second));
      second.selection = const TextSelection.collapsed(offset: 4);
      await tester.pump();
      first.text = '99';
      await tester.pump();

      expect(changes, 0);
      expect(completions, 0);
      expect(second.text, '5678');
      await tester.pumpApp(const SizedBox.shrink());
      first.dispose();
      second.dispose();
    },
  );
}
