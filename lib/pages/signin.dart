import 'package:firebase_auth/firebase_auth.dart';
import 'package:truple_practice/pages/trip_list.dart';
import 'package:truple_practice/pages/signup.dart';
import 'package:truple_practice/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // 사용자 입력을 저장할 이메일과 비밀번호 변수
  String email = "", password = "";

  // 이메일과 비밀번호 입력을 관리할 컨트롤러
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  // 사용자 로그인 함수
  userlogin() async {
    try {
      // FirebaseAuth를 사용하여 이메일과 비밀번호로 로그인 시도
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // 로그인 성공 시 홈 페이지로 이동
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const TripList()));
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 오류를 처리
      if (e.code == 'user-not-found') {
        // 입력된 이메일에 해당하는 사용자가 없을 경우 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "해당 이메일로 등록된 사용자를 찾을 수 없습니다.",
              style: TextStyle(fontSize: 20.0),
            )));
      } else if (e.code == "wrong-password") {
        // 잘못된 비밀번호가 입력된 경우 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "사용자가 잘못된 비밀번호를 입력했습니다.",
              style: TextStyle(fontSize: 20.0),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            // 환영 화면 이미지 표시
            Image.asset("assets/images/welcome_screen.png"),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color(0xFF9dc3d5),
                  Color(0xFF9ac3d4),
                  Color.fromARGB(145, 27, 94, 118)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30.0,
                      ),
                      // 이메일 입력 필드
                      TextField(
                        controller: mailcontroller,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5), // 기본적으로 포커스되지 않았을 때의 색상
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // 비밀번호 입력 필드
                      TextField(
                        controller: passwordcontroller,
                        decoration: const InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.5), // 기본적으로 포커스되지 않았을 때의 색상
                          ),
                        ),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        obscureText: true,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, left: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Sign in",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                // 이메일과 비밀번호 입력이 비어있지 않을 경우 로그인 함수 호출
                                if (mailcontroller.text != "" &&
                                    passwordcontroller.text != "") {
                                  setState(() {
                                    email = mailcontroller.text;
                                    password = passwordcontroller.text;
                                  });
                                }
                                userlogin();
                              },
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(60),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF4C7296),
                                      borderRadius: BorderRadius.circular(60)),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // 구글 로그인 기능 호출
                              AuthMethods().signInWithGoogle(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.asset(
                                "assets/images/google.png",
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              // 애플 로그인 기능 호출 (현재 구현 없음)
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.asset(
                                "assets/images/apple.png",
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "계정이 없으신가요? ",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                              onTap: () {
                                // 회원가입 페이지로 이동
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignUp()));
                              },
                              child: const Text(
                                "회원가입",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
