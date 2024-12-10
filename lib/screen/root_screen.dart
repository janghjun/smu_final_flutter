import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:smp_final_project/screen/badge_screen.dart';
import 'package:smp_final_project/screen/calendar_screen.dart';
import 'package:smp_final_project/screen/settings_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  LatLng? _currentLatLng;
  late GoogleMapController _mapController;

  final List<LatLng> _routePoints = [];
  final Set<Polyline> _polylines = {};

  bool _isButtonVisible = true;
  bool _isTimerRunning = false;
  int _seconds = 0;
  late Timer _timer;

  int _stepCount = 0;
  double _distance = 0.0;

  Map<DateTime, Map<String, dynamic>> _runningGoals = {};
  List<Map<String, dynamic>> _dailyRecords = []; // 하루 운동 기록 저장

  int _goalSteps = 10000;
  double _goalDistance = 5.0;

  StreamSubscription<StepCount>? _stepCountStreamSubscription;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final Position position = await Geolocator.getCurrentPosition();
    _updateRoute(LatLng(position.latitude, position.longitude));
  }

  void _updateRoute(LatLng newPosition) {
    setState(() {
      if (_currentLatLng != null) {
        _distance += _calculateDistance(_currentLatLng!, newPosition);
      }
      _currentLatLng = newPosition;
      _routePoints.add(newPosition);

      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: Colors.blue,
        width: 5,
      ));
    });

    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    double latDiff = _degreeToRadian(end.latitude - start.latitude);
    double lngDiff = _degreeToRadian(end.longitude - start.longitude);

    double a =
        sin(latDiff / 2) * sin(latDiff / 2) +
            cos(_degreeToRadian(start.latitude)) *
                cos(_degreeToRadian(end.latitude)) *
                sin(lngDiff / 2) *
                sin(lngDiff / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startPedometer();
  }

  void _startPedometer() {
    _stepCountStreamSubscription =
        Pedometer.stepCountStream.listen((StepCount stepCount) {
          setState(() {
            _stepCount = stepCount.steps;
          });
        }, onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('걸음 수 센서 오류: $error')),
          );
          _calculateStepsFromDistance();
        });
  }

  void _calculateStepsFromDistance() {
    const double averageStepLength = 0.78;
    setState(() {
      _stepCount = (_distance * 1000 / averageStepLength).round();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startTimer() {
    setState(() {
      _isButtonVisible = false;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _seconds++;
      });

      try {
        final Position position = await Geolocator.getCurrentPosition();
        _updateRoute(LatLng(position.latitude, position.longitude));
      } catch (e) {
        print('Error getting location: $e');
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _timer.cancel();
      _isTimerRunning = false;
    });
  }

  void _endSession() {
    setState(() {
      // 운동 기록 저장
      _dailyRecords.add({
        'steps': _stepCount,
        'distance': _distance,
        'time': _seconds,
      });

      // 운동 기록 초기화
      _stepCount = 0;
      _distance = 0.0;
      _seconds = 0;

      _isButtonVisible = true; // 시작 버튼 활성화
      _timer.cancel();
      _isTimerRunning = false;
    });
  }

  void _onGoalSet(DateTime date, Map<String, dynamic> goal) {
    setState(() {
      _runningGoals[date] = goal;

      // 성과 화면의 목표를 업데이트
      _goalSteps = goal['steps'] ?? _goalSteps;
      _goalDistance = goal['distance'] ?? _goalDistance;
    });
  }

  @override
  void dispose() {
    _stepCountStreamSubscription?.cancel();
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                value,
                style: const TextStyle(fontSize: 20.0, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: _currentLatLng == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng!,
                      zoom: 16,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    polylines: _polylines,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard('걸음 수', '$_stepCount'),
                    _buildInfoCard('거리', '${_distance.toStringAsFixed(2)} km'),
                    _buildInfoCard('시간', _formatTime(_seconds)),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isButtonVisible)
                      ElevatedButton(
                        onPressed: _startTimer,
                        child: const Text('시작'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _stopTimer,
                        child: const Text('정지'),
                      ),
                    ElevatedButton(
                      onPressed: _endSession,
                      child: const Text('종료'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      BadgeScreen(
        stepCount: _stepCount,
        distance: _distance,
        time: _seconds,
        goalSteps: _goalSteps,
        goalDistance: _goalDistance,
        dailyRecords: _dailyRecords, // 기록 전달
      ),
      CalendarScreen(
        runningGoals: _runningGoals,
        onGoalSet: _onGoalSet,
      ),
      SettingsScreen(),
    ];
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈 화면'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.trophy),
            label: '성과',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendar),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.gear),
            label: '설정',
          ),
        ],
      ),
    );
  }
}