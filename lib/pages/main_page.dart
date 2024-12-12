import 'package:flutter/material.dart';
import 'package:truple_practice/pages/add_plan/survey1_page.dart';
import 'package:truple_practice/pages/home_page.dart';
import 'package:truple_practice/pages/user_page.dart';
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

  final List<dynamic> _appBarTitles = [
    const Icon(Icons.home, size: 24), // "홈" 페이지 아이콘
    const Icon(Icons.bookmark, size: 24), // "나의 여행" 아이콘
    const Icon(Icons.info, size: 24), // "정보" 아이콘
    const Icon(Icons.face_6_rounded, size: 24), // "유저" 아이콘
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(onNavigateToMyTravel: () {}),
    const MyTripPage(),
    const InfoPage(),
    const UserPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _appBarTitles[_selectedIndex], // 네비게이션 바의 아이콘을 제목으로 설정
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
                      icon: Icon(Icons.home),
                      label: '홈',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bookmark),
                      label: '나의 여행',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.info),
                      label: '정보',
                    ),
                    BottomNavigationBarItem(
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
