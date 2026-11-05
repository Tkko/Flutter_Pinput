import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class UserConsentApiExample extends StatefulWidget {
  const UserConsentApiExample({super.key});

  @override
  State<UserConsentApiExample> createState() => _UserConsentApiExampleState();
}

class _UserConsentApiExampleState extends State<UserConsentApiExample> {
  final pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenForSmsCode();
  }

  Future<void> _listenForSmsCode() async {
    final res = await SmartAuth.instance.getSmsWithUserConsentApi();
    final code = res.data?.code;
    if (mounted && code != null) pinController.setText(code);
  }

  @override
  void dispose() {
    SmartAuth.instance.removeUserConsentApiListener();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(controller: pinController);
  }
}
