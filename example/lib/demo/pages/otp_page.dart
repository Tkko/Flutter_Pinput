import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpPage extends StatefulWidget {
  final Widget pinPut;

  const OtpPage(this.pinPut, {Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();

  @override
  String toStringShort() => pinPut.toStringShort();
}

class _OtpPageState extends State<OtpPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Column(
        children: [
          const OtpHeader(),
          widget.pinPut,
          const SizedBox(height: 44),
          Text(
            'Didn’t receive code?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color.fromRGBO(62, 116, 165, 1),
            ),
          ),
          Text(
            'Resend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              decoration: TextDecoration.underline,
              color: const Color.fromRGBO(62, 116, 165, 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class OtpHeader extends StatelessWidget {
  const OtpHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Verification',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(30, 60, 87, 1),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Enter the code sent to the number',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromRGBO(133, 153, 170, 1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '+995 123 3456',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color.fromRGBO(30, 60, 87, 1),
          ),
        ),
        const SizedBox(height: 64)
      ],
    );
  }
}
