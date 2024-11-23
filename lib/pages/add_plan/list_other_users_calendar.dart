import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'other_users_calendar_viewer.dart'; // Make sure to create this file and widget

class ListOtherUsersCalendar extends StatelessWidget {
  final List<String> cities;

  const ListOtherUsersCalendar({Key? key, required this.cities}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchOtherUsersCalendars() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final querySnapshots = await FirebaseFirestore.instance
          .collectionGroup('calendars')
          .where('cities', arrayContainsAny: cities)
          .get();

      final calendars = querySnapshots.docs.map((doc) {
        final data = doc.data();
        final calendarId = doc.id; // 문서의 ID를 사용
        final pathSegments = doc.reference.path.split('/');
        final calendarUserId = pathSegments[pathSegments.indexOf('users') + 1];

        return {
          'calendarId': calendarId,
          'userId': calendarUserId,
          ...data, // 기존 데이터 포함
        };
      }).where((calendar) => calendar['userId'] != currentUserId).toList(); // 자신 제외

      // 로그 추가: 가져온 일정 수와 각 일정의 이름을 출력
      print("Fetched ${calendars.length} calendars:");
      for (var calendar in calendars) {
        print("Calendar Name: ${calendar['name'] ?? 'Unnamed'}");
      }

      return calendars;
    } catch (e) {
      print("Error fetching calendars: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다른 사용자의 ${cities} 일정'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOtherUsersCalendars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('다른 사용자의 일정이 없습니다.'));
          } else {
            final calendars = snapshot.data!;

            // 일정 랜덤하게 선택
            calendars.shuffle();

            return ListView.builder(
              itemCount: calendars.length,
              itemBuilder: (context, index) {
                final calendar = calendars[index];
                return ListTile(
                  title: Text(calendar['name'] ?? '이름 없음'),
                  subtitle: Text((calendar['cities'] as List).join(', ')),
                  onTap: () {
                    // calendarId, dayId, userId가 null이 아닌지 확인
                    final calendarId = calendar['calendarId'];
                    final userId = calendar['userId'];
                    final dayId = 'day01'; // 필요한 경우 기본값 사용

                    if (calendarId != null && userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherUsersCalendarViewer(
                            calendarId: calendarId,
                            dayId: dayId, // 기본값 또는 적절한 값 사용
                            userId: userId,
                          ),
                        ),
                      );
                    } else {
                      // 오류 처리: 데이터가 누락된 경우 사용자에게 알림
                      print('Invalid calendar data: calendarId or userId is null.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('일정을 표시할 수 없습니다. 데이터가 유효하지 않습니다.')),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}