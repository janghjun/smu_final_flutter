import 'package:flutter/material.dart';

class BadgeScreen extends StatelessWidget {
  final int stepCount; // 현재 걸음 수
  final double distance; // 현재 거리
  final int time; // 총 시간
  final int goalSteps; // 목표 걸음 수
  final double goalDistance; // 목표 거리
  final List<Map<String, dynamic>> dailyRecords; // 하루 운동 기록 리스트

  const BadgeScreen({
    Key? key,
    required this.stepCount,
    required this.distance,
    required this.time,
    required this.goalSteps,
    required this.goalDistance,
    required this.dailyRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성과'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘의 목표
              const Text(
                '오늘의 목표:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildGoalRow('걸음 수', stepCount, goalSteps, goalSteps - stepCount),
              _buildGoalRow('거리', distance.toStringAsFixed(2), goalDistance.toStringAsFixed(2),
                  (goalDistance - distance).toStringAsFixed(2)),
              const Divider(height: 30),

              // 기록된 데이터
              const Text(
                '기록된 데이터:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (dailyRecords.isNotEmpty)
                ...dailyRecords.map((record) => _buildRecordedDataCard(record)).toList()
              else
                const Text(
                  '기록된 데이터가 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalRow(String title, dynamic current, dynamic goal, dynamic remaining) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title: $current / $goal (남은: $remaining)',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordedDataCard(Map<String, dynamic> record) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '걸음 수: ${record['steps']} 걸음',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '거리: ${record['distance'].toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '시간: ${_formatTime(record['time'])}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
