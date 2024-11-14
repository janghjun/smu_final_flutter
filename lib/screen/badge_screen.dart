import 'package:flutter/material.dart';

class BadgeScreen extends StatelessWidget {
  final int stepCount;
  final int goalSteps;

  BadgeScreen({required this.stepCount, this.goalSteps = 10000});

  @override
  Widget build(BuildContext context) {
    bool isAchieved = stepCount >= goalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text('성과 달성'),
      ),
      body: Center(
        child: SingleChildScrollView(  // 화면에 text가 넘쳐서 생기는 오류 1. SingleChildScrollView로 감싸기
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '오늘의 목표: $goalSteps 걸음',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // 2. CircleAvatar 크기 조정
              CircleAvatar(
                radius: 60,
                backgroundColor: isAchieved ? Colors.amber : Colors.grey,
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                isAchieved ? '축하합니다! 목표 달성!' : '아직 목표에 도달하지 못했습니다',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              // 목표 달성 여부에 따른 배지 출력
              ..._getBadges(),
            ],
          ),
        ),
      ),
    );
  }

  // 목표 달성 시 부여할 배지들 반환
  List<Widget> _getBadges() {
    List<Widget> badges = [];

    // 목표 달성 여부 확인 및 배지 추가
    badges.add(_buildBadge('1km 목표', 1000, Colors.blue));
    badges.add(_buildBadge('2km 목표', 2000, Colors.green));
    badges.add(_buildBadge('5km 목표', 5000, Colors.purple));
    badges.add(_buildBadge('10km 목표', 10000, Colors.orange));
    badges.add(_buildBadge('주간 50km 목표', 50000, Colors.red));
    badges.add(_buildBadge('주간 100km 목표', 100000, Colors.yellow));

    if (badges.isEmpty) {
      badges.add(Text(
        '목표를 달성하세요!',
        style: TextStyle(fontSize: 20, color: Colors.grey),
      ));
    }

    return badges;
  }

  // 목표 달성 여부에 따라 배지 생성
  Widget _buildBadge(String text, int goal, Color color) {
    bool goalAchieved = stepCount >= goal;  // 목표 달성 여부 확인
    Color badgeColor = goalAchieved ? color : Colors.grey;

    return Card(
      color: badgeColor,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              goalAchieved ? Icons.check_circle : Icons.circle,
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
