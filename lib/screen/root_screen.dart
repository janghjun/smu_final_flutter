import 'dart:async'; // 타이머 관련
import 'dart:math'; // 수학 함수 및 상수 사용
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:smp_final_project/screen/badge_screen.dart';
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

  final List<LatLng> _routePoints = []; // 이동 경로를 저장할 리스트
  final Set<Polyline> _polylines = {};

  StreamSubscription<Position>? _positionStreamSubscription;

  // 타이머 관련 변수
  bool _isButtonVisible = true;
  bool _isTimerRunning = false;
  int _seconds = 0; // 타이머 값을 초 단위로 관리
  late Timer _timer;

  int _stepCount = 0;
  double _distance = 0.0;

  // pedometer 스트림을 사용하여 걸음 수 추적
  late StreamSubscription<StepCount?> _stepCountStreamSubscription;

  // 버튼 스타일 변수화
  final buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(150, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    padding: const EdgeInsets.all(16.0),
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadInitialLocation();
    _startPedometer();
  }

  void _startPedometer() {
    _stepCountStreamSubscription =
        Pedometer.stepCountStream.listen((StepCount stepCount) {
          setState(() {
            _stepCount = stepCount.steps; // StepCount 객체에서 steps 사용
          });
        });
  }

  // 네비게이션 탭 변경
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadInitialLocation() async {
    await _getCurrentLocation();
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
    const double earthRadius = 6731;
    double latDiff = _degreeToRadian(end.latitude - start.latitude);
    double lngDiff = _degreeToRadian(end.longitude - start.longitude);

    double a = sin(latDiff / 2) * sin(latDiff / 2) +
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

  // 경로 추적 시작
  void _startTracking() {
    _resetState();

    // 위치 스트림 구독 시작
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: const LocationSettings())
            .listen((Position position) {
          final LatLng newLatLng = LatLng(position.latitude, position.longitude);
          setState(() {
            _currentLatLng = newLatLng;
            _routePoints.add(newLatLng); // 새 위치를 경로 리스트에 추가
          });

          // 카메라 이동
          if (_mapController != null) {
            _mapController.animateCamera(
              CameraUpdate.newLatLng(newLatLng),
            );
          }
        });

    // 타이머 시작
    _startTimer();
  }

  void _resetState() {
    setState(() {
      _isButtonVisible = false;
      _isTimerRunning = true;
      _routePoints.clear(); // 이전 경로 초기화
      _seconds = 0; // 타이머 초기화
    });
  }

  // 타이머 시작
  void _startTimer() {
    setState(() {
      _isButtonVisible = false;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  // 타이머 멈추기
  void _stopTimer() {
    setState(() {
      _timer.cancel();
      _isTimerRunning = false;
    });
  }

  // 타이머 멈추기 및 경로 추적 종료
  void _stopTracking() {
    _stopTimer();
    _positionStreamSubscription?.cancel(); // 위치 스트림 구독 해제
    setState(() {
      _isButtonVisible = true;
      // 멈춘 시간은 계속 화면에 보이도록 유지
    });
  }

  // 홈으로 돌아가기
  void _endSession() {
    setState(() {
      _timer.cancel();
      _isTimerRunning = false;
      _selectedIndex = 1; // 성과 화면으로 이동
    });
  }

  @override
  void dispose() {
    _stepCountStreamSubscription?.cancel();
    _timer.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // 시간 포맷팅
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${_padZero(hours)}:${_padZero(minutes)}:${_padZero(remainingSeconds)}';
  }

  String _padZero(int value) {
    return value.toString().padLeft(2, '0');
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
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
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
                    myLocationButtonEnabled: true,
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
                    _buildInfoCard('거리', '${_distance.toStringAsFixed(2)}km'),
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
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120.0, 50.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
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
      BadgeScreen(stepCount: _stepCount),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈 화면'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.trophy),
            label: '성공',
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