import 'package:flutter/material.dart';
import 'package:truple_practice/pages/add_plan/survey2_page.dart';
import 'package:truple_practice/widgets/appbar.dart';

class FirstSurveyPage extends StatefulWidget {
  const FirstSurveyPage({super.key});

  @override
  State<FirstSurveyPage> createState() => _FirstSurveyPageState();
}

class _FirstSurveyPageState extends State<FirstSurveyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '설문'),
      body: Column(
        children: [
          const SizedBox(height: 60), // 상단 여백
          _buildProgressIndicator(), // 상단 진행 표시 네모
          const SizedBox(height: 30), // 네모와 제목 사이 간격
          const Text(
            "여행 기간을 체크해 주세요",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30), // 제목과 캘린더 네모 간 간격
          Container(
            height: 300, // 캘린더 공간의 높이
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[300], // 캘린더 대체용 사각형 색상
              borderRadius: BorderRadius.circular(10), // 모서리를 둥글게
            ),
            child: const Center(
              child: Text(
                "캘린더 공간",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          ),
          const Spacer(), // 버튼을 아래로 밀기
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 이전 페이지로 돌아가기
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
              const SizedBox(width: 16), // 좌우 버튼 사이 간격
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const SecondSurveyPage(), // SecondSurveyPage는 위젯이어야 함
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

  // 상단 진행 표시 네모
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 50,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
