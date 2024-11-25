import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
            top: 1, // 버튼을 완전히 위로 올림
            right: 80, // 오른쪽으로 이동
            child: _buildSpeechBubbleButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubbleButton() {
    return ClipPath(
      clipper: SpeechBubbleClipper(),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showCalendar = !_showCalendar;
            _selectedCountry = null; // 선택 초기화
            _contentAnimationController.reset();
          });
        },
        child: Container(
          width: 100, // 말풍선의 가로 길이를 줄임
          height: 50, // 말풍선의 높이
          color: _showCalendar
              ? Theme.of(context).colorScheme.primary // 캘린더일 때 파란색
              : Theme.of(context).colorScheme.primaryContainer, // 나라 정보일 때 분홍색
          child: Align(
            alignment: const Alignment(0.0, -0.7), // 텍스트를 약간 위로 이동
            child: Text(
              _showCalendar ? '캘린더' : '나라 정보',
              textAlign: TextAlign.center, // 텍스트 중앙 정렬
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
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
              const SizedBox(width: 0.05),
              _buildToggleContainer(),
            ],
          ),
        ),
        if (_selectedCountry != null)
          SlideTransition(
            position: _contentSlideAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 15), // 간격 추가
              child: _buildContentContainer(_selectedCountry!),
            ),
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
              ? Theme.of(context).colorScheme.primaryContainer // 선택된 경우 색상 변경
              : Theme.of(context).colorScheme.tertiary, // 기본 색상
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
          color: Theme.of(context).colorScheme.primaryContainer, // 색상 변경
        ),
        child: Align(
          alignment: const Alignment(0.0, -0.5), // 위로 올림
          child: Text(
            "⇄",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentContainer(String country) {
    String timeInfo = '';
    String weatherInfo = '';
    String currencyInfo = '';
    String imagePath = 'images/ko.png';

    final now = DateTime.now();
    switch (country) {
      case '한국':
        timeInfo = '현재 시간: ${now.toLocal()}';
        weatherInfo = '날씨: 맑음, 15°C';
        currencyInfo = '환율: 1,000 KRW = 0.75 USD';
        break;
      case '일본':
        final japanTime = now.add(const Duration(hours: 0)); // 시차 없음
        timeInfo = '현재 시간: ${japanTime.toLocal()}';
        weatherInfo = '날씨: 흐림, 18°C';
        currencyInfo = '환율: 100 JPY = 0.9 USD';
        break;
      case '중국':
        final chinaTime = now.add(const Duration(hours: -1)); // 시차 계산
        timeInfo = '현재 시간: ${chinaTime.toLocal()}';
        weatherInfo = '날씨: 비, 12°C';
        currencyInfo = '환율: 1 CNY = 0.14 USD';
        break;
      case '미국':
        final usTime = now.subtract(const Duration(hours: 14)); // 시차 계산
        timeInfo = '시차: 한국보다 14시간 느림 (${usTime.toLocal()})';
        weatherInfo = '날씨: 맑음, 22°C';
        currencyInfo = '환율: 1 USD = 1,330 KRW';
        break;
      case '아프리카':
        final africaTime = now.subtract(const Duration(hours: 7)); // 시차 계산
        timeInfo = '시차: 한국보다 7시간 느림 (${africaTime.toLocal()})';
        weatherInfo = '날씨: 덥고 건조, 35°C';
        currencyInfo = '환율: 1 ZAR = 72 KRW';
        break;
      case '프랑스':
        final franceTime = now.subtract(const Duration(hours: 8)); // 시차 계산
        timeInfo = '시차: 한국보다 8시간 느림 (${franceTime.toLocal()})';
        weatherInfo = '날씨: 흐림, 10°C';
        currencyInfo = '환율: 1 EUR = 1,450 KRW';
        break;
      default:
        timeInfo = '정보 없음';
        weatherInfo = '정보 없음';
        currencyInfo = '정보 없음';
        break;
    }

    return Container(
      width: 365,
      height: 250,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.tertiary,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            offset: const Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // 수평 정렬
          crossAxisAlignment: CrossAxisAlignment.center, // 수직 정렬
          children: [
            Transform.translate(
              offset: const Offset(0, -40), // CircleAvatar를 위로 10픽셀 이동
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: AssetImage(imagePath),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 텍스트를 세로로 중심 배치
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$country',
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(timeInfo, style: const TextStyle(fontSize: 18)),
                  Text(weatherInfo, style: const TextStyle(fontSize: 18)),
                  Text(currencyInfo, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
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
        defaultTextStyle: const TextStyle(fontSize: 20, color: Colors.black),
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

class SpeechBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double radius = 16.0; // 둥근 모서리 반경
    final double tailWidth = 20.0; // 꼬리 너비
    final double tailHeight = 10.0; // 꼬리 높이
    final double tailOffset = 8.0; // 꼬리를 위로 올리는 오프셋

    final Path path = Path();

    // 둥근 사각형 몸체
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - tailHeight - tailOffset),
        Radius.circular(radius),
      ),
    );

    // 말풍선 꼬리
    path.moveTo(radius, size.height - tailHeight - tailOffset); // 시작점
    path.lineTo(radius - tailWidth / 2, size.height - tailOffset); // 아래로 내려감
    path.lineTo(radius + tailWidth / 2, size.height - tailHeight - tailOffset); // 오른쪽 위로 올라감

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}