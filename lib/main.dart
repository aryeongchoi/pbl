import 'package:flutter/material.dart';
import 'home.dart';
import 'mt.dart';
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
      home: MainPage(), // MainPage를 초기 화면으로 설정
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? HomePage() // 홈 화면으로 이동
          : _selectedIndex == 1
          ? MyTravelPage() // 나의 여행 화면으로 이동
          : TravelCalendarPage(), // 정보 화면으로 이동
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '나의 여행'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF3EBBCB),
        onTap: _onItemTapped,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white, // 네모 박스 색상
            borderRadius: BorderRadius.circular(45),
          ),
          child: Text(
            '신난 고슴도치 님',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/hedgehog.jpg'), // 고슴도치 이미지 경로
          ),
          SizedBox(height: 16),
          Text(
            '신난 고슴도치 님, 반갑습니다!',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Container(
            width: MediaQuery.of(context).size.width * 0.8, // 캘린더 크기 줄이기
            child: _buildCalendar(),
          ),
          SizedBox(height: 16),
          Text(
            '#신나는 #탁트인 #즐거운',
            style: TextStyle(color: Color(0xFF3EBBCB), fontSize: 16),
          ),
        ],
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
        defaultTextStyle: TextStyle(fontSize: 16), // 캘린더 텍스트 크기 키우기
        weekendTextStyle: TextStyle(fontSize: 16, color: Colors.red), // 주말 텍스트 크기 및 색상
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