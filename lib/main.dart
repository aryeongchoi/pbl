import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:truple_practice/pages/user_auth/signin.dart';

//google api key = AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행 캘린더 앱',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFF40BCCB), // PANTONE 311C
          primaryContainer: Color(0xFFF3A7AC), // PANTONE 494C
          secondary: Color(0xFF0099CC), // PANTONE 2192C
          secondaryContainer: Color(0xFF0099CC), // PANTONE 311C
          surface: Color(0xFFFFFFFF), // PANTONE White C
          error: Colors.red, // 기본 오류 색상
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light, // 밝은 테마
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF40BCCB), // AppBar와 프로필 배경을 같은 색상으로
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0099CC), // FAB 버튼 색상
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF0099CC),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SignIn(),
    );
  }
}
