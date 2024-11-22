import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truple_practice/pages/main_page.dart';
import 'package:truple_practice/pages/user_auth/signup.dart';
import 'package:truple_practice/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String email = "", password = "";
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'user-not-found'
          ? "해당 이메일로 등록된 사용자를 찾을 수 없습니다."
          : "잘못된 비밀번호입니다.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(message, style: const TextStyle(fontSize: 16.0)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 흰색 카드 형태
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          '이메일로 로그인',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: mailController,
                      decoration: InputDecoration(
                        labelText: "이메일 주소", // 필드 위에 표시될 라벨
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600),
                        hintText: "example@domain.com", // 이메일 예시
                        hintStyle:
                            const TextStyle(color: Colors.grey), // 힌트 스타일
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey), // 기본 밑줄 색상
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // 포커스 시 밑줄 색상
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black), // 입력 글씨 스타일
                    ),
                    const SizedBox(height: 16),
// 비밀번호 입력 필드
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "비밀번호", // 필드 위에 표시될 라벨
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600),
                        hintText: "8자 이상 입력하세요", // 비밀번호 조건
                        hintStyle:
                            const TextStyle(color: Colors.grey), // 힌트 스타일
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey), // 기본 밑줄 색상
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // 포커스 시 밑줄 색상
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black), // 입력 글씨 스타일
                    ),
                    const SizedBox(height: 20),
                    // 소셜 로그인 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          imagePath: "assets/images/google.png",
                          onTap: () {
                            AuthMethods().signInWithGoogle(context);
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          imagePath: "assets/images/apple.png",
                          onTap: () {
                            // 애플 로그인 구현
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "계정이 없으신가요?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const SignUp()),
                      );
                    },
                    child: const Text(
                      " 회원가입",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF3A7AC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.91,
        height: 80,
        child: FloatingActionButton(
          heroTag: "loginButton", // 고유 heroTag 지정
          onPressed: () {
            setState(() {
              email = mailController.text;
              password = passwordController.text;
            });
            userLogin();
          },
          backgroundColor: Theme.of(context).colorScheme.primary, // 버튼 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
          ),
          child: const Text("로그인"),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}
