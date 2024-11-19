import 'package:flutter/material.dart';

class MyTravelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나의 여행'),
      ),
      body: Center(
        child: Text(
          '나의 여행 화면입니다!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}