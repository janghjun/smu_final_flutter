import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false; // 기본값은 라이트 모드
  bool get isDarkMode => _isDarkMode;
  // 다크모드 토글
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // 상태가 변경되었음을 UI에 알림
  }
}