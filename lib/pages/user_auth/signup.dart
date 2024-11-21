import 'package:firebase_auth/firebase_auth.dart';
import 'package:truple_practice/home_page.dart';
import 'package:truple_practice/pages/user_auth/signin.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // 사용자 입력을 저장할 이메일, 비밀번호, 이름 변수
  String email = "", password = "", name = "";

  // 이름, 이메일, 비밀번호 입력을 관리할 컨트롤러
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  // 회원가입 함수
  registration() async {
    // 이메일과 비밀번호가 비어있지 않은지 확인
    if (password != "" && email != "" && password != "") {
      try {
        // FirebaseAuth를 사용하여 이메일과 비밀번호로 사용자 생성
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        if (!mounted) return;
        // 사용자 생성 성공 시 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            )));
        // 홈 페이지로 이동
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } on FirebaseAuthException catch (e) {
        // Firebase 인증 오류를 처리
        if (e.code == 'weak-password') {
          // 비밀번호가 약할 경우 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too weak",
                style: TextStyle(fontSize: 20.0),
              )));
        } else if (e.code == "email-already-in-use") {
          // 이미 존재하는 이메일일 경우 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 20.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            // 계정 이미지 표시
            Image.asset("assets/images/account.png"),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xFF498aa2),
                Color(0xFF377b94),
                Color(0xFF81b7cf),
                Color(0xFF81b7cf),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30.0,
                  ),
                  // 이름 입력 필드
                  TextField(
                    controller: namecontroller,
                    decoration: const InputDecoration(
                      hintText: "Name",
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
                    obscureText: true,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Sign up",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 모든 입력 필드가 비어있지 않은지 확인 후 등록 함수 호출
                            if (namecontroller.text != "" &&
                                mailcontroller.text != "" &&
                                passwordcontroller.text != "") {
                              setState(() {
                                email = mailcontroller.text;
                                name = namecontroller.text;
                                password = passwordcontroller.text;
                              });
                            }
                            registration();
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
                    height: 50.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "이미 계정이 있으신가요? ",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                          onTap: () {
                            // 로그인 페이지로 이동
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignIn()));
                          },
                          child: const Text(
                            "로그인",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  )
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
