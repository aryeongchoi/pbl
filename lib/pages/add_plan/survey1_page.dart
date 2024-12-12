import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:truple_practice/widgets/appbar.dart'; // 이전 페이지 import
import 'package:truple_practice/pages/add_plan/survey2_page.dart'; // Survey2Page import

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
          color: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.2), // 약간 투명한 색상
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
      body: Column(
        children: [
          const SizedBox(height: 60), // 상단 여백
          _buildProgressIndicator(), // 상단 네모 두 개
          const SizedBox(height: 20), // 캘린더와 진행 표시기 간 여백
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 120),
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
              child: SfCalendar(
                view: CalendarView.month,
                dataSource: AppointmentDataSource(_appointments),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                ),
                headerHeight: 50, // 캘린더 헤더 높이 조정
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center, // 헤더 텍스트를 중앙 정렬
                  textStyle: TextStyle(
                    fontSize: 20, // 헤더 글꼴 크기
                    fontWeight: FontWeight.bold, // 글꼴 두께
                    color: Theme.of(context).colorScheme.onSurface, // 텍스트 색상
                  ),
                ),
                todayHighlightColor: Theme.of(context)
                    .colorScheme
                    .primaryContainer, // 오늘 날짜 강조 색상
                showNavigationArrow: true, // 네비게이션 화살표 추가
              ),
            ),
          ),
        ],
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
                builder: (context) => const Survey2Page(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressStep(isActive: true), // 첫 번째 진행 상태
        const SizedBox(width: 10),
        _buildProgressStep(isActive: false), // 두 번째 진행 상태
      ],
    );
  }

  Widget _buildProgressStep({required bool isActive}) {
    return Container(
      width: 70,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
