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

  // 타이머 관련 변수
  bool _isButtonVisible = true;
  bool _isTimerRunning = false;
  int _seconds = 0; // 타이머 값을 초 단위로 관리
  late Timer _timer;

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

    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLatLng!),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // 네비게이션 탭 변경
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 타이머 시작
  void _startTimer() {
    setState(() {
      _isButtonVisible = false; // 시작 버튼 숨기기
      _isTimerRunning = true; // 타이머 실행 상태로 변경
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++; // 초 증가
      });
    });
  }

  // 타이머 멈추기
  void _stopTimer() {
    setState(() {
      _timer.cancel(); // 타이머 멈추기
      _isTimerRunning = false; // 타이머 실행 상태 종료
    });
  }

  // 홈으로 돌아가기 (되돌아가기 버튼)
  void _goHome() {
    setState(() {
      _seconds = 0; // 타이머 리셋
      _isButtonVisible = true; // 시작 버튼 표시
      _isTimerRunning = false; // 타이머 실행 상태 종료
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 리소스 해제
    super.dispose();
  }

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
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
          // 지도 영역
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
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black.withOpacity(0.2), // 불투명
                  ),
                ),
              ],
            ),
          ),
          // 하단 정보 영역
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard('걸음 수', '0'),
                    _buildInfoCard('거리', '0.0 km'),
                    _buildInfoCard('시간', _formatTime(_seconds)),
                  ],
                ),
                const SizedBox(height: 16.0),
                _isButtonVisible
                    ? ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('시작'),
                )
                    : ElevatedButton(
                  onPressed: _stopTimer,
                  child: const Text('중지'),
                ),
              ],
            ),
          ),
        ],
      ),
      BadgeScreen(stepCount: 0),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('홈 화면')),
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
        items: const [
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
