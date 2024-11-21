import 'dart:async'; // 타이머 관련
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smp_final_project/screen/badge_screen.dart';
import 'package:smp_final_project/screen/settings_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  LatLng? _currentLatLng;
  late GoogleMapController _mapController;
  List<LatLng> _routePoints = []; // 이동 경로를 저장할 리스트
  StreamSubscription<Position>? _positionStreamSubscription;

  // 타이머 관련 변수
  bool _isButtonVisible = true;
  bool _isTimerRunning = false;
  int _seconds = 0; // 타이머 값을 초 단위로 관리
  late Timer _timer;

  // 버튼 스타일 변수화
  final buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(150, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    padding: const EdgeInsets.all(16.0),
  );

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
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
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    if (_mapController != null && _currentLatLng != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLatLng!),
      );
    }
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  // 타이머 멈추기
  void _stopTimer() {
    _timer.cancel();
    setState(() {
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
  void _goHome() {
    _stopTimer();
    _positionStreamSubscription?.cancel(); // 위치 스트림 구독 해제
    setState(() {
      _isButtonVisible = true;
      _isTimerRunning = false;
      _routePoints.clear(); // 이전 경로 초기화
      _seconds = 0; // 타이머 값 초기화
    });
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

  // 네비게이션 탭 변경
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center, // 위젯들 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.center,
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
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _isButtonVisible
                  ? ElevatedButton(
                onPressed: _startTracking,
                style: buttonStyle,
                child: const Icon(
                  Icons.play_arrow_outlined,
                  size: 30.0,
                  color: Colors.black,
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 멈춘 시간은 계속 표시됨
                  Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                    ),
                  ),
                  // 멈춤 버튼은 타이머가 실행 중일 때만 보이도록
                  if (_isTimerRunning)
                    ElevatedButton(
                      onPressed: _stopTracking,
                      style: buttonStyle,
                      child: const Icon(
                        Icons.stop,
                        size: 25.0,
                        color: Colors.black,
                      ),
                    ),
                  // 홈 버튼은 항상 표시
                  ElevatedButton(
                    onPressed: _goHome,
                    style: buttonStyle,
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 25.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      BadgeScreen(stepCount: 0),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: const Text('홈 화면'),
      )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.trophy),
            label: '성과',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '환경설정',
          ),
        ],
      ),
    );
  }
}
