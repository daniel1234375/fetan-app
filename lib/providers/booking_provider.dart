import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/truck_type.dart';
import '../models/driver.dart';

class BookingProvider extends ChangeNotifier {
  String? _userEmail;
  bool _isAuthenticated = false;
  TruckType _selectedTruck = TruckType.list.first;
  String _destination = '';
  bool _isBookingActive = false;
  Driver _driver = Driver.mockDriver;
  double _distanceKm = 12.5; // Simulated default distance
  double _driverProgress = 0.0; // 0.0 to 1.0 along the route
  Timer? _simulationTimer;

  // Getters
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _isAuthenticated;
  TruckType get selectedTruck => _selectedTruck;
  String get destination => _destination;
  bool get isBookingActive => _isBookingActive;
  Driver get driver => _driver;
  double get distanceKm => _distanceKm;
  double get driverProgress => _driverProgress;
  double get estimatedFare => _selectedTruck.calculateFare(_distanceKm);

  // Authentication Logic
  Future<bool> signIn(String email, String password) async {
    // Simple simulated authentication
    if (email.contains('@') && email.contains('.')) {
      _userEmail = email;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    return signIn(email, password);
  }

  void signOut() {
    _userEmail = null;
    _isAuthenticated = false;
    _isBookingActive = false;
    _stopSimulation();
    notifyListeners();
  }

  // Booking Logic
  void selectTruck(TruckType truck) {
    _selectedTruck = truck;
    notifyListeners();
  }

  void updateDestination(String dest) {
    _destination = dest;
    notifyListeners();
  }

  void setDistance(double km) {
    _distanceKm = km;
    notifyListeners();
  }

  void startBooking() {
    if (_destination.trim().isEmpty) return;
    _isBookingActive = true;
    _driverProgress = 0.0;
    notifyListeners();
    _startSimulation();
  }

  void cancelBooking() {
    _isBookingActive = false;
    _stopSimulation();
    _driverProgress = 0.0;
    notifyListeners();
  }

  // Driver Movement Simulator
  void _startSimulation() {
    _stopSimulation();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_driverProgress < 1.0) {
        _driverProgress += 0.05; // 5% progress per step
        if (_driverProgress > 1.0) _driverProgress = 1.0;
        notifyListeners();
      } else {
        _stopSimulation();
      }
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  @override
  void dispose() {
    _stopSimulation();
    super.dispose();
  }
}
