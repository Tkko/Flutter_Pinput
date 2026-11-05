import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class SmsRetrieverApiExample extends StatefulWidget {
  const SmsRetrieverApiExample({super.key});

  @override
  State<SmsRetrieverApiExample> createState() => _SmsRetrieverApiExampleState();
}

class _SmsRetrieverApiExampleState extends State<SmsRetrieverApiExample> {
  final pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenForSmsCode();
  }

  Future<void> _listenForSmsCode() async {
    final res = await SmartAuth.instance.getSmsWithRetrieverApi();
    final code = res.data?.code;
    if (mounted && code != null) pinController.setText(code);
  }

  @override
  void dispose() {
    SmartAuth.instance.removeSmsRetrieverApiListener();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(controller: pinController);
  }
}
