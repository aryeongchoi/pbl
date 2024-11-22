import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'package:truple_practice/pages/add_plan/list_calendar.dart';

// first.dart 파일 import

class SecondSurveyPage extends StatefulWidget {
  const SecondSurveyPage({super.key});

  @override
  State<SecondSurveyPage> createState() => _Survey1PageState();
}

class _Survey1PageState extends State<SecondSurveyPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  String selectedBudget = '100만원';
  String selectedPeople = '3명';
  String selectedPurpose = '친목';

  final List<String> budgetOptions = [
    '50만원 이하',
    '100만원',
    '200만원',
    '300만원',
    '400만원',
    '500만원 이상'
  ];
  final List<String> peopleOptions = ['1명', '2명', '3명', '4명', '5명 이상'];
  final List<String> purposeOptions = [
    '데이트',
    '친목',
    '가족모임',
    '비지니스',
    '여행',
    '나들이'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "상세설문"),
      body: Column(
        children: [
          const SizedBox(height: 100), // 상단 네모를 더 위로 올리기 위한 여백
          _buildProgressIndicator(), // 상단 네모 두 개
          const SizedBox(height: 40), // 네모와 질문 요소 사이 간격
          Expanded(
            // 질문 요소를 화면 중앙에 배치
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 질문 요소 왼쪽 정렬
                mainAxisAlignment:
                    MainAxisAlignment.center, // 질문 요소를 화면 세로 중앙에 정렬
                children: [
                  _buildQuestion(
                    '1. 여행 비용',
                    budgetOptions,
                    selectedBudget,
                    (value) => setState(() => selectedBudget = value),
                  ),
                  const SizedBox(height: 24),
                  _buildQuestion(
                    '2. 여행 인원',
                    peopleOptions,
                    selectedPeople,
                    (value) => setState(() => selectedPeople = value),
                  ),
                  const SizedBox(height: 24),
                  _buildQuestion(
                    '3. 여행 목적',
                    purposeOptions,
                    selectedPurpose,
                    (value) => setState(() => selectedPurpose = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // 제출 버튼과 질문 요소 사이 간격
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListCalendar(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                '제출',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), // 제출 버튼과 하단 여백
        ],
      ),
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
      width: 73, // 가로로 길게 설정
      height: 15, // 세로로 더 짧게 설정
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey, // 활성화 여부에 따라 색상 변경
        borderRadius: BorderRadius.circular(12), // 더 동그랗게 설정
      ),
    );
  }

  Widget _buildQuestion(
    String title,
    List<String> options,
    String selectedOption,
    Function(String) onSelected,
  ) {
    return Container(
      color: Colors.blue, // 배경색 빨간색 설정
      padding: const EdgeInsets.all(8.0), // 내부 여백 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 질문과 선택지가 왼쪽 정렬
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white), // 글자색 흰색으로 변경
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 가로 스크롤 가능
            child: Row(
              children: options.map((option) {
                final isSelected = selectedOption == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0), // 옵션 간 간격
                  child: ChoiceChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (_) => onSelected(option),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      // 둥글게 설정
                      borderRadius: BorderRadius.circular(20), // 테두리 둥글기
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCalendarDialog(BuildContext context, String? userId) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 일정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '일정 이름'),
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
            TextButton(
              child: const Text('추가'),
              onPressed: () async {
                if (userId != null &&
                    nameController.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('calendars')
                      .add({
                    'name': nameController.text,
                    'start_date': startDate,
                    'end_date': endDate,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
