import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'package:truple_practice/pages/add_plan/survey1_page.dart'; // 이전 페이지 import
import 'package:truple_practice/pages/add_plan/survey3_page.dart'; // Survey3Page import

class Survey2Page extends StatefulWidget {
  const Survey2Page({super.key});

  @override
  State<Survey2Page> createState() => _Survey2PageState();
}

class _Survey2PageState extends State<Survey2Page> {
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
      appBar: const CustomAppBar(title: "상세 설문"),
      body: Column(
        children: [
          const SizedBox(height: 60), // 상단 여백
          _buildProgressIndicator(), // 상단 네모 두 개
          const SizedBox(height: 50), // 네모와 질문 요소 사이 간격
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildQuestion(
                    '1. 여행 비용',
                    budgetOptions,
                    selectedBudget,
                        (value) => setState(() => selectedBudget = value),
                  ),
                  const SizedBox(height: 80), // 질문 요소 간 간격
                  _buildQuestion(
                    '2. 여행 인원',
                    peopleOptions,
                    selectedPeople,
                        (value) => setState(() => selectedPeople = value),
                  ),
                  const SizedBox(height: 80), // 질문 요소 간 간격
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
          const SizedBox(height: 20), // 버튼과 질문 요소 사이 간격
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Survey1Page(), // 이전 페이지로 이동
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
              const SizedBox(width: 16), // 좌우 버튼 간 간격
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const Survey3Page(), // Survey3Page로 이동
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  ">",
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

  Widget _buildQuestion(
      String title,
      List<String> options,
      String selectedOption,
      Function(String) onSelected,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 질문 제목
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15), // 제목과 옵션 사이 간격
        // 옵션 버튼들
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = selectedOption == option;
              return GestureDetector(
                onTap: () => onSelected(option), // 선택 이벤트 연결
                child: Container(
                  margin: const EdgeInsets.only(right: 10), // 옵션 간 간격
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ), // 버튼 내부 여백
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), // 둥근 모서리
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white, // 선택된 경우 강조 색상
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02), // 그림자 추가
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}