import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:truple_practice/widgets/appbar.dart'; // 이전 페이지 import

class Survey1Page extends StatefulWidget {
  const Survey1Page({super.key});

  @override
  State<Survey1Page> createState() => _Survey1PageState();
}

class _Survey1PageState extends State<Survey1Page> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchEventsFromFirestore();
  }

  Future<void> _fetchEventsFromFirestore() async {
    try {
      final snapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .get();

      final List<Appointment> fetchedAppointments = [];

      for (var doc in snapshots.docs) {
        final data = doc.data();
        final startDate = (data['start_date'] as Timestamp).toDate();
        final endDate = (data['end_date'] as Timestamp).toDate();
        final name = data['name'] ?? 'No Title';

        fetchedAppointments.add(Appointment(
          startTime: startDate,
          endTime: endDate,
          subject: name,
          color: Colors.blue.withOpacity(0.2), // 약간 투명한 색상
        ));
      }

      setState(() {
        _appointments = fetchedAppointments;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "상세 설문"),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: AppointmentDataSource(_appointments),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * 0.91,
        height: 80,
        margin: const EdgeInsets.only(bottom: 30),
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

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
