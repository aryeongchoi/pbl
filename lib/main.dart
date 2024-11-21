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
          onPrimary: Color(0xFF167783),

          secondary: Color(0xFF0099CC), // PANTONE 2192C
          onSecondary: Color(0xFF006590),

          secondaryContainer: Color(0xFFEAEAEA),
          tertiaryContainer: Color(0xFFA7A6A6),

          primaryContainer: Color(0xFFF3A7AC), // PANTONE 494C
          onPrimaryContainer: Color(0xFFAC7B7D),

          tertiary: Colors.white,
          onTertiary: Color(0xFFABAA92),

          surface: Color.fromARGB(255, 242, 242, 242), // PANTONE White C
          onSurface: Color.fromARGB(255, 31, 31, 31), //글자랑 아이콘 색

          error: Colors.red, // 기본 오류 색상
          onError: Colors.white,

          outline: Color(0xFF000000),
          shadow: Color.fromARGB(23, 0, 0, 0),

          brightness: Brightness.light, // 밝은 테마
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF40BCCB), // AppBar와 프로필 배경을 같은 색상으로
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF40BCCB), // FAB 버튼 색상
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF40BCCB),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SignIn(),
    );
  }
}
