//google_login.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  // 구글 로그인 함수
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // GoogleSignIn 객체로 로그인 흐름을 시작
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 사용자가 로그인하지 않으면 null 반환
      if (googleUser == null) {
        return null; // 로그인 취소
      }

      // 인증 세부 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase에 사용할 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인 처리
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("구글 로그인 오류: $e");
      return null; // 오류 발생 시 null 반환
    }
  }

  // 구글 로그아웃 함수
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}




