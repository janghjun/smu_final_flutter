import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smp_final_project/screen/badge_screen.dart';
import 'package:smp_final_project/screen/settings_screen.dart';
import 'package:smp_final_project/screen/start_screen.dart';
import 'package:smp_final_project/screen/step_counter_screen.dart';  // StepCounterScreen 추가
import 'package:smp_final_project/screen/badge_screen.dart';  // BadgeScreen 추가

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭
  int _steps = 0; // 걸음 수 저장
  LatLng? _currentLatLng; // 현재 위치 저장
  late GoogleMapController _mapController;

  // 걸음 수 업데이트
  void _updateStepCount(int steps) {
    setState(() {
      _steps = steps;
    });
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

    // 지도 중심을 현재 위치로 이동
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLatLng!),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 현재 위치 가져오기
  }

  // 네비게이션 탭 변경
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 페이지들 설정
    final List<Widget> _pages = [
      _currentLatLng == null
          ? const Center(child: CircularProgressIndicator()) // 로딩 상태
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
      BadgeScreen(stepCount: _steps), // 성과 화면
      const SettingsScreen(), // 환경설정 화면
    ];

    return Scaffold(
      appBar: _selectedIndex == 0 // 홈 탭에서만 AppBar 표시
          ? AppBar(
        title: const Text('시작 화면'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const StartScreen(),
              ),
            );
          },
        ),
      )
          : null, // 다른 탭에서는 AppBar를 표시하지 않음
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex, // 선택된 탭에 맞는 페이지 표시
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 현재 인덱스에 맞는 탭 선택
        onTap: _onItemTapped, // 탭 클릭 시 인덱스 변경
        selectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
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
