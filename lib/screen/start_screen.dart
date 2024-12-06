import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/root_screen.dart';
import 'package:smp_final_project/screen/main_view_model.dart'; // 카카오 로그인 Viewmodel
import 'package:smp_final_project/screen/main_view_model_google.dart'; // 구글 로그인 ViewModel
import 'package:smp_final_project/screen/kakao_login.dart'; // 카카오 로그인
import 'package:smp_final_project/screen/google_login.dart'; // 구글 로그인
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smp_final_project/provider/theme_provider.dart'; // ThemeProvider import

class StartScreen extends StatefulWidget {
  const StartScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final kakaoViewModel = MainViewModel(KakaoLogin());
  final googleViewModel = GoogleMainViewModel(GoogleLogin());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lets Run!!',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.dark_mode,
              size: 30.0,
            ),
            onPressed: () {
              // 다크모드 토글
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RootScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                child: Image.asset(
                  'asset/img/directions_run.png',
                  width: 150.0,
                  height: 150.0,
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RootScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200.0, 60.0),
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Start'),
              ),
              const SizedBox(height: 20.0),
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            try {
                              await kakaoViewModel.login();
                              setState(() {});
                            } catch (e) {
                              _showErrorDialog('카카오 로그인 실패', e.toString());
                            }
                          },
                          child: Image.asset(
                            'asset/img/Kakao.png',
                            width: 200.0,
                            height: 60.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () async {
                            try {
                              await googleViewModel.login();
                              setState(() {});
                            } catch (e) {
                              _showErrorDialog('구글 로그인 실패', e.toString());
                            }
                          },
                          child: Image.asset(
                            'asset/img/Google.png',
                            width: 200.0,
                            height: 60.0,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data?.photoURL ?? 'asset/img/default_profile.png',
                        ),
                        radius: 45.0,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '안녕하세요, ${snapshot.data?.displayName ?? "사용자"}님!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
