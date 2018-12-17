import 'dart:async';

class PinPutBloc {
  PinPutBloc() {
    _actionButtonSinkCtrl.stream.distinct().listen((bool b) {
      _actionButtonSreamCtrl.add(b);
    });
  }

  final _actionButtonSinkCtrl = StreamController<bool>();
  Sink<bool> get onActionChange => _actionButtonSinkCtrl.sink;
  final _actionButtonSreamCtrl = StreamController<bool>();
  Stream<bool> get onActionChanged => _actionButtonSreamCtrl.stream;

  void dispose() {
    _actionButtonSinkCtrl.close();
    _actionButtonSreamCtrl.close();
  }
}
