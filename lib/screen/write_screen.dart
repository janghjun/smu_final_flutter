import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:smp_final_project/screen/question_screen.dart';
import 'package:smp_final_project/state/title_state.dart'; // TitleState import

class WriteScreen extends StatefulWidget {
  const WriteScreen({Key? key}) : super(key: key);

  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _contentCharCount = 0;
  final int _maxCharCount = 500;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateCharCount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.removeListener(_updateCharCount);
    _contentController.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    setState(() {
      _contentCharCount = _contentController.text.length;
    });
  }

  // Firestore에 제목과 내용을 저장하는 함수
  Future<void> _saveToFirestore() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      // 제목이나 내용이 비어있으면 저장하지 않음
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'content': content,
        'createdAt': Timestamp.now(),
      });

      // TitleState의 상태 업데이트
      Provider.of<TitleState>(context, listen: false).addTitle(title);

      // 저장 후 이전 화면으로 돌아감
      Navigator.pop(context, title);
    } catch (e) {
      print('Error saving to Firestore: $e');
      // 오류 처리
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '경고',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('작성 내용이 저장되지 않을 수 있습니다. 계속 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '취소',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.pop(context);
            },
            child: Text(
              '확인',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('글쓰기'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: Stack(
                  children: [
                    TextField(
                      controller: _contentController,
                      maxLength: _maxCharCount,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        labelText: '내용',
                        border: OutlineInputBorder(),
                        counterText: '', // 기본 counterText 비우기
                      ),
                    ),
                    Positioned(
                      right: 16.0,
                      bottom: 16.0,
                      child: Text(
                        '$_contentCharCount/$_maxCharCount',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _saveToFirestore, // Firestore에 저장하는 함수 연결
                  child: Text('확인'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.0, 60.0),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
