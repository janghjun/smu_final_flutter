import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 임포트
import 'package:smp_final_project/screen/write_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<String> titles = []; // Firestore에서 가져올 제목 목록

  // Firestore에서 제목 목록을 가져오는 함수
  Future<void> _fetchTitles() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true) // 생성일 기준으로 내림차순 정렬
          .get();

      setState(() {
        titles = snapshot.docs
            .map((doc) => doc['title'] as String)
            .toList(); // Firestore에서 제목만 추출하여 리스트로 저장
      });
    } catch (e) {
      print('제목 가져오기 오류: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTitles(); // 화면 로딩 시 제목 목록을 가져옵니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Q & A'),
      ),
      body: Center(
        child: titles.isEmpty
            ? Text(
          '등록된 제목이 없습니다.',
          style: TextStyle(fontSize: 16),
        )
            : ListView.builder(
          itemCount: titles.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(titles[index]), // Firestore에서 가져온 제목 표시
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // WriteScreen에서 제목을 입력받고 돌아옴
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WriteScreen(),
            ),
          );
          if (result != null) {
            setState(() {
              titles.add(result); // 새로 작성된 제목을 목록에 추가
            });
          }
        },
        child: Icon(Icons.edit),
        tooltip: '글쓰기',
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }
}
