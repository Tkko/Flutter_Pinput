import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

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
  Widget build(BuildContext context) {
    return Pinput(
      controller: pinController,
      keyboard: PinKeyboard(autofillHints: const [AutofillHints.oneTimeCode]),
      length: 10,
      enableInteractiveSelection: false,
      inputFormatters: [Formatter()],
    );
  }
}

class ErrorStateExample extends StatefulWidget {
  const ErrorStateExample({super.key});

  @override
  State<ErrorStateExample> createState() => _ErrorStateExampleState();
}

class _ErrorStateExampleState extends State<ErrorStateExample> {
  PinValidationState _validationState = const PinValidationState.idle();
  int _validationRequest = 0;

  Future<void> _validate(String value) async {
    final request = ++_validationRequest;
    setState(() => _validationState = const PinValidationState.validating());
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || request != _validationRequest) return;
    setState(() {
      _validationState = value == '1111'
          ? const PinValidationState.invalid('Incorrect code')
          : const PinValidationState.valid();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: 4,
      validationState: _validationState,
      onChanged: (_) {
        _validationRequest++;
        setState(() => _validationState = const PinValidationState.idle());
      },
      onCompleted: _validate,
    );
  }
}

class HeightExample extends StatelessWidget {
  const HeightExample({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 105,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.black,
      ),
    );

    return Pinput(
      length: 6,
      theme: PinThemes(
        fallback: defaultPinTheme,
        focused: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.red,
          ),
        ),
        filled: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.green,
          ),
        ),
        empty: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
