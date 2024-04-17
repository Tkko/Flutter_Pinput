import 'package:flutter/material.dart';

class AllPinputs extends StatefulWidget {
  final List<Widget> pinPuts;
  final List<List<Color>> colors;

  const AllPinputs(this.pinPuts, this.colors, {Key? key}) : super(key: key);

  @override
  _AllPinputsState createState() => _AllPinputsState();

  @override
  String toStringShort() => 'All';
}

class _AllPinputsState extends State<AllPinputs>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          ...widget.pinPuts.asMap().entries.map((item) {
            final fromColor = widget.colors[item.key + 1].first;
            return Container(
              width: double.maxFinite,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: fromColor.withOpacity(.4)),
              child: item.value,
            );
          }),
          const Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              autofillHints: [AutofillHints.oneTimeCode],
              decoration: InputDecoration(
                labelText: 'Standard TextField for Testing',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
