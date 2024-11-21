import 'package:flutter/material.dart';
import 'package:truple_practice/pages/home_page.dart';
import 'info_page.dart';
import 'mytrip_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _HomePageState();
}

class _HomePageState extends State<MainPage> {
  int _selectedIndex = 0;

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
        index: _selectedIndex,
        children: [
          HomePage(
            onNavigateToMyTravel: navigateToMyTravelPage,
          ),
          const MyTripPage(),
          const InfoPage(),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
