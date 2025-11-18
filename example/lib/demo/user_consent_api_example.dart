import 'package:flutter/material.dart';
import 'package:flutter_pinput/flutter_pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class SmsRetrieverImpl implements SmsRetriever {
  const SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeUserConsentApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final res = await smartAuth.getSmsWithUserConsentApi();
    return res.data?.code;
  }
}

class UserConsentApiExample extends StatefulWidget {
  const UserConsentApiExample({super.key});

  @override
  State<UserConsentApiExample> createState() => _UserConsentApiExampleState();
}

class _UserConsentApiExampleState extends State<UserConsentApiExample> {
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
