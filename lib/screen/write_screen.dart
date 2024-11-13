import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/question_screen.dart';

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

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '경고',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        content: Text('작성 내용이 저장되지 않을 수 있습니다. 계속 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '취소',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(),
                ),
              );
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(),
                      ),
                    );
                  },
                  child: Text('확인'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.0, 60.0),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
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