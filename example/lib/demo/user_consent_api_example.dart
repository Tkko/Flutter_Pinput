import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeSmsListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final res = await smartAuth.getSmsCode(
      useUserConsentApi: true,
    );
    if (res.succeed && res.codeFound) {
      return res.code!;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}

class UserConsentApiExample extends StatefulWidget {
  const UserConsentApiExample({Key? key}) : super(key: key);

  @override
  State<UserConsentApiExample> createState() => _UserConsentApiExampleState();
}

class _UserConsentApiExampleState extends State<UserConsentApiExample> {
  late final SmsRetrieverImpl smsRetrieverImpl;

  @override
  void initState() {
    smsRetrieverImpl = SmsRetrieverImpl(SmartAuth());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(
      smsRetriever: smsRetrieverImpl,
    );
  }
}
