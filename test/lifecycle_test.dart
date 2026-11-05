import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import 'helpers/helpers.dart';

void main() {
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
