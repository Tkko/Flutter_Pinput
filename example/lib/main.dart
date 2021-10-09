import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

void main() => runApp(PinPutApp());

class PinPutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: PinPutView()),
    );
  }
}

class PinPutView extends StatefulWidget {
  @override
  PinPutViewState createState() => PinPutViewState();
}

class PinPutViewState extends State<PinPutView> {
  final _formKey = GlobalKey<FormState>();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final _pageController = PageController();

  int _pageIndex = 0;

  final List<Widget> _pinPuts = [];

  final List<Color> _bgColors = [
    Colors.white,
    const Color.fromRGBO(43, 36, 198, 1),
    Colors.white,
    const Color.fromRGBO(75, 83, 214, 1),
    const Color.fromRGBO(43, 46, 66, 1),
  ];

  @override
  void initState() {
    _pinPuts.addAll([
      onlySelectedBorderPinPut(),
      darkRoundedPinPut(),
      animatingBorders(),
      boxedPinPutWithPreFilledSymbol(),
      justRoundedCornersPinPut(),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        AnimatedContainer(
          color: _bgColors[_pageIndex],
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(40.0),
          child: PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _pageIndex = index);
            },
            children: _pinPuts.map((p) {
              return FractionallySizedBox(
                heightFactor: 1.0,
                child: Center(child: p),
              );
            }).toList(),
          ),
        ),
        _bottomAppBar,
      ],
    );
  }

  Widget onlySelectedBorderPinPut() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(235, 236, 237, 1),
      borderRadius: BorderRadius.circular(5.0),
    );
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onLongPress: () {
              print(_formKey.currentState.validate());
            },
            child: PinPut(
              validator: (s) {
                if (s.contains('1')) return null;
                return 'NOT VALID';
              },
              useNativeKeyboard: false,
              // autovalidateMode: AutovalidateMode.onUserInteraction,
              withCursor: true,
              fieldsCount: 5,
              fieldsAlignment: MainAxisAlignment.spaceAround,
              textStyle: const TextStyle(fontSize: 25.0, color: Colors.black),
              eachFieldMargin: EdgeInsets.all(0),
              eachFieldWidth: 45.0,
              eachFieldHeight: 55.0,
              onSubmit: (String pin) => _showSnackBar(pin),
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration.copyWith(
                color: Colors.white,
                border: Border.all(
                  width: 2,
                  color: const Color.fromRGBO(160, 215, 220, 1),
                ),
              ),
              followingFieldDecoration: pinPutDecoration,
              pinAnimationType: PinAnimationType.scale,
            ),
          ),
          SizedBox(height: 30),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(30),
            physics: NeverScrollableScrollPhysics(),
            children: [
              ...[1, 2, 3, 4, 5, 6, 7, 8, 9, 0].map((e) {
                return RoundedButton(
                  title: '$e',
                  onTap: () {
                    if (_pinPutController.text.length >= 5) return;

                    _pinPutController.text = '${_pinPutController.text}$e';
                  },
                );
              }),
              RoundedButton(
                title: '⌫',
                onTap: () {
                  if (_pinPutController.text.isNotEmpty) {
                    _pinPutController.text = _pinPutController.text
                        .substring(0, _pinPutController.text.length - 1);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget darkRoundedPinPut() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(25, 21, 99, 1),
      borderRadius: BorderRadius.circular(20.0),
    );
    return PinPut(
      eachFieldWidth: 65.0,
      eachFieldHeight: 65.0,
      withCursor: true,
      fieldsCount: 4,
      focusNode: _pinPutFocusNode,
      controller: _pinPutController,
      onSubmit: (String pin) => _showSnackBar(pin),
      submittedFieldDecoration: pinPutDecoration,
      selectedFieldDecoration: pinPutDecoration,
      followingFieldDecoration: pinPutDecoration,
      pinAnimationType: PinAnimationType.scale,
      textStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
    );
  }

  Widget animatingBorders() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
    return PinPut(
      fieldsCount: 5,
      eachFieldHeight: 40.0,
      withCursor: true,
      onSubmit: (String pin) => _showSnackBar(pin),
      focusNode: _pinPutFocusNode,
      controller: _pinPutController,
      submittedFieldDecoration: pinPutDecoration.copyWith(
        borderRadius: BorderRadius.circular(20.0),
      ),
      selectedFieldDecoration: pinPutDecoration,
      followingFieldDecoration: pinPutDecoration.copyWith(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: Colors.deepPurpleAccent.withOpacity(.5),
        ),
      ),
    );
  }

  Widget boxedPinPutWithPreFilledSymbol() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(119, 125, 226, 1),
      borderRadius: BorderRadius.circular(5.0),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(20.0),
      child: PinPut(
        withCursor: true,
        fieldsCount: 5,
        preFilledWidget: FlutterLogo(),
        textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
        eachFieldWidth: 50.0,
        eachFieldHeight: 50.0,
        onSubmit: (String pin) => _showSnackBar(pin),
        focusNode: _pinPutFocusNode,
        controller: _pinPutController,
        submittedFieldDecoration: pinPutDecoration,
        selectedFieldDecoration: pinPutDecoration.copyWith(color: Colors.white),
        followingFieldDecoration: pinPutDecoration,
      ),
    );
  }

  Widget justRoundedCornersPinPut() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: const Color.fromRGBO(43, 46, 66, 1),
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(
        color: const Color.fromRGBO(126, 203, 224, 1),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: PinPut(
        fieldsCount: 4,
        withCursor: true,
        textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
        eachFieldWidth: 55.0,
        eachFieldHeight: 55.0,
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

  Widget get _bottomAppBar {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextButton(
            onPressed: () => _pinPutFocusNode.requestFocus(),
            child: const Text('Focus'),
          ),
          TextButton(
            onPressed: () => _pinPutFocusNode.unfocus(),
            child: const Text('Unfocus'),
          ),
          TextButton(
            onPressed: () => _pinPutController.text = '',
            child: const Text('Clear All'),
          ),
          TextButton(
            child: Text('Paste'),
            onPressed: () => _pinPutController.text = '234',
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String pin) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 80.0,
        child: Center(
          child: Text(
            'Pin Submitted. Value: $pin',
            style: const TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      backgroundColor: Colors.deepPurpleAccent,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class RoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  RoundedButton({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromRGBO(25, 21, 99, 1),
        ),
        alignment: Alignment.center,
        child: Text(
          '$title',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
