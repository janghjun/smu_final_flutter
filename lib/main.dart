import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smp_final_project/firebase_options.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:smp_final_project/state/title_state.dart'; // TitleState import
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:smp_final_project/provider/theme_provider.dart'; // ThemeProvider import
import 'package:flutter_localizations/flutter_localizations.dart';  // 추가

void main() async {
  // Kakao SDK 초기화
  kakao.KakaoSdk.init(nativeAppKey: '6281646518bb69ca2ffc8dd7550d6fe6');

  // Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Provider를 앱의 최상위에 추가
    ChangeNotifierProvider(
      create: (_) => TitleState(), // TitleState 초기화
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(), // 다크모드를 위한 ThemeProvider 추가
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: "Let's run!!",
          theme: ThemeData(
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light, // 다크모드 전환
            primarySwatch: Colors.blue,
          ),
          home: const StartScreen(title: "Let's run!!"), // 앱의 시작 화면
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('ko', 'KR'),  // 한국어 지원
            Locale('en', 'US'),  // 영어 지원
          ],
        );
      },
    );
  }
}
