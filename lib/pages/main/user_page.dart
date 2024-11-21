import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: Colors.blue, size: 10),
            SizedBox(width: 8),
            Text('10월 18일 금', style: TextStyle(color: Colors.black)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {}, // 날짜 이전 버튼 기능 추가 예정
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () {}, // 날짜 다음 버튼 기능 추가 예정
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("일정 짜기", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Container(
              width: 350,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text("여행 일정 표시 영역")),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(label: Text('이전 일정')),
                SizedBox(width: 10),
                Chip(label: Text('추천 일정')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
