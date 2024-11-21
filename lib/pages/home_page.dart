import 'package:flutter/material.dart';
import 'add_plan/list_calendar.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToMyTravel;

  const HomePage({super.key, required this.onNavigateToMyTravel});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
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
                    blurStyle: BlurStyle.normal)
              ]),
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
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //사진자체에는 그림자가 안들어가 밖에있는 contanier
                          // 그림자같은거 전역으로 하나 만들려고 하는데 어느정도가 괜찮은지 한번 봐줄래
                          SizedBox(
                            width: 350,
                            height: 354,
                            child: TravelCard(
                              imagePath: 'images/ca.jpg',
                              isHot: true,
                              tag: '추천',
                              tagColor: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            height: 171,
                            child: TravelCard(
                              imagePath: 'images/oh.jpg',
                              isHot: false,
                              tag: 'D-10',
                              tagColor: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            height: 354,
                            child: TravelCard(
                              imagePath: 'images/se.jpg',
                              isHot: true,
                              tag: '추천',
                              tagColor: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            height: 171,
                            child: TravelCard(
                              imagePath: 'images/oh.jpg',
                              isHot: false,
                              tag: 'D-10',
                              tagColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListCalendar()), // 이동할 페이지 지정
          );
        },
        child: const Icon(Icons.add),
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
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(0, 0),
              blurRadius: 10,
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
