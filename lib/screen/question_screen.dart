import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/write_screen.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Q & A'),
      ),
      body: Center(
        child: Text('질문 목록'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteScreen()),
          );
        },
        child: Icon(Icons.edit),
        tooltip: '글쓰기',
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }
}