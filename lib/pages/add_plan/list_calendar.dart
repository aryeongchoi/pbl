import 'package:flutter/material.dart';
import 'package:truple_practice/pages/add_plan/survey1_page.dart';
import 'calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truple_practice/widgets/appbar.dart';
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
      appBar: CustomAppBar(
        title: '여행일정 목록', // AppBar 제목 설정
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.done : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing; // 편집 모드 토글
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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: calendars.length,
            itemBuilder: (context, index) {
              final calendar = calendars[index];
              final startDate = (calendar['start_date'] as Timestamp).toDate();
              final endDate = (calendar['end_date'] as Timestamp).toDate();

              // 날짜 형식 변환
              final formattedStartDate = DateFormat('MM-dd').format(startDate);
              final formattedEndDate = DateFormat('MM-dd').format(endDate);
              final duration = endDate.difference(startDate).inDays + 1;

              return Card(
                child: Container(
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
                          blurStyle: BlurStyle.normal)
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      calendar['name'] ?? 'Unnamed Calendar',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '$formattedStartDate ~ $formattedEndDate ($duration일)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: _isEditing
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('삭제 확인'),
                                    content: const Text('정말로 이 일정을 삭제하시겠습니까?'),
                                    actions: [
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
                        : const Icon(Icons.arrow_forward_ios,
                            color: Colors.black),
                    onTap: () {
                      // 특정 일정 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(
                              calendarId: calendar.id, dayId: calendar.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.91,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const FirstSurveyPage(), // SecondSurveyPage는 위젯이어야 함
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary, // 버튼 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
          ),
          child: const Text("일정 추가"),
        ),
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
