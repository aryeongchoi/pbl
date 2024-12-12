import 'package:flutter/material.dart';
import 'package:truple_practice/pages/user_auth/signin.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String? _selectedFlight; // 선택된 비행 정보

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로그인 창으로 돌아가기 버튼 (제일 위)
            _buildReturnButton(context),
            const SizedBox(height: 30), // 버튼 아래 간격
            const Text(
              '비행권 검색',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30), // 검색창과 타이틀 사이 간격
            _buildFlightSearchBox(),
            const SizedBox(height: 20), // 검색창과 결과 리스트 사이 간격
            Expanded(
              child: _buildFlightResults(), // 결과 리스트
            ),
          ],
        ),
      ),
    );
  }

  // 비행권 검색 입력창
  Widget _buildFlightSearchBox() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '출발지 입력',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '목적지 입력',
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: _searchFlights,
          icon: const Icon(Icons.search),
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  // 비행권 결과를 보여주는 위젯
  Widget _buildFlightResults() {
    return ListView.builder(
      itemCount: 5, // 예제: 5개의 결과만 표시
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text('비행 ${index + 1}'),
            subtitle: const Text('출발: 서울, 도착: 뉴욕\n시간: 10시간'),
            trailing: const Text('₩1,200,000'),
            onTap: () {
              setState(() {
                _selectedFlight = '비행 ${index + 1}';
              });
            },
          ),
        );
      },
    );
  }

  // "로그인 창으로 돌아가기" 버튼
  Widget _buildReturnButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignIn()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          minimumSize: const Size.fromHeight(50), // 버튼 높이 조정
        ),
        child: const Text(
          '로그인 창으로 돌아가기',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // 비행권 검색 API 호출 (예제)
  void _searchFlights() {
    // Amadeus, Skyscanner 등의 API를 사용해 데이터를 가져오는 로직 구현
    // 예: HTTP 요청 보내고 결과를 파싱하여 상태를 업데이트
    print('비행권 검색 API 호출');
  }
}