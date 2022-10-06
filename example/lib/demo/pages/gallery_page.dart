import 'package:flutter/material.dart';
import 'package:pinput_example/demo/demo.dart';
import 'package:pinput_example/demo/pages/all_pinputs_page.dart';
import 'package:pinput_example/demo/pages/otp_page.dart';
import 'package:pinput_example/demo/pinput_templates/filled.dart';
import 'package:pinput_example/demo/pinput_templates/filled_rounded.dart';
import 'package:pinput_example/demo/pinput_templates/only_bottom_cursor.dart';
import 'package:pinput_example/demo/pinput_templates/rounded_with_cursor.dart';
import 'package:pinput_example/demo/pinput_templates/rounded_with_shadow.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final backgroundColors = [
    [
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(255, 255, 255, 1)
    ], // All
    [
      const Color.fromRGBO(200, 255, 221, 1),
      const Color.fromRGBO(255, 255, 255, 1)
    ],
    [
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(255, 255, 255, 1)
    ],
    [
      const Color.fromRGBO(228, 217, 236, 1),
      const Color.fromRGBO(255, 255, 255, 1)
    ],
    [
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(255, 255, 255, 1)
    ],
    [
      const Color.fromRGBO(228, 217, 236, 1),
      const Color.fromRGBO(255, 255, 255, 1)
    ],
  ];

  final List<Widget> pinPuts = [];

  @override
  void initState() {
    super.initState();
    const otpPages = [
      OtpPage(RoundedWithCustomCursor()),
      OtpPage(RoundedWithShadow()),
      OtpPage(OnlyBottomCursor()),
      OtpPage(FilledRoundedPinPut()),
      OtpPage(Filled()),
    ];
    pinPuts.addAll([
      AllPinputs(otpPages.map((e) => e.pinPut).toList(), backgroundColors),
      ...otpPages,
    ]);

    _tabController =
        TabController(length: pinPuts.length, vsync: this, initialIndex: 1);
    _tabController!.animation!.addListener(() {
      final focusScope = FocusScope.of(context);
      if (focusScope.hasFocus) {
        focusScope.unfocus();
      }
    });
  }

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: AnimatedBuilder(
        animation: _tabController!.animation!,
        builder: (BuildContext context, Widget? child) {
          final anim = _tabController!.animation!.value;
          final Color fromColor = Color.lerp(
            backgroundColors[anim.floor()].first,
            backgroundColors[anim.ceil()].first,
            anim - anim.floor(),
          )!;

          final Color toColor = Color.lerp(
            backgroundColors[anim.floor()].last,
            backgroundColors[anim.ceil()].last,
            anim - anim.floor(),
          )!;

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fromColor, toColor],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).viewPadding.top),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: pinPuts.map((item) {
                      return Tab(text: '$item');
                    }).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: pinPuts,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
