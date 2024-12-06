import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'root_screen.dart'; // RootScreen 파일 임포트

// 상태 관리 모델 추가
class BadgeModel extends ChangeNotifier {
  final Map<DateTime, List<Map<String, dynamic>>> _badgeData = {};

  Map<DateTime, List<Map<String, dynamic>>> get badgeData => _badgeData;

  void addBadge(DateTime date, String title, int goal, Color color) {
    _badgeData[date] ??= [];
    _badgeData[date]!.add({'title': title, 'goal': goal, 'color': color});
    notifyListeners();
  }

  List<Map<String, dynamic>> getBadgesForDate(DateTime date) {
    return _badgeData[date] ?? [];
  }
}

class BadgeScreen extends StatelessWidget {
  final int stepCount;
  final int goalSteps;

  BadgeScreen({required this.stepCount, this.goalSteps = 10000});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BadgeModel(),
      child: BadgeScreenContent(stepCount: stepCount, goalSteps: goalSteps),
    );
  }
}

class BadgeScreenContent extends StatefulWidget {
  final int stepCount;
  final int goalSteps;

  BadgeScreenContent({required this.stepCount, this.goalSteps = 10000});

  @override
  _BadgeScreenContentState createState() => _BadgeScreenContentState();
}

class _BadgeScreenContentState extends State<BadgeScreenContent>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAchieved = widget.stepCount >= widget.goalSteps;
    if (isAchieved) _animationController.forward();

    return Scaffold(
      appBar: AppBar(
        title: const Text('성과 달성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RootScreen()),
            );
          },
        ),
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
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.2)
                        .animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.bounceOut,
                    )),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor:
                      isAchieved ? Colors.amber : Colors.grey,
                      child: const Icon(
                        Icons.star,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isAchieved
                        ? '축하합니다! 목표 달성!'
                        : '아직 목표에 도달하지 못했습니다',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  Consumer<BadgeModel>(
                    builder: (context, badgeModel, child) {
                      final todayBadges = badgeModel
                          .getBadgesForDate(_selectedDay ?? DateTime.now());
                      return Column(
                        children: todayBadges.isNotEmpty
                            ? todayBadges
                            .map((badge) => _buildBadge(
                            badge['title'],
                            badge['goal'],
                            badge['color']))
                            .toList()
                            : [
                          const Text(
                            '선택한 날짜에 달성한 목표가 없습니다.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, int goal, Color color) {
    bool goalAchieved = widget.stepCount >= goal;
    return Card(
      color: goalAchieved ? color : Colors.grey,
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