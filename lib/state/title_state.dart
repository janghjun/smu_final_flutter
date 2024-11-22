import 'package:flutter/material.dart';

class TitleState with ChangeNotifier {
  List<String> _titles = []; // 제목들을 저장할 리스트

  // 제목 목록에 제목을 추가하는 메서드
  void addTitle(String title) {
    _titles.add(title);
    notifyListeners(); // 상태가 변경되었음을 알림
  }

  // 제목 목록을 가져오는 메서드
  List<String> get titles => _titles;
}
