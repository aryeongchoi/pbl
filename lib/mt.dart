import 'package:flutter/material.dart';

class MyTravelPage extends StatelessWidget {
  const MyTravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 여행'),
      ),
      body: const Center(
        child: Text(
          '나의 여행 화면입니다!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}