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

  bool _isTimerRunning = false;
  int _seconds = 0;
  Timer? _timer;

  int _stepCount = 0; // 걸음 수 저장
  double _distance = 0.0; // 거리 저장

  StreamSubscription<StepCount>? _stepCountStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 현재 위치 가져오기
    _startPedometer(); // 걸음 수 측정 시작
  }

  @override
  void dispose() {
    _stepCountStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // 걸음 수 측정
  void _startPedometer() {
    _stepCountStreamSubscription = Pedometer.stepCountStream.listen(
          (StepCount stepCount) {
        setState(() {
          _stepCount = stepCount.steps; // 실시간 걸음 수 업데이트
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('걸음 수 센서 오류: $error')),
        );
      },
    );
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final Position position = await Geolocator.getCurrentPosition();
    _updateRoute(LatLng(position.latitude, position.longitude));
  }

  // 경로 업데이트
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

    _mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  // 거리 계산
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // 지구 반지름 (단위: km)
    double latDiff = _degreeToRadian(end.latitude - start.latitude);
    double lngDiff = _degreeToRadian(end.longitude - start.longitude);

    double a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(_degreeToRadian(start.latitude)) *
            cos(_degreeToRadian(end.latitude)) *
            sin(lngDiff / 2) *
            sin(lngDiff / 2);

    return 2 * earthRadius * atan2(sqrt(a), sqrt(1 - a));
  }

  double _degreeToRadian(double degree) => degree * pi / 180;

  // 타이머 시작
  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  // 타이머 정지
  void _stopTimer() {
    setState(() {
      _timer?.cancel();
      _isTimerRunning = false;
    });
  }

  // 세션 종료
  void _endSession() {
    setState(() {
      _timer?.cancel();
      _isTimerRunning = false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BadgeScreen(
            stepCount: _stepCount,
            goalSteps: 10000, // 목표 걸음 수 (예시)
          ),
        ),
      );
    });
  }

  // 시간 포맷팅
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomePage(),
      BadgeScreen(stepCount: _stepCount),
      CalendarScreen(
        runningGoals: {},
        onGoalSet: (date, goal) {
          // 캘린더 목표 설정 시 실행되는 콜백
        },
      ),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈 화면'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.home,
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.trophy,
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            label: '성과',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.calendar,
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.gear,
              color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
            ),
            label: '설정',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _currentLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 16,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: _polylines,
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
                  ElevatedButton(
                    onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                    child: Text(_isTimerRunning ? '정지' : '시작'),
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
    );
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
                style: const TextStyle(
                    fontSize: 20.0, color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
