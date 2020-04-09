import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

void main() => runApp(PinPutTest());

class PinPutTest extends StatefulWidget {
  @override
  PinPutTestState createState() => PinPutTestState();
}

class PinPutTestState extends State<PinPutTest> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  BuildContext _context;
  final PageController _pageController = PageController(initialPage: 1);
  int _pageIndex = 0;

  Widget darkRoundedPinPut() {
    BoxDecoration pinPutDecoration = BoxDecoration(
      color: Color.fromRGBO(25, 21, 99, 1),
      borderRadius: BorderRadius.circular(20),
    );
    return PinPut(
      eachFieldWidth: 65,
      eachFieldHeight: 65,
      fieldsCount: 4,
      focusNode: _pinPutFocusNode,
      controller: _pinPutController,
      onSubmit: (String pin) => _showSnackBar(pin),
      submittedFieldDecoration: pinPutDecoration,
      selectedFieldDecoration: pinPutDecoration,
      followingFieldDecoration: pinPutDecoration,
      pinAnimationType: PinAnimationType.scale,
      textStyle: TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  Widget animatingBorders() {
    BoxDecoration pinPutDecoration = BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15),
    );
    return PinPut(
      fieldsCount: 5,
      eachFieldHeight: 40,
      onSubmit: (String pin) => _showSnackBar(pin),
      focusNode: _pinPutFocusNode,
      controller: _pinPutController,
      submittedFieldDecoration:
          pinPutDecoration.copyWith(borderRadius: BorderRadius.circular(20)),
      pinAnimationType: PinAnimationType.slide,
      selectedFieldDecoration: pinPutDecoration,
      followingFieldDecoration: pinPutDecoration.copyWith(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.deepPurpleAccent.withOpacity(.5),
        ),
      ),
    );
  }

  Widget boxedPinPutWithPreFilledSymbol() {
    BoxDecoration pinPutDecoration = BoxDecoration(
      color: Color.fromRGBO(119, 125, 226, 1),
      borderRadius: BorderRadius.circular(5),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white),
      ),
      padding: EdgeInsets.all(20),
      child: PinPut(
        fieldsCount: 5,
        preFilledChar: '-',
        preFilledCharStyle: TextStyle(fontSize: 35, color: Colors.white),
        textStyle: TextStyle(fontSize: 25, color: Colors.white),
        eachFieldWidth: 50,
        eachFieldHeight: 50,
        onSubmit: (String pin) => _showSnackBar(pin),
        focusNode: _pinPutFocusNode,
        controller: _pinPutController,
        submittedFieldDecoration: pinPutDecoration,
        selectedFieldDecoration: pinPutDecoration.copyWith(color: Colors.white),
        followingFieldDecoration: pinPutDecoration,
        pinAnimationType: PinAnimationType.slide,
      ),
    );
  }

  Widget onlySelectedBorderPinPut() {
    BoxDecoration pinPutDecoration = BoxDecoration(
      color: Color.fromRGBO(235, 236, 237, 1),
      borderRadius: BorderRadius.circular(5),
    );

    return PinPut(
      fieldsCount: 5,
      textStyle: TextStyle(fontSize: 25, color: Colors.black),
      eachFieldWidth: 45,
      eachFieldHeight: 55,
      onSubmit: (String pin) => _showSnackBar(pin),
      focusNode: _pinPutFocusNode,
      controller: _pinPutController,
      submittedFieldDecoration: pinPutDecoration,
      selectedFieldDecoration: pinPutDecoration.copyWith(
          color: Colors.white,
          border: Border.all(
            width: 2,
            color: Color.fromRGBO(160, 215, 220, 1),
          )),
      followingFieldDecoration: pinPutDecoration,
      pinAnimationType: PinAnimationType.scale,
    );
  }

  Widget justRoundedCornersPinPut() {
    BoxDecoration pinPutDecoration = BoxDecoration(
        color: Color.fromRGBO(43, 46, 66, 1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color.fromRGBO(126, 203, 224, 1)));

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: PinPut(
        fieldsCount: 4,
        textStyle: TextStyle(fontSize: 25, color: Colors.white),
        eachFieldWidth: 40,
        eachFieldHeight: 55,
        onSubmit: (String pin) => _showSnackBar(pin),
        focusNode: _pinPutFocusNode,
        controller: _pinPutController,
        submittedFieldDecoration: pinPutDecoration,
        selectedFieldDecoration: pinPutDecoration,
        followingFieldDecoration: pinPutDecoration,
        pinAnimationType: PinAnimationType.fade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pinPuts = [
      onlySelectedBorderPinPut(),
      darkRoundedPinPut(),
      animatingBorders(),
      boxedPinPutWithPreFilledSymbol(),
      justRoundedCornersPinPut(),
    ];

    List<Color> _bgColors = [
      Colors.white,
      Color.fromRGBO(43, 36, 198, 1),
      Colors.white,
      Color.fromRGBO(75, 83, 214, 1),
      Color.fromRGBO(43, 46, 66, 1),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Builder(
              builder: (context) {
                _context = context;
                return AnimatedContainer(
                  color: _bgColors[_pageIndex],
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(40),
                  child: PageView(
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                    children: _pinPuts.map((p) {
                      return FractionallySizedBox(
                        heightFactor: 1,
                        child: Center(child: p),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            _bottomAppBar,
          ],
        ),
      ),
    );
  }

  Widget get _bottomAppBar {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Text('Focus'),
            onPressed: () => _pinPutFocusNode.requestFocus(),
          ),
          FlatButton(
            child: Text('Unfocus'),
            onPressed: () => _pinPutFocusNode.unfocus(),
          ),
          FlatButton(
            child: Text('Clear All'),
            onPressed: () => _pinPutController.text = '',
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String pin) {
    final snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Container(
          height: 80.0,
          child: Center(
            child: Text(
              'Pin Submitted. Value: $pin',
              style: TextStyle(fontSize: 25.0),
            ),
          )),
      backgroundColor: Colors.deepPurpleAccent,
    );
    Scaffold.of(_context).hideCurrentSnackBar();
    Scaffold.of(_context).showSnackBar(snackBar);
  }
}
