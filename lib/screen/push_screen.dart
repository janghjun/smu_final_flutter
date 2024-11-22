import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushScreen extends StatefulWidget {
  const PushScreen({Key? key}) : super(key: key);

  @override
  _PushScreenState createState() => _PushScreenState();
}

class _PushScreenState extends State<PushScreen> {
  bool _isPushEnabled = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _loadPushNotificationSetting();

    // 로컬 알림 초기화
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  // 알림 초기화 함수
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // 앱 아이콘 지정

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 푸시 알림 설정을 로드하는 함수
  Future<void> _loadPushNotificationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPushEnabled = prefs.getBool('pushEnabled') ?? false;
    });
  }

  // 푸시 알림 설정을 저장하는 함수
  Future<void> _savePushNotificationSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('pushEnabled', value);
  }

  // 푸시 알림 상태 변경 시 로컬 알림 보내기
  Future<void> _sendLocalNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '푸시 알림 설정',
      message,
      platformDetails,
      payload: 'payload',
    );
  }

  // 푸시 알림 상태 변경 시 모달로 알려주기
  void _showModal(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '알림',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message),
      ),
    );

    // 2초 후 자동으로 모달 닫기
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  // 푸시 알림 스위치 상태 변경 시 호출되는 함수
  void _onPushNotificationChanged(bool value) {
    setState(() {
      _isPushEnabled = value;
    });
    _savePushNotificationSetting(value);

    // 상태에 맞는 알림 전송
    if(value) {
      _sendLocalNotification('알림을 켰습니다');
      _showModal('알림을 켰습니다');
    } else {
      _sendLocalNotification('알림을 껐습니다');
      _showModal('알림을 껐습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('푸시 알림 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                '푸시 알림 켜기',
                style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                ),
              ),
              value: _isPushEnabled,
              onChanged: _onPushNotificationChanged,
            ),
          ],
        ),
      ),
    );
  }
}
