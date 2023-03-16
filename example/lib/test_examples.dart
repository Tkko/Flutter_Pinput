import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class Issue129 extends StatelessWidget {
  const Issue129({Key? key}) : super(key: key);
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Pinput(
  //     androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
  //     controller: otpController,
  //     autofocus: true,
  //     length: 6,
  //     autofillHints: const [AutofillHints.oneTimeCode],
  //     defaultPinTheme: defaultPinTheme,
  //     focusedPinTheme: focusedPinTheme,
  //     submittedPinTheme: submittedPinTheme,
  //     validator: (value) {
  //       if (value!.length != 6) {
  //         return "Invalid OTP";
  //       } else {
  //         return null;
  //       }
  //     },
  //     pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
  //     showCursor: true,
  //     onCompleted: (pin) => handleSubmit(context),
  //     onSubmitted: (value) => handleSubmit(context),
  //   );
  // }
}

class Formatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= 3) {
      return oldValue;
    }
    return newValue;
  }
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  late final TextEditingController pinController;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController(text: 'Hello');
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: pinController,
      length: 10,
      toolbarEnabled: false,
      inputFormatters: [Formatter()],
    );
  }
}
