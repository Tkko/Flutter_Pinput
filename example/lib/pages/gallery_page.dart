import 'package:flutter/material.dart';
import 'package:pinput_example/main.dart';
import 'package:pinput_example/pages/all_pinputs_page.dart';
import 'package:pinput_example/pages/otp_page.dart';
import 'package:pinput_example/pinput_templates/filled.dart';
import 'package:pinput_example/pinput_templates/filled_rounded.dart';
import 'package:pinput_example/pinput_templates/only_bottom_cursor.dart';
import 'package:pinput_example/pinput_templates/rounded_with_cursor.dart';
import 'package:pinput_example/pinput_templates/rounded_with_shadow.dart';

class GalleryPage extends StatefulWidget {
  @override
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  final backgroundColors = [
    [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(255, 255, 255, 1)], // All
    [Color.fromRGBO(200, 255, 221, 1), Color.fromRGBO(255, 255, 255, 1)],
    [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(255, 255, 255, 1)],
    [Color.fromRGBO(228, 217, 236, 1), Color.fromRGBO(255, 255, 255, 1)],
    [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(255, 255, 255, 1)],
    [Color.fromRGBO(228, 217, 236, 1), Color.fromRGBO(255, 255, 255, 1)],
  ];

  final List<Widget> pinPuts = [];

  @override
  void initState() {
    super.initState();
    final otpPages = [
      OptPage(RoundedWithCustomCursor()),
      OptPage(RoundedWithShadow()),
      OptPage(OnlyBottomCursor()),
      OptPage(FilledRoundedPinPut()),
      OptPage(Filled()),
    ];
    pinPuts.addAll([
      AllPinputs(otpPages.map((e) => e.pinPut).toList(), backgroundColors),
      ...otpPages,
    ]);

    _tabController = TabController(length: pinPuts.length, vsync: this, initialIndex: 1);
    _tabController.animation.addListener(() {
      final focusScope = FocusScope.of(context);
      if (focusScope.hasFocus) {
        focusScope.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: AnimatedBuilder(
        animation: _tabController.animation,
        builder: (BuildContext context, Widget child) {
          final anim = _tabController.animation.value;
          final Color fromColor = Color.lerp(
            backgroundColors[anim.floor()].first,
            backgroundColors[anim.ceil()].first,
            anim - anim.floor(),
          );

          final Color toColor = Color.lerp(
            backgroundColors[anim.floor()].last,
            backgroundColors[anim.ceil()].last,
            anim - anim.floor(),
          );

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
