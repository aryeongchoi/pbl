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
        colorScheme: const ColorScheme(
          primary: Color(0xFF40BCCB), // PANTONE 311C
          primaryContainer: Color(0xFFF3A7AC), // PANTONE 494C
          secondary: Color(0xFF0099CC), // PANTONE 2192C
          secondaryContainer: Color(0xFF0099CC), // PANTONE 311C
          surface: Color(0xFFFFFFFF), // PANTONE White C
          error: Colors.red, // 기본 오류 색상
          onPrimary: Colors.white,
          onSecondary: Color(0xFFEAEAEA),
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light, // 밝은 테마
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEAEAEA), // AppBar와 프로필 배경을 같은 색상으로
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF0099CC), // FAB 버튼 색상
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF0099CC),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainPage(),
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

  // "나의 여행" 페이지로 이동하기 위한 메서드
  void navigateToMyTravelPage() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(
            onNavigateToMyTravel: navigateToMyTravelPage, // HomePage에서 호출될 메서드
          ),
          MTPage(),
          TravelCalendarPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '나의 여행'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
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
      appBar: AppBar(
        title: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 8, // 동그라미 크기 설정
                backgroundColor: Theme.of(context).colorScheme.primary, // 동그라미 색상 설정
              ),
              SizedBox(width: 8),
              Text(
                '신난 고슴도치 님',
                style: TextStyle(fontSize: 18, color: Colors.black),
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
            margin: EdgeInsets.only(top: 80), // 상단 여백을 조정하여 잘리지 않게 함
            height: 1200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1), // 테두리 추가
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 3), // 동그라미와 겹침을 방지하는 여백
                  Text(
                    '신난 고슴도치 님, 반갑습니다!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildLegend(),
                  Center( // 캘린더를 센터로 위치
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: _buildCalendar(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '#신나는 #탁트인 #즐거운',
                    style: TextStyle(color: Color(0xFF3EBBCB), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
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
          _buildLegendItem(Color(0xFFF3A8AC), "이전 일정"),
          SizedBox(width: 16),
          _buildLegendItem(Color(0xFF3EBBCB), "추진 일정"),
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
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31) ,
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
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        todayTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        outsideDaysVisible: false,
        defaultTextStyle: TextStyle(fontSize: 23),
        weekendTextStyle: TextStyle(fontSize: 23, color: Colors.red),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (previousDates.contains(day)) {
            return _buildMarker(day, Color(0xFFF3A8AC));
          } else if (upcomingDates.contains(day)) {
            return _buildMarker(day, Color(0xFF3EBBCB));
          }
          return null;
        },
      ),
      headerStyle: HeaderStyle(
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