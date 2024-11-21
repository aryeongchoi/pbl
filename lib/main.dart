import 'package:firebase_core/firebase_core.dart';
import 'package:truple_practice/pages/user_auth/signup.dart';
import 'package:flutter/material.dart';

//google api key = AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 이 위젯은 애플리케이션의 루트입니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trupple',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Pretendard-Medium',
        secondaryHeaderColor: Colors.amber,
        canvasColor: const Color.fromARGB(255, 255, 255, 255),
        focusColor: const Color.fromARGB(255, 255, 254, 234),
        highlightColor: const Color.fromARGB(255, 243, 167, 172),
        primaryColor: const Color.fromARGB(255, 64, 188, 203),
        primaryColorLight: const Color.fromARGB(255, 0, 153, 217),
        primaryColorDark: const Color.fromARGB(255, 0, 0, 0),
      ),
      debugShowCheckedModeBanner: false,
      home: const SignUp(),
    );
  }
}
