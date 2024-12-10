import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final Map<DateTime, Map<String, dynamic>> runningGoals;
  final Function(DateTime, Map<String, dynamic>) onGoalSet;

  const CalendarScreen({
    Key? key,
    required this.runningGoals,
    required this.onGoalSet,
  }) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _setRunningGoal(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('러닝 목표 설정'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: '제목'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: '설명'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stepsController,
                decoration: const InputDecoration(hintText: '목표 걸음 수'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _distanceController,
                decoration: const InputDecoration(hintText: '목표 거리 (km)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty &&
                  _stepsController.text.isNotEmpty &&
                  _distanceController.text.isNotEmpty) {
                widget.onGoalSet(date, {
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'steps': int.tryParse(_stepsController.text) ?? 0,
                  'distance': double.tryParse(_distanceController.text) ?? 0.0,
                });
                _titleController.clear();
                _descriptionController.clear();
                _stepsController.clear();
                _distanceController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                _setRunningGoal(selectedDay);
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
            ),
            const Divider(),
            if (_selectedDay != null &&
                widget.runningGoals[_selectedDay!] != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '목표 (${_selectedDay!.toLocal()}):',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '제목: ${widget.runningGoals[_selectedDay!]!['title']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '설명: ${widget.runningGoals[_selectedDay!]!['description']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '걸음 수: ${widget.runningGoals[_selectedDay!]!['steps']} 걸음',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '거리: ${widget.runningGoals[_selectedDay!]!['distance']} km',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '설정된 목표가 없습니다.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}