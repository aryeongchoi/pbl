import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truple_practice/pages/main_page.dart';
import 'package:truple_practice/pages/user_auth/signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  registration() async {
    if (password != "" && email != "" && name != "") {
      try {
        //UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "회원가입 성공",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } on FirebaseAuthException catch (e) {
        String message =
            e.code == 'weak-password' ? "비밀번호가 너무 약합니다." : "이미 존재하는 계정입니다.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(message, style: const TextStyle(fontSize: 16.0)),
          ),
        );
      }
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
                    const Text(
                      '이메일로 회원가입',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 16),
                    // 이름 입력 필드
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "이름", // 필드 위에 표시될 라벨
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600),
                        hintText: "홍길동", // 이메일 예시
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
                    // 이메일 입력 필드
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
                        hintText: "영어, 숫자를 포함하세요", // 비밀번호 조건
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 로그인 페이지 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "이미 계정이 있으신가요?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const SignIn()),
                      );
                    },
                    child: const Text(
                      " 로그인",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF40BCCB),
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
          heroTag: "signupButton", // 고유 heroTag 지정
          onPressed: () {
            setState(() {
              email = mailController.text;
              name = nameController.text;
              password = passwordController.text;
            });
            Navigator.pop(context);
          },
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer, // 버튼 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
          ),
          child: const Text("회원가입"),
        ),
      ),
    );
  }
}
