import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smp_final_project/firebase_options.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:smp_final_project/state/title_state.dart'; // TitleState import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Provider를 앱의 최상위에 추가
    ChangeNotifierProvider(
      create: (_) => TitleState(), // TitleState 초기화
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(), // 앱의 시작 화면
      debugShowCheckedModeBanner: false,
    );
  }
}
