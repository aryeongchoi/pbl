import 'package:flutter/material.dart';
import 'package:truple_practice/pages/add_plan/survey2_page.dart';
import 'package:truple_practice/widgets/appbar.dart';

class Survey1Page extends StatefulWidget {
  const Survey1Page({super.key});

  @override
  State<Survey1Page> createState() => _FirstSurveyPageState();
}

class _FirstSurveyPageState extends State<Survey1Page> {
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
          _buildStyledContainer(context), // 개선된 캘린더 대체용 컨테이너
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
                          const Survey2Page(), // SecondSurveyPage는 위젯이어야 함
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

  Widget _buildStyledContainer(BuildContext context) {
    return Container(
      height: 300, // 캘린더 공간의 높이
      margin: const EdgeInsets.symmetric(horizontal: 20.0), // 양옆 간격 증가
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: const Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 1,
            blurStyle: BlurStyle.normal,
          ),
        ],
        color: Colors.grey[300], // 캘린더 대체용 사각형 색상
      ),
      child: const Center(
        child: Text(
          "캘린더 공간",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
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
