import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  VoidCallback? _onShake;
  bool _isListening = false;

  static const double _shakeThreshold = 15.0;
  static const int _shakeMinCount = 3;
  static const Duration _shakeWindow = Duration(milliseconds: 600);

  final List<DateTime> _shakeTimestamps = [];
  DateTime _lastEvent = DateTime.now();

  bool get isListening => _isListening;

  void startListening({required VoidCallback onShake}) {
    if (_isListening) return;
    _onShake = onShake;
    _isListening = true;

    _subscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();

      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        if (now.difference(_lastEvent).inMilliseconds < 100) return;
        _lastEvent = now;

        _shakeTimestamps.add(now);
        _shakeTimestamps.removeWhere(
          (t) => now.difference(t) > _shakeWindow,
        );

        if (_shakeTimestamps.length >= _shakeMinCount) {
          _shakeTimestamps.clear();
          _onShake?.call();
        }
      }
    }, onError: (error) {
      debugPrint('Accelerometer error: $error');
    });
  }

  void stopListening() {
    _isListening = false;
    _subscription?.cancel();
    _subscription = null;
    _shakeTimestamps.clear();
  }
}
