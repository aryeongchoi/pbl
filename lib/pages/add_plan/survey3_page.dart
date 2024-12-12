import 'package:flutter/material.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'list_calendar.dart';

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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60), // 상단 여백
            const SizedBox(height: 50), // 네모와 질문 요소 사이 간격
            Expanded(
              // 컨테이너를 화면 중앙에 배치
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                      _showAddTravelPlanDialog(context);
                    },
                  ),
                ],
              ),
            ), // 제출 버튼과 컨테이너 사이 간격
          ],
        ),
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

  void _showAddTravelPlanDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 여행 계획'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '여행 계획 이름'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  startDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text(startDate == null
                    ? '시작 날짜 선택'
                    : '시작 날짜: ${startDate.toString().split(' ')[0]}'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  endDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text(endDate == null
                    ? '종료 날짜 선택'
                    : '종료 날짜: ${endDate.toString().split(' ')[0]}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (userId != null &&
                    nameController.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  final newCalendarRef = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('calendars')
                      .add({
                    'name': nameController.text,
                    'start_date': startDate,
                    'end_date': endDate,
                  });

                  // Firebase에 추가 완료 후 팝업 닫기 및 ListCalendar로 이동
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListCalendar(),
                    ),
                  );
                }
              },
              child: const Text('생성'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressStep(isActive: true), // 첫 번째 동그란 네모
        const SizedBox(width: 10),
        _buildProgressStep(isActive: true), // 두 번째 동그란 네모
      ],
    );
  }

  // 단일 네모 생성
  Widget _buildProgressStep({required bool isActive}) {
    return Container(
      width: 70,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
