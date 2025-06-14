# 🏃‍♀️ SMU 운동 기록 앱 (Flutter 기반)

상명대학교 Flutter 프로젝트로 개발된 **운동 기록 및 일정 관리 앱**입니다.  
Flutter 기반으로 제작되었으며, **카카오/구글 소셜 로그인**, **운동 기록 기능**, **캘린더 연동**, **푸시 알림 설정**, **프로필 관리** 기능을 제공합니다.

---

<img src="./asset/img/directions_run.png" width="300" alt="앱 시작 화면" />

---

## 🎬 실행 영상

![Image](https://github.com/user-attachments/assets/6eba8803-c65f-4f62-ad1f-7aeaa7089679)

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 🔐 소셜 로그인 | 카카오, 구글 계정을 통한 간편 로그인 |
| 🏃 운동 시작 기능 | Start 버튼을 눌러 운동 기록 화면으로 이동 |
| 📅 캘린더 기능 | 날짜별 운동 기록 관리 및 일정 조회 |
| ✏️ 글 작성 | 메모 및 운동 기록 입력 기능 |
| 🔔 푸시 알림 | 알림 설정 화면을 통한 맞춤 알림 제어 |
| 👤 프로필 관리 | 사용자 정보 확인 및 설정 변경 기능 |

---

## 🛠 기술 스택

- **Flutter** 3.x
- **Dart**
- **Firebase Auth** (Google/Kakao 연동)
- **Kakao SDK**
- **State Management**: Provider
- **UI**: Material Design

---

## 📁 프로젝트 구조

```
lib/
├── main.dart                      
├── firebase/
│   ├── firebase_auth_remote_data_source.dart
│   ├── firebase_options.dart
│   ├── google_login.dart
│   ├── kakao_login.dart
│   └── ...
├── screen/
│   ├── calendar_screen.dart
│   ├── push_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── write_screen.dart
│   └── ...
├── state/
│   ├── app_state.dart
│   └── ...
├── provider/
├── theme_provider.dart
│   └── ...

```

---

## 📝 라이선스

본 프로젝트는 MIT License 하에 배포됩니다.

---
