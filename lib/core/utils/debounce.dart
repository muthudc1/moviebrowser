import 'dart:async';
import 'package:flutter/foundation.dart';

class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce({this.duration = const Duration(milliseconds: 400)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
