import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput_example/all_pinputs.dart';
import 'package:pinput_example/otp_page.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

void main() => runApp(AppView());

class AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final app = MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Color.fromRGBO(30, 60, 87, 1),
            tabBarTheme: TabBarTheme(
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color.fromRGBO(30, 60, 87, 1), width: 2.0),
                ),
              ),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 16),
              labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              labelColor: Color.fromRGBO(30, 60, 87, 1),
              unselectedLabelColor: Color.fromRGBO(107, 137, 165, 1),
            ),
            chipTheme: ChipThemeData(
              selectedColor: Color.fromRGBO(30, 60, 87, 1),
            ),
          ),
          home: PinPutGallery(),
        );

        final shortestSide = min(constraints.maxWidth.abs(), constraints.maxHeight.abs());

        if (shortestSide > 600) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Container(
              width: 375,
              height: 812,
              margin: EdgeInsets.all(20),
              clipBehavior: Clip.antiAlias,
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 15),
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: app,
            ),
          );
        }
        return app;
      },
    );
  }
}

class PinPutGallery extends StatefulWidget {
  @override
  PinPutGalleryState createState() => PinPutGalleryState();
}

class PinPutGalleryState extends State<PinPutGallery> with SingleTickerProviderStateMixin {
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
      AllPinPuts(otpPages.map((e) => e.pinPut).toList(), backgroundColors),
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
    // return Scaffold(
    //   body: Center(
    //     child: FilledRoundedPinPut(),
    //   ),
    // );

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

class Filled extends StatefulWidget {
  @override
  _FilledState createState() => _FilledState();

  @override
  String toStringShort() => 'Filled';
}

class _FilledState extends State<Filled> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
      decoration: BoxDecoration(color: Color.fromRGBO(159, 132, 193, 0.8)),
    );

    return Container(
      width: 243,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Pinput(
        length: 4,
        controller: controller,
        focusNode: focusNode,
        separator: Container(
          height: 64,
          width: 1,
          color: Colors.white,
        ),
        defaultTheme: defaultPinTheme,
        showCursor: true,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(color: Color.fromRGBO(124, 102, 152, 1)),
        ),
      ),
    );
  }
}

class RoundedWithShadow extends StatefulWidget {
  @override
  _RoundedWithShadowState createState() => _RoundedWithShadowState();

  @override
  String toStringShort() => 'Rounded With Shadow';
}

class _RoundedWithShadowState extends State<RoundedWithShadow> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 64,
      textStyle: GoogleFonts.poppins(fontSize: 20, color: Color.fromRGBO(70, 69, 66, 1)),
      decoration: BoxDecoration(
        color: Color.fromRGBO(232, 235, 241, 0.37),
        borderRadius: BorderRadius.circular(24),
      ),
    );

    final cursor = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 21,
        height: 1,
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(137, 146, 160, 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return Pinput(
      length: 4,
      controller: controller,
      focusNode: focusNode,
      defaultTheme: defaultPinTheme,
      separator: SizedBox(width: 16),
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05999999865889549),
              offset: Offset(0, 3),
              blurRadius: 16,
            )
          ],
        ),
      ),
      showCursor: true,
      cursor: cursor,
    );
  }
}

class OnlyBottomCursor extends StatefulWidget {
  @override
  _OnlyBottomCursorState createState() => _OnlyBottomCursorState();

  @override
  String toStringShort() => 'With Bottom Cursor';
}

class _OnlyBottomCursorState extends State<OnlyBottomCursor> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(30, 60, 87, 1);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
      decoration: BoxDecoration(),
    );

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
    final preFilledWidget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );

    return SizedBox(
      height: 68,
      child: Pinput(
        length: 5,
        pinAnimationType: PinAnimationType.slide,
        controller: controller,
        focusNode: focusNode,
        defaultTheme: defaultPinTheme,
        showCursor: true,
        cursor: cursor,
        preFilledWidget: preFilledWidget,
      ),
    );
  }
}

class RoundedWithCustomCursor extends StatefulWidget {
  @override
  _RoundedWithCustomCursorState createState() => _RoundedWithCustomCursorState();

  @override
  String toStringShort() => 'Rounded With Cursor';
}

class _RoundedWithCustomCursorState extends State<RoundedWithCustomCursor> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return SizedBox(
      height: 68,
      child: Pinput(
        controller: controller,
        focusNode: focusNode,
        defaultTheme: defaultPinTheme,
        showCursor: true,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 9),
              width: 22,
              height: 1,
              color: focusedBorderColor,
            ),
          ],
        ),
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 56,
          width: 56,
          decoration: defaultPinTheme.decoration.copyWith(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          height: 56,
          width: 56,
          decoration: defaultPinTheme.decoration.copyWith(
            color: fillColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: focusedBorderColor),
          ),
        ),
      ),
    );
  }
}

class FilledRoundedPinPut extends StatefulWidget {
  @override
  _FilledRoundedPinPutState createState() => _FilledRoundedPinPutState();

  @override
  String toStringShort() => 'Rounded Filled';
}

class _FilledRoundedPinPutState extends State<FilledRoundedPinPut> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool showError = false;

  @override
  Widget build(BuildContext context) {
    final length = 4;
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 68,
          child: Pinput(
            length: length,
            controller: controller,
            focusNode: focusNode,
            defaultTheme: defaultPinTheme,
            useNativeKeyboard: false,
            showError: showError,
            onCompleted: (pin) {
              setState(() => showError = pin != '5555');
            },
            focusedPinTheme: defaultPinTheme.copyWith(
              height: 68,
              width: 64,
              decoration: defaultPinTheme.decoration.copyWith(
                border: Border.all(color: borderColor),
              ),
            ),
            errorPinTheme: defaultPinTheme.copyWith(
              decoration: BoxDecoration(
                color: errorColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          children: [
            ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map(
              (e) => TextButton(
                child: Text('$e'),
                onPressed: () {
                  controller.append('$e', length);
                },
              ),
            ),
            TextButton(
              child: Text('Del'),
              onPressed: () {
                controller.delete();
              },
            )
          ],
        ),
      ],
    );
  }
}
