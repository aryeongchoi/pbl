import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToMyTravel;

  const HomePage({super.key, required this.onNavigateToMyTravel});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5), // 양옆 패딩 추가
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 380,
                              height: 354,
                              child: TravelCard(
                                imagePath: 'images/ca.jpg',
                                isHot: true,
                                tag: '추천',
                                tagColor: Colors.red,
                              ),
                            ),
                            SizedBox(
                              width: 380,
                              height: 171,
                              child: TravelCard(
                                imagePath: 'images/oh.jpg',
                                isHot: false,
                                tag: 'D-10',
                                tagColor: Colors.blue,
                              ),
                            ),
                            SizedBox(
                              width: 380,
                              height: 354,
                              child: TravelCard(
                                imagePath: 'images/se.jpg',
                                isHot: true,
                                tag: '추천',
                                tagColor: Colors.red,
                              ),
                            ),
                            SizedBox(
                              width: 380,
                              height: 171,
                              child: TravelCard(
                                imagePath: 'images/oh.jpg',
                                isHot: false,
                                tag: 'D-10',
                                tagColor: Colors.blue,
                              ),
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TravelCard extends StatelessWidget {
  final String imagePath;
  final bool isHot;
  final String tag;
  final Color tagColor;

  const TravelCard({
    super.key,
    required this.imagePath,
    required this.isHot,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(0, 0),
              blurRadius: 5,
              spreadRadius: 1,
              blurStyle: BlurStyle.normal)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}