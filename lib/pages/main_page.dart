import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truple_practice/pages/add_plan/survey1_page.dart';
import 'package:truple_practice/pages/home_page.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'info_page.dart';
import 'mytrip_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _HomePageState();
}

class _HomePageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<String> _appBarTitles = [
    '홈',
    '나의 여행',
    '정보',
    '에러'
  ]; // 페이지에 따른 AppBar 제목

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // "나의 여행" 페이지로 이동하기 위한 메서드
  void navigateToMyTravelPage() {
    setState(() {
      _selectedIndex = 1; // "나의 여행" 페이지 인덱스
    });
  }

  final List<Widget> _pages = [
    HomePage(onNavigateToMyTravel: () {}),
    const MyTripPage(),
    const InfoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _appBarTitles[_selectedIndex], // 동적으로 제목 설정
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Floating Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.all(16), // 화면 가장자리 여백
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white, // 약간 투명한 배경
                borderRadius: BorderRadius.circular(30), // 둥근 모서리
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3), // 그림자 위치
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  elevation: 4,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor:
                      Theme.of(context).colorScheme.primary, // 선택된 아이템 색상
                  unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items: const [
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(Icons.home),
                      label: '홈',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(Icons.bookmark),
                      label: '나의 여행',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(Icons.info),
                      label: '정보',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(Icons.face_6_rounded),
                      label: '유저',
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 60),
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
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const Survey1Page(), // SecondSurveyPage는 위젯이어야 함
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
}
