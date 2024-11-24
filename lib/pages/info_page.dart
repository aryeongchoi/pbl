import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with TickerProviderStateMixin {
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

  bool _showCalendar = true; // 캘린더와 다른 콘텐츠 전환을 위한 플래그
  String? _selectedCountry; // 선택된 나라를 저장
  bool _isSecondRegion = false; // 지역 리스트 상태를 관리
  late AnimationController _contentAnimationController;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 초기화
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 아래에서 시작
      end: Offset.zero, // 원래 위치
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 80),
            height: 1200,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  offset: const Offset(0, 0),
                  blurRadius: 6,
                  spreadRadius: 2,
                  blurStyle: BlurStyle.normal,
                ),
              ],
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80), // 문구와 캘린더 사이 간격 추가
                const Text(
                  '신난 고슴도치 님, 반갑습니다!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40), // 이전 일정/추진 일정과 문구 간 간격
                if (_showCalendar) _buildLegend(),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showCalendar
                        ? _buildCalendarContainer()
                        : _buildCountrySelection(),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 42, // 동그라미 위치 고정
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/hedgehog.jpg'),
            ),
          ),
          Positioned(
            top: 20, // 버튼을 완전히 위로 올림
            right: 20,
            child: _buildFixedButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _showCalendar = !_showCalendar; // 캘린더와 다른 콘텐츠 전환
          _selectedCountry = null; // 버튼 클릭 시 선택 초기화
          _contentAnimationController.reset();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 12,
        ),
      ),
      child: Text(
        _showCalendar ? '다른 콘텐츠 보기' : '캘린더로 돌아가기',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildCalendarContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // 캘린더 위치 조정
      height: 500, // 캘린더의 고정 높이
      child: _buildCalendar(),
    );
  }

  Widget _buildCountrySelection() {
    final regions = _isSecondRegion
        ? ["미국", "아프리카", "프랑스"]
        : ["한국", "일본", "중국"];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...regions.map((region) => _buildStyledContainer(region)).toList(),
              const SizedBox(width: 10),
              _buildToggleContainer(),
            ],
          ),
        ),
        if (_selectedCountry != null)
          SlideTransition(
            position: _contentSlideAnimation,
            child: _buildContentContainer(_selectedCountry!),
          ),
      ],
    );
  }

  Widget _buildStyledContainer(String country) {
    bool isSelected = _selectedCountry == country; // 선택 여부 확인
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCountry = country; // 선택된 나라 저장
          _contentAnimationController.forward(from: 0.0); // 애니메이션 시작
        });
      },
      child: Container(
        width: 110,
        height: 30,
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // 둥근 모서리
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
              : Theme.of(context).colorScheme.tertiary, // 선택된 경우 색상 변경
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow, // 그림자 색상
              offset: const Offset(0, 0),
              blurRadius: 10,
              spreadRadius: 0.5,
              blurStyle: BlurStyle.normal,
            ),
          ],
        ),
        child: Center(
          child: Text(
            country,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleContainer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSecondRegion = !_isSecondRegion; // 지역 리스트를 변경
        });
      },
      child: Container(
        width: 40,
        height: 30,
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: const Center(
          child: Text(
            ">",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentContainer(String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // 위치 조정
      height: 300, // 고정된 높이
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "$content 선택됨",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
              Theme.of(context).colorScheme.primaryContainer, "이전 일정"),
          const SizedBox(width: 16),
          _buildLegendItem(Theme.of(context).colorScheme.primary, "추진 일정"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
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
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        weekendTextStyle: const TextStyle(fontSize: 20, color: Colors.red),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  void _navigateToPlan(DateTime selectedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelPlanPage(date: selectedDay),
      ),
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