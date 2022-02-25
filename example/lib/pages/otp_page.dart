import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OptPage extends StatefulWidget {
  final Widget pinPut;

  OptPage(this.pinPut);

  @override
  State<OptPage> createState() => _OptPageState();

  @override
  String toStringShort() => pinPut.toStringShort();
}

class _OptPageState extends State<OptPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Column(
        children: [
          Text(
            'Verification',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(30, 60, 87, 1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Enter the code sent to the number',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color.fromRGBO(133, 153, 170, 1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '+995 123 3456',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color.fromRGBO(30, 60, 87, 1),
            ),
          ),
          const SizedBox(height: 64),
          widget.pinPut,
          const SizedBox(height: 44),
          Text(
            'Didn’t receive code?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color.fromRGBO(62, 116, 165, 1),
            ),
          ),
          Text(
            'Resend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              decoration: TextDecoration.underline,
              color: Color.fromRGBO(62, 116, 165, 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
