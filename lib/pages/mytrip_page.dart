import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_plan/calendar.dart';

class MyTripPage extends StatefulWidget {
  const MyTripPage({super.key});

  @override
  State<MyTripPage> createState() => _MyTripPageState();
}

class _MyTripPageState extends State<MyTripPage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(45),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                offset: const Offset(0, 0),
                blurRadius: 10,
                spreadRadius: 1,
                blurStyle: BlurStyle.normal,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: Colors.teal,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼 동작
          },
        ),
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
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
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
                        builder: (context) => Calendar(calendarId: calendar.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
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
}
