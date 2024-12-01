//main_view_model_google.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smp_final_project/screen/google_login.dart'; // 구글 로그인 클래스 임포트

class GoogleMainViewModel {
  final GoogleLogin _googleLogin;

  bool isLogined = false;

  GoogleMainViewModel(this._googleLogin);

  // 구글 로그인 처리
  Future<void> login() async {
    try {
      final UserCredential? userCredential = await _googleLogin.signInWithGoogle();
      if (userCredential != null) {
        isLogined = true;
        print("구글 로그인 성공");
      } else {
        isLogined = false;
        print("구글 로그인 실패");
      }
    } catch (e) {
      print("구글 로그인 오류: $e");
      isLogined = false;
    }
  }

  // 구글 로그아웃 처리
  Future<void> logout() async {
    await _googleLogin.signOut();
    isLogined = false;
    print("구글 로그아웃");
  }
}



