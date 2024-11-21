import 'package:flutter/material.dart';
import 'package:smp_final_project/screen/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smp_final_project/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      home: StartScreen(),
      debugShowCheckedModeBanner: false,
    )
  );
}