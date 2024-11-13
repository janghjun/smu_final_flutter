import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/root_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lets Run!!',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이미지 클릭 가능하도록 만들기
              GestureDetector(
                onTap: () {
                  // 이미지 클릭 시 홈 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RootScreen(),
                    ),
                  );
                },
                child: Image.asset(
                  'asset/img/directions_run.png',
                  width: 200.0,
                  height: 200.0,
                ),
              ),
              SizedBox(height: 10.0,), // 이미지와 버튼 사이의 간격
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RootScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200.0, 60.0),
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}