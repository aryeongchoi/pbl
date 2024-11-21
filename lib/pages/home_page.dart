import 'package:flutter/material.dart';
import 'add_plan/trip_list.dart';

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
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(45),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: PageView(
                  controller: _pageController,
                  children: const [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        SizedBox(height: 16),
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TripList()), // 이동할 페이지 지정
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
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
    return ClipRRect(
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
    );
  }
}
