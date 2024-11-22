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
  List<String> docIds = []; // 각 제목에 대응하는 Firestore 문서 ID 목록

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
        docIds = snapshot.docs
            .map((doc) => doc.id) // 문서 ID를 함께 저장
            .toList();
      });
    } catch (e) {
      print('제목 가져오기 오류: $e');
    }
  }

  // 제목 삭제 함수
  Future<void> _deleteTitle(String docId, int index) async {
    try {
      // Firestore에서 해당 제목 삭제
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(docId)
          .delete();

      // 화면에서 제목 삭제
      setState(() {
        titles.removeAt(index); // 제목 목록에서 삭제
        docIds.removeAt(index);  // 해당 제목에 대응하는 문서 ID도 삭제
      });
    } catch (e) {
      print('제목 삭제 오류: $e');
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
          '등록된 게시물이 없습니다.',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        )
            : ListView.builder(
          itemCount: titles.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '제목 : ',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: titles[index],
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ), // Firestore에서 가져온 제목 표시
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // 삭제 버튼 클릭 시 해당 제목만 삭제
                      _deleteTitle(docIds[index], index);
                    },
                  ), // 삭제 버튼 추가
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0), // 상하 간격 조정
                  height: 1.0, // 선 두께
                  color: Colors.grey, // 선 색상
                ),
              ],
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

