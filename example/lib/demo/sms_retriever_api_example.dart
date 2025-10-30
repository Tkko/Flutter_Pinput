import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() async {
    await smartAuth.removeUserConsentApiListener();
    await smartAuth.removeSmsRetrieverApiListener();
    return;
  }

  @override
  Future<String?> getSmsCode() async {
    final res = await smartAuth.getSmsWithRetrieverApi();
    if (res.hasData && res.requireData.code != null) {
      return res.requireData.code!;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}

class SmsRetrieverApiExample extends StatefulWidget {
  const SmsRetrieverApiExample({super.key});

  @override
  State<SmsRetrieverApiExample> createState() => _SmsRetrieverApiExampleState();
}

class _SmsRetrieverApiExampleState extends State<SmsRetrieverApiExample> {
  late final SmsRetrieverImpl smsRetrieverImpl;

  @override
  void initState() {
    smsRetrieverImpl = SmsRetrieverImpl(SmartAuth.instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Pinput(smsRetriever: smsRetrieverImpl);
  }
}
