import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
          color: Colors.blue,
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
      appBar: AppBar(title: const Text("상세 설문")),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: AppointmentDataSource(_appointments),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
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
