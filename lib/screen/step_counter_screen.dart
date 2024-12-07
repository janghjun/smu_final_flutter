import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepCounterScreen extends StatefulWidget {
  final Function(int) onStepsChanged;  // 걸음 수 업데이트 콜백

  const StepCounterScreen({Key? key, required this.onStepsChanged}) : super(key: key);

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  late StreamSubscription<StepCount> _stepCountStreamSubscription;
  int _steps = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Pedometer.stepCountStream
    _stepCountStreamSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (error) {
        print('Error in step count stream: $error');
        setState(() {
          _errorMessage = '걸음 수 스트림 에러 : $error';
        });
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
      widget.onStepsChanged(_steps);  // 걸음 수가 업데이트되면 RootScreen에 콜백 호출
      print('현재 걸음 수: $_steps');
    });
  }

  @override
  void dispose() {
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
            if(_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
            Text(
              '오늘 걸음 수: $_steps',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}