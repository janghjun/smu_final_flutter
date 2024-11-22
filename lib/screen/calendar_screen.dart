import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  final Map<DateTime, String> runningGoals;
  final Function(DateTime, String) onGoalSet;

  const CalendarScreen({
    Key? key,
    required this.runningGoals,
    required this.onGoalSet,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _showTodayGoal = true;

  // 홈 화면에서 전달받은 데이터
  final Map<String, dynamic> _todayData = {
    "steps": 0,
    "distance": 0.0,
    "time": "00:00:00",
  };

  // 뱃지 데이터 예시
  final List<String> _achievedBadges = ["10,000 Steps Badge", "5km Badge"];
  final List<String> _inProgressBadges = ["20,000 Steps Badge", "10km Badge"];
  final List<String> _inactiveBadges = ["Marathon Badge"];

  // 오늘 목표 및 뱃지 화면 전환
  void _toggleView(bool showTodayGoal) {
    setState(() {
      _showTodayGoal = showTodayGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayGoal = widget.runningGoals[today] ?? "목표가 설정되지 않았습니다.";

    return Column(
      children: [
        // 캘린더와 하단 버튼 영역
        Expanded(
          flex: 4,
          child: Center(
            child: Text(
              "캘린더 구현 영역",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ),
        ),
        // 버튼 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _toggleView(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _showTodayGoal ? Colors.blue : Colors.grey,
              ),
              child: const Text("오늘 목표"),
            ),
            ElevatedButton(
              onPressed: () => _toggleView(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: !_showTodayGoal ? Colors.blue : Colors.grey,
              ),
              child: const Text("달성 뱃지"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 오늘 목표 또는 뱃지 정보 표시
        Expanded(
          flex: 2,
          child: _showTodayGoal
              ? _buildTodayGoalView(todayGoal)
              : _buildBadgeView(),
        ),
      ],
    );
  }

  // 오늘 목표 화면
  Widget _buildTodayGoalView(String todayGoal) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "오늘 목표",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          todayGoal,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Text(
          "오늘 데이터",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("걸음 수: ${_todayData['steps']} 걸음"),
        Text("거리: ${_todayData['distance'].toStringAsFixed(2)} km"),
        Text("시간: ${_todayData['time']}"),
      ],
    );
  }

  // 뱃지 화면
  Widget _buildBadgeView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "달성한 뱃지",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._achievedBadges.map((badge) => ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: Text(badge),
        )),
        const Divider(),
        const Text(
          "진행 중인 뱃지",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._inProgressBadges.map((badge) => ListTile(
          leading: const Icon(Icons.star_half, color: Colors.blue),
          title: Text(badge),
        )),
        const Divider(),
        const Text(
          "진행하지 않는 뱃지",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ..._inactiveBadges.map((badge) => ListTile(
          leading: const Icon(Icons.star_outline, color: Colors.grey),
          title: Text(badge),
        )),
      ],
    );
  }
}