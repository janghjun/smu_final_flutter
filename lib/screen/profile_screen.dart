import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smp_final_project/screen/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;  // 프로필 이미지를 저장할 변수
  String _nickname = ''; // 닉네임 저장 변수
  final ImagePicker _picker = ImagePicker();  // ImagePicker 객체 생성

  // 이미지를 선택하는 함수
  Future<void> _pickImage() async {
    // 갤러리에서 이미지를 선택할 수 있도록 설정
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // 선택한 이미지를 File 객체로 변환하여 저장
      });
    }
  }

  // 환경설정 페이지로 이동하는 함수
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SettingsScreen() //
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: SingleChildScrollView(  // 화면을 스크롤 가능하게 만듦
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage('asset/img/account_circle.png') as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('프로필 이미지 변경'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.0, 60.0),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      _nickname = text;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '닉네임 변경',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _navigateToSettings,
                  child: Text('확인'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200.0, 60.0),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}