import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // 캘린더 라이브러리

class BadgeScreen extends StatefulWidget {
  final int stepCount;
  final int goalSteps;

  BadgeScreen({required this.stepCount, this.goalSteps = 10000});

  @override
  _BadgeScreenState createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  DateTime _focusedDay = DateTime.now(); // 현재 선택된 날짜
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    bool isAchieved = widget.stepCount >= widget.goalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('성과 달성'),
      ),
      body: Column(
        children: [
          // 캘린더 영역
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(thickness: 1.0),

          // 목표 및 배지 상태 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오늘의 목표: ${widget.goalSteps} 걸음',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: isAchieved ? Colors.amber : Colors.grey,
                    child: const Icon(
                      Icons.star,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isAchieved ? '축하합니다! 목표 달성!' : '아직 목표에 도달하지 못했습니다',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  // 목표 달성 여부에 따른 배지 출력
                  ..._getBadges(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getBadges() {
    List<Widget> badges = [];

    // 예제 데이터로 날짜별 배지 설정 가능
    final Map<DateTime, List<Map<String, dynamic>>> badgeData = {
      DateTime.now(): [
        {'title': '1km 목표', 'goal': 1000, 'color': Colors.blue},
        {'title': '5km 목표', 'goal': 5000, 'color': Colors.purple},
      ],
    };

    final todayBadges = badgeData[_selectedDay ?? DateTime.now()] ?? [];

    for (var badge in todayBadges) {
      badges.add(_buildBadge(badge['title'], badge['goal'], badge['color']));
    }

    if (badges.isEmpty) {
      badges.add(const Text(
        '선택한 날짜에 달성한 목표가 없습니다.',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ));
    }

    return badges;
  }

  // 목표 달성 여부에 따라 배지 생성
  Widget _buildBadge(String text, int goal, Color color) {
    bool goalAchieved = widget.stepCount >= goal; // 목표 달성 여부 확인
    Color badgeColor = goalAchieved ? color : Colors.grey;

    return Card(
      color: badgeColor,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              goalAchieved ? Icons.check_circle : Icons.circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              '$text ${goalAchieved ? '달성!' : '도전 중...'}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
