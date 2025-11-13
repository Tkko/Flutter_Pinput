import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pinput/flutter_pinput.dart';

class Formatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length <= 3) {
      return oldValue;
    }
    return newValue;
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

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
  Widget build(BuildContext context) =>
      Pinput(controller: pinController, length: 10, toolbarEnabled: false, inputFormatters: [Formatter()]);
}

class ErrorStateExample extends StatefulWidget {
  const ErrorStateExample({super.key});

  @override
  State<ErrorStateExample> createState() => _ErrorStateExampleState();
}

class _ErrorStateExampleState extends State<ErrorStateExample> {
  bool _hasError = false;

  Future<void> _validate(String value) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() => _hasError = value == '1111');
  }

  @override
  Widget build(BuildContext context) => Pinput(forceErrorState: _hasError, onCompleted: _validate);
}

class HeightExample extends StatelessWidget {
  const HeightExample({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 105,
      textStyle: const TextStyle(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.bold),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black),
    );

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.red),
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.green),
      ),
      followingPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue),
      ),
    );
  }
}
