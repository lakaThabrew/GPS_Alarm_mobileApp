import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/destination.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Destination? _currentDestination;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  
  bool _isTracking = false;
  double _distanceToDest = 0.0;
  double _currentSpeed = 0.0;
  String _alertMessage = '';

  // Thresholds state
  bool _passed2km = false;
  bool _passed1km = false;
  bool _passed750m = false;
  bool _arrived = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Destination? get currentDestination => _currentDestination;
  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  double get distanceToDest => _distanceToDest;
  double get currentSpeed => _currentSpeed;
  String get alertMessage => _alertMessage;

  Future<void> startTracking(Destination destination) async {
    _currentDestination = destination;
    _isTracking = true;
    _alertMessage = 'Tracking Started';
    
    // Reset states
    _passed2km = false;
    _passed1km = false;
    _passed750m = false;
    _arrived = false;

    // Keep screen on
    WakelockPlus.enable();
    notifyListeners();

    _currentPosition = await LocationService.getCurrentPosition();
    if (_currentPosition != null) {
      _updateMetrics(_currentPosition!);
    }

    _positionSubscription = LocationService.getLocationStream().listen((Position position) {
      _currentPosition = position;
      _updateMetrics(position);
    });
  }

  void _updateMetrics(Position position) {
    if (_currentDestination == null) return;

    _currentSpeed = position.speed * 3.6; // convert m/s to km/h

    _distanceToDest = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _currentDestination!.latitude,
      _currentDestination!.longitude,
    );

    _checkAlarms(_distanceToDest);
    notifyListeners();
  }

  Future<void> _checkAlarms(double distanceMeters) async {
    if (_arrived) return;

    if (distanceMeters <= 300 && !_arrived) {
      _arrived = true;
      _alertMessage = 'Arrived at Destination!';
      await _playArrivalAlarm();
      stopTracking();
      return;
    }

    if (distanceMeters <= 750 && !_passed750m) {
      _passed750m = true;
      _alertMessage = 'Close: 750 meters remaining';
      _vibrate(pattern: [0, 500, 200, 500, 200, 500]);
      return;
    }

    if (distanceMeters <= 1000 && !_passed1km) {
      _passed1km = true;
      _alertMessage = 'Near: 1 km remaining';
      _vibrate(pattern: [0, 500, 200, 500]);
      return;
    }

    if (distanceMeters <= 2000 && !_passed2km) {
      _passed2km = true;
      _alertMessage = 'Approaching: 2 km remaining';
      _vibrate(pattern: [0, 500]);
      return;
    }
  }

  Future<void> _vibrate({required List<int> pattern}) async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: pattern);
    }
  }

  Future<void> _playArrivalAlarm() async {
    await _vibrate(pattern: [0, 1000, 500, 1000, 500, 1000]);
    await _audioPlayer.play(AssetSource('alarm.mp3'));
  }

  void stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _audioPlayer.stop();
    WakelockPlus.disable();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}
