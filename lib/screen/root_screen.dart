import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smp_final_project/screen/badge_screen.dart';
import 'package:smp_final_project/screen/settings_screen.dart';
import 'package:smp_final_project/screen/start_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  LatLng? _currentLatLng; // 현재 위치 저장
  late GoogleMapController _mapController;

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
      _selectedIndex = index; // 선택된 탭 인덱스를 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    // Root 화면의 3개 페이지 정의
    final List<Widget> _pages = [
      Column(
        children: [
          Expanded(
            flex: 4, // 화면의 3/4 차지
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
            flex: 1, // 화면의 1/4 차지
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('시작 버튼을 눌렀습니다!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.all(16.0)
                ),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                      fontSize: 18.0,
                    color: Colors.black
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      BadgeScreen(stepCount: 0), // 성과 화면
      const SettingsScreen(), // 환경설정 화면
    ];

    return Scaffold(
      appBar: _selectedIndex == 0 // 홈 탭에서만 AppBar 표시
          ? AppBar(
        title: const Text('홈 화면'),
      )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex, // 선택된 탭 인덱스에 따라 화면 표시
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 현재 선택된 탭 인덱스
        onTap: _onItemTapped, // 탭 클릭 시 선택된 인덱스를 변경
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
