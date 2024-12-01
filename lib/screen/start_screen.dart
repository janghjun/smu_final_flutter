import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/root_screen.dart';
import 'package:smp_final_project/screen/main_view_model.dart'; // 카카오 로그인 Viewmodel
import 'package:smp_final_project/screen/main_view_model_google.dart'; // 구글 로그인 ViewModel
import 'package:smp_final_project/screen/kakao_login.dart'; // 카카오 로그인
import 'package:smp_final_project/screen/google_login.dart'; // 구글 로그인
import 'package:firebase_auth/firebase_auth.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({
    super.key,
    required this.title
  });

  final String title;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final kakaoViewModel = MainViewModel(KakaoLogin()); // 카카오 로그인 ViewModel
  final googleViewModel = GoogleMainViewModel(GoogleLogin()); // 구글 로그인 ViewModel

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
                  width: 150.0,
                  height: 150.0,
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
              SizedBox(height: 10.0), // start버튼과 로그인 버튼 사이의 간격

              // 로그인 상태에 따라 카카오, 구글 로그인 버튼을 아래에 표시
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 카카오 로그인 버튼
                        GestureDetector(
                          onTap: () async {
                            await kakaoViewModel.login(); // 카카오 로그인
                            setState(() {});
                          },
                          child: Image.asset(
                            'asset/img/Kakao.png', // 카카오 로그인 이미지
                            width: 200.0,
                            height: 60.0,
                          ),
                        ),
                        //SizedBox(height: 20.0),
                        // 구글 로그인 버튼
                        GestureDetector(
                          onTap: () async {
                            await googleViewModel.login(); // 구글 로그인
                            setState(() {});
                          },
                          child: Image.asset(
                            'asset/img/Google.png', // 구글 로그인 이미지
                            width: 200.0,
                            height: 60.0,
                          ),
                        ),
                      ],
                    );
                  }

                  // 사용자가 로그인한 경우
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(
                        snapshot.data?.photoURL ?? 'asset/img/1.png', // 사용자 프로필 이미지
                        width: 90.0,
                        height: 90.0,
                      ),
                      Text(
                        'Logged in as: ${snapshot.data?.displayName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut(); // 로그아웃 처리
                          setState(() {});
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}