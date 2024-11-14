import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smp_final_project/screen/settings_screen.dart';
import 'package:smp_final_project/screen/step_counter_screen.dart';  // StepCounterScreen 추가
import 'package:smp_final_project/screen/badge_screen.dart';  // BadgeScreen 추가

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  int _steps = 0;  // 걸음 수 저장 변수

  // Step_Counter_Screen에서 걸음 수 업데이트
  void _updateStepCount(int steps) {
    setState(() {
      _steps = steps;
    });
  }

  // 페이지들을 미리 정의 걸음 수 업데이트
  final List<Widget> _pages = [
    // Center(
    //   child: Text(
    //     '홈',
    //     style: TextStyle(
    //       fontSize: 25.0,
    //     ),
    //   ),
    // ),
    // Center(
    //   child: Text(
    //     '성과',
    //     style: TextStyle(
    //       fontSize: 25.0,
    //     ),
    //   ),
    // ),
    // SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 페이지들 초기화 StepCounterScreen에 onStepsChanged 콜백 전달
    _pages.add(StepCounterScreen(onStepsChanged: (steps) {
      _updateStepCount(steps);  // 걸음 수 업데이트
    }));
    _pages.add(BadgeScreen(stepCount: _steps));  // BadgeScreen으로 걸음 수 전달
    _pages.add(SettingsScreen());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
