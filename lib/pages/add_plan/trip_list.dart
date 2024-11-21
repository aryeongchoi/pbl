import 'package:flutter/material.dart';
import 'list_calendar.dart';

class TripList extends StatefulWidget {
  const TripList({super.key});

  @override
  State<TripList> createState() => _HomeState();
}

class _HomeState extends State<TripList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TripList"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListCalendar()),
            );
          },
          child: const Text("Go to Trip List"),
        ),
      ),
    );
  }
}
