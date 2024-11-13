import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '여행 캘린더 앱',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Pretendard-Medium', // Pretendard-Medium 폰트 설정
      ),
      home: TravelCalendarPage(), // 초기 화면 설정
    );
  }
}

class TravelCalendarPage extends StatefulWidget {
  @override
  _TravelCalendarPageState createState() => _TravelCalendarPageState();
}

class _TravelCalendarPageState extends State<TravelCalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  //222

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신난 고슴도치 님'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            '신난 고슴도치 님, 반갑습니다!',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/hedgehog.jpg'), // 고슴도치 이미지 경로
          ),
          SizedBox(height: 16),
          _buildCalendar(),
          SizedBox(height: 16),
          Text(
            '#신나는 #탁트인 #즐거운',
            style: TextStyle(color: Color(0xFF3EBBCB), fontSize: 16),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '나의 여행'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),
        ],
        selectedItemColor: Color(0xFF3EBBCB),
      ),
    );
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
        _navigateToPlan(selectedDay);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Color(0xFF3EBBCB), // 추진 일정 색상
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFFF3A8AC), // 이전 일정 색상
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  void _navigateToPlan(DateTime selectedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TravelPlanPage(date: selectedDay)),
    );
  }
}

class TravelPlanPage extends StatelessWidget {
  final DateTime date;

  TravelPlanPage({required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 계획'),
      ),
      body: Center(
        child: Text(
          '여행 계획 페이지: ${date.toLocal()}',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}