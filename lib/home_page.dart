import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:truple_practice/pages/user_auth/signin.dart';
import 'main_page.dart';
import 'user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // "나의 여행" 페이지로 이동하기 위한 메서드
  void navigateToMyTravelPage() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: 0,
        children: [
          MainPage(
            onNavigateToMyTravel: navigateToMyTravelPage, // HomePage에서 호출될 메서드
          ),
          const UserPage(),
          const TravelCalendarPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8.0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '나의 여행'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColorDark,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TravelCalendarPage extends StatefulWidget {
  const TravelCalendarPage({super.key});

  @override
  _TravelCalendarPageState createState() => _TravelCalendarPageState();
}

class _TravelCalendarPageState extends State<TravelCalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<DateTime> previousDates = [
    DateTime(2024, 11, 16),
    DateTime(2024, 11, 17),
  ];

  List<DateTime> upcomingDates = [
    DateTime(2024, 11, 25),
    DateTime(2024, 11, 26),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 20,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(45),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 8, // 동그라미 크기 설정
                backgroundColor: Colors.teal, // 동그라미 색상 설정
              ),
              const SizedBox(width: 10),
              Text(
                '신난 고슴도치 님',
                style: TextStyle(
                    fontSize: 18, color: Theme.of(context).primaryColorDark),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 80), // 상단 여백을 조정하여 잘리지 않게 함
            height: 1200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 10,
                  blurRadius: 30,
                  offset: const Offset(0, -3), // changes position of shadow
                ),
              ],
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Theme.of(context).focusColor, width: 1), // 테두리 추가
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 3), // 동그라미와 겹침을 방지하는 여백
                  const Text(
                    '신난 고슴도치 님, 반갑습니다!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildLegend(),
                  Center(
                    // 캘린더를 센터로 위치
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: _buildCalendar(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '#신나는 #탁트인 #즐거운',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 42, // 동그라미가 중앙에 위치하도록 조정
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/hedgehog.jpg'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Theme.of(context).highlightColor, "이전 일정"),
          const SizedBox(width: 16),
          _buildLegendItem(Theme.of(context).primaryColor, "추진 일정"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20, // 동그라미 크기 설정
          height: 20, // 동그라미 크기 설정
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
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
          color: Theme.of(context).primaryColorDark,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(fontSize: 20),
        weekendTextStyle: const TextStyle(fontSize: 20, color: Colors.red),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (previousDates.contains(day)) {
            return _buildMarker(day, Theme.of(context).highlightColor);
          } else if (upcomingDates.contains(day)) {
            return _buildMarker(day, Theme.of(context).primaryColorDark);
          }
          return null;
        },
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildMarker(DateTime day, Color color) {
    return Center(
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _navigateToPlan(DateTime selectedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TravelPlanPage(date: selectedDay)),
    );
  }
}

class TravelPlanPage extends StatelessWidget {
  final DateTime date;

  const TravelPlanPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 계획'),
      ),
      body: Center(
        child: Text(
          '여행 계획 페이지: ${date.toLocal()}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
