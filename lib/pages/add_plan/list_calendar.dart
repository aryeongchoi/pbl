import 'package:flutter/material.dart';
import 'calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ListCalendar extends StatefulWidget {
  const ListCalendar({super.key});

  @override
  _ListCalendarState createState() => _ListCalendarState();
}

class _ListCalendarState extends State<ListCalendar> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;


    return Scaffold(
      appBar: AppBar(
        title: const Text("여행 일정 목록"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final calendars = snapshot.data!.docs;

          return ListView.builder( //일정 표시
            itemCount: calendars.length,
            itemBuilder: (context, index) {
              final calendar = calendars[index];
              final start_date = (calendar['start_date'] as Timestamp).toDate(); //여행 기간 표시용
              final end_date = (calendar['end_date'] as Timestamp).toDate(); //여행 기간 표시용
              return ListTile(
                title: Text(calendar['name'] ?? 'Unnamed Calendar'),
                subtitle: Text(
                  '${DateFormat('yyyy-MM-dd').format(start_date)} ~ ${DateFormat('yyyy-MM-dd').format(end_date)}', // 여행 기간 표시
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('삭제 확인'),
                                content: const Text('정말로 이 일정을 삭제하시겠습니까?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('취소'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('삭제'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await _deleteCalendar(userId, calendar.id);
                          }
                        },
                      )
                    : null,
                onTap: () async {
                  String dayId = 'defaultDayId'; // 기본값 설정

                  // Firestore에서 날짜 목록을 가져오기
                  final datesSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('calendars')
                      .doc(calendar.id)
                      .collection('dates')
                      .orderBy('date') // 날짜를 기준으로 정렬
                      .get();

                  if (datesSnapshot.docs.isNotEmpty) {
                    // 가장 첫 번째 날짜의 문서 ID를 dayId로 사용
                    dayId = datesSnapshot.docs.first.id;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Calendar(
                        calendarId: calendar.id,
                        dayId: dayId, // Firestore에서 가져온 dayId 사용
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCalendarDialog(context, userId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteCalendar(String? userId, String calendarId) async {
    if (userId != null) {
      try {
        final datesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .doc(calendarId)
            .collection('dates')
            .get();

        for (var dateDoc in datesSnapshot.docs) {
          final placesSnapshot =
              await dateDoc.reference.collection('places').get();
          for (var placeDoc in placesSnapshot.docs) {
            await placeDoc.reference.delete();
          }
          await dateDoc.reference.delete();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .doc(calendarId)
            .delete();

        print('Calendar and its subcollections deleted: $calendarId');
      } catch (e) {
        print('Failed to delete calendar: $e');
      }
    }
  }

  void _showAddCalendarDialog(BuildContext context, String? userId) {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 일정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '일정 이름'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  startDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text(startDate == null
                    ? '시작 날짜 선택'
                    : '시작 날짜: ${startDate.toString().split(' ')[0]}'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  endDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text(endDate == null
                    ? '종료 날짜 선택'
                    : '종료 날짜: ${endDate.toString().split(' ')[0]}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('추가'),
              onPressed: () async {
                if (userId != null &&
                    nameController.text.isNotEmpty &&
                    startDate != null &&
                    endDate != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('calendars')
                      .add({
                    'name': nameController.text,
                    'start_date': startDate,
                    'end_date': endDate,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
