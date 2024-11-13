import 'package:flutter/material.dart';
import 'calendar.dart';
//googleAPIKey: "AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4"
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Calendar()),
            );
          },
          child: const Text("Go to Calendar"),
        ),
      ),
    );
  }
}