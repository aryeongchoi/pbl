import 'package:flutter/material.dart';
import 'package:truple_practice/pages/add_plan/survey2_page.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class Survey1Page extends StatefulWidget {
  const Survey1Page({super.key});

  @override
  State<Survey1Page> createState() => _FirstSurveyPageState();
}

class _FirstSurveyPageState extends State<Survey1Page> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '설문'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          children: [
            const SizedBox(height: 60), // 상단 여백
            _buildProgressIndicator(), // 상단 진행 표시 네모
            const SizedBox(height: 30), // 네모와 제목 사이 간격
            const Text(
              "여행 기간을 체크해 주세요",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30), // 제목과 캘린더 네모 간 간격
            _buildCalendar(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.91,
        height: 80,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(0, 0),
              spreadRadius: 4,
              blurRadius: 4,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const Survey2Page(), // SecondSurveyPage는 위젯이어야 함
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary, // 버튼 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
          ),
          child: const Icon(Icons.add),
        ),
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
          width: 70,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 70,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
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

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
        weekendTextStyle: const TextStyle(fontSize: 20, color: Colors.red),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }
}
