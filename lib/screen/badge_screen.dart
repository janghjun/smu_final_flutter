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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '오늘의 목표: $goalSteps 걸음',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 80,
              backgroundColor: isAchieved ? Colors.amber : Colors.grey,
              child: Icon(
                Icons.star,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              isAchieved ? '축하합니다! 목표 달성!' : '아직 목표에 도달하지 못했습니다',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
