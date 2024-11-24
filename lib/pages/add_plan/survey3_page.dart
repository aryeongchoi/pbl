import 'package:flutter/material.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truple_practice/pages/add_plan/survey2_page.dart'; // 이전 페이지 import

class Survey3Page extends StatefulWidget {
  const Survey3Page({super.key});

  @override
  State<Survey3Page> createState() => _Survey3PageState();
}

class _Survey3PageState extends State<Survey3Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "추천 여행지!"),
      body: Column(
        children: [
          const SizedBox(height: 60), // 상단 여백
          Expanded(
            // 컨테이너를 화면 중앙에 배치
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStyledContainer(
                  context: context,
                  title: "캐나다 퀘벡",
                  onTap: () {
                    print("캐나다 퀘벡 클릭됨!");
                  },
                ),
                const SizedBox(height: 20),
                _buildStyledContainer(
                  context: context,
                  title: "일본 오사카",
                  onTap: () {
                    print("일본 오사카 클릭됨!");
                  },
                ),
                const SizedBox(height: 20),
                _buildStyledContainer(
                  context: context,
                  title: "나만의 여행 계획 짜기",
                  onTap: () {
                    print("나만의 여행 계획 클릭됨!");
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // 제출 버튼과 컨테이너 사이 간격
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Survey2Page(), // 이전 페이지로 이동
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  "<",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40), // 하단 여백
        ],
      ),
    );
  }

  Widget _buildStyledContainer({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // 클릭 이벤트 연결
      child: Container(
        width: 350, // 컨테이너 너비 유지
        height: 150, // 컨테이너 높이 유지
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // 둥근 모서리
          color: Theme.of(context).colorScheme.tertiary, // 테마 색상
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow, // 그림자 색상
              offset: const Offset(0, 0),
              blurRadius: 10,
              spreadRadius: 0.5,
              blurStyle: BlurStyle.normal,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void AddCalendar(BuildContext context, String? userId, String? name,
      String? startdDate, String? endDate) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('calendars')
        .add({
      'name': name,
      'start_date': startdDate,
      'end_date': endDate,
    });
  }
}
