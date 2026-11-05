import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';

/// App-owned async validation with visible progress and stale-result handling.
class AsyncValidationExample extends StatefulWidget {
  const AsyncValidationExample({super.key});

  @override
  State<AsyncValidationExample> createState() => _AsyncValidationExampleState();

  @override
  String toStringShort() => 'Async validation';
}

class _AsyncValidationExampleState extends State<AsyncValidationExample> {
  final _controller = TextEditingController();
  PinValidationState _validation = const PinValidationState.idle();
  int _request = 0;

  void _onChanged(String pin) {
    _request++;
    setState(() => _validation = const PinValidationState.idle());
  }

  Future<void> _verify(String pin) async {
    if (_validation is PinValidationValidating) return;
    if (pin.length != 4) {
      setState(() {
        _validation = const PinValidationState.invalid('Enter all 4 digits');
      });
      return;
    }

    final request = ++_request;
    setState(() => _validation = const PinValidationState.validating());

    // Simulate a server check. Keep editing enabled to demonstrate stale results.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || request != _request || _controller.text != pin) return;

    setState(() {
      _validation = pin == '2222'
          ? const PinValidationState.valid()
          : const PinValidationState.invalid('Incorrect code. Try 2222.');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _validation is PinValidationValidating;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Async validation', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 12),
          const Text(
            'Enter 2222 to succeed, or any other code to see an error. '
            'Edit during the two-second check to discard its result.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Pinput(
            controller: _controller,
            validationState: _validation,
            closeKeyboardWhenCompleted: false,
            onChanged: _onChanged,
            onCompleted: _verify,
            onSubmitted: _verify,
          ),
          const SizedBox(height: 20),
          if (pending) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('Verifying code...'),
          ] else if (_validation is PinValidationValid)
            const Text('Code verified'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: pending ? null : () => _verify(_controller.text),
            child: const Text('Verify code'),
          ),
        ],
      ),
    );
  }
}
