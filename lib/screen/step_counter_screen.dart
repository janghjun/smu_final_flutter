import 'dart:async';  // StreamSubscription을 사용하려면 필요합니다.
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({Key? key}) : super(key: key);

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late StreamSubscription<StepCount> _stepCountStreamSubscription;  // StreamSubscription 선언
  int _steps = 0;

  @override
  void initState() {
    super.initState();

    // Pedometer.stepCountStream 구독
    _stepCountStreamSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (error) {
        print('Error in step count stream: $error');
      },
      onDone: () {
        print('Step count stream is done');
      },
    );
  }

  // 걸음 수 업데이트
  void _onStepCount(StepCount stepCount) {
    setState(() {
      _steps = stepCount.steps;
      print('현재 걸음 수: $_steps');  // 디버깅을 위한 출력
    });
  }

  // 목표를 달성했는지 체크
  bool _checkGoal(int goal) {
    return _steps >= goal;
  }

  @override
  void dispose() {
    // 화면이 닫힐 때 스트림 구독 취소
    _stepCountStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('걸음 수 측정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '오늘 걸음 수: $_steps',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '목표 달성 상태:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            // 뱃지 확인: 목표 달성 시 배지 부여
            ..._getBadges(),
          ],
        ),
      ),
    );
  }

  // 목표 달성 시 부여할 뱃지들을 반환하는 함수
  List<Widget> _getBadges() {
    List<Widget> badges = [];

    // 목표 달성 여부 확인 및 색상 변경
    badges.add(_buildBadge('1km 목표', 1000, Colors.blue));
    badges.add(_buildBadge('2km 목표', 2000, Colors.green));
    badges.add(_buildBadge('5km 목표', 5000, Colors.purple));
    badges.add(_buildBadge('10km 목표', 10000, Colors.orange));
    badges.add(_buildBadge('주간 50km 목표', 50000, Colors.red));
    badges.add(_buildBadge('주간 100km 목표', 100000, Colors.yellow));

    // 배지가 없다면 안내 메시지 추가
    if (badges.isEmpty) {
      badges.add(Text(
        '목표를 달성하세요!',
        style: TextStyle(fontSize: 20, color: Colors.grey),
      ));
    }

    return badges;
  }

  // 목표 달성 여부에 따라 배지를 생성하는 함수
  Widget _buildBadge(String text, int goal, Color color) {
    bool goalAchieved = _checkGoal(goal);  // 목표 달성 여부 확인
    Color badgeColor = goalAchieved ? color : Colors.grey;  // 달성시 색상 변경

    return Card(
      color: badgeColor,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              goalAchieved ? Icons.check_circle : Icons.circle,  // 달성 여부에 따른 아이콘 변경
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              '$text ${goalAchieved ? '달성!' : '도전 중...'}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
