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
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
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

              final formattedStartDate = DateFormat('MM-dd').format(startDate);
              final formattedEndDate = DateFormat('MM-dd').format(endDate);
              final duration = endDate.difference(startDate).inDays + 1;

              return Dismissible(
                key: Key(calendar.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await _deleteCalendar(userId, calendar.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${calendar['name']} 일정이 삭제되었습니다.'),
                    ),
                  );
                },
                confirmDismiss: (direction) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('삭제 확인'),
                        content: const Text('정말로 이 일정을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            child: const Text('취소'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('삭제'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );
                  return confirm ?? false;
                },
                child: Card(
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
                          blurStyle: BlurStyle.normal,
                        ),
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
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Calendar(
                              calendarId: calendar.id,
                              dayId: calendar.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
