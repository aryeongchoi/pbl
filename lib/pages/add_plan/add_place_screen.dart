import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:truple_practice/widgets/appbar.dart';
import 'calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPlaceScreen extends StatefulWidget {
  final String calendarId;
  final String dayId; // 추가된 dayId

  const AddPlaceScreen(
      {super.key, required this.calendarId, required this.dayId});

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final List<Prediction> _selectedPlaces = [];
  final TextEditingController _searchController = TextEditingController();
  final String apiKey =
      "AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4"; // Google API Key

  Future<void> _addPlaceToFirestore(
      Prediction prediction, double latitude, double longitude, String dayId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final shortDescription =
            prediction.structuredFormatting?.mainText ?? 'Unknown Location';
        final placeId = prediction.placeId ?? 'Unknown Place ID';

        // Google Places API를 사용하여 장소 세부 정보를 가져옵니다.
        final placeDetails = await _fetchPlaceDetails(placeId);
        final types = placeDetails['types'] as List<String>? ?? [];
        final rating = placeDetails['rating'] as double? ?? 0.0;

        final nextOrderValue = await _getNextOrderValue();

        // Firestore에 장소 추가
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .doc(widget.calendarId)
            .collection('dates')
            .doc(dayId) // 'day01', 'day02'와 같은 형식으로 사용
            .collection('places')
            .add({
          'name': shortDescription,
          'location': GeoPoint(latitude, longitude),
          'timestamp': FieldValue.serverTimestamp(),
          'order': nextOrderValue,
          'placeId': placeId,
          'types': types,
          'rating': rating,
        });
        print('Place added with coordinates: ($latitude, $longitude)');
      } catch (e) {
        print('Failed to add place to Firestore: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  Future<int> _getNextOrderValue() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('dates')
          .doc(widget.dayId) // 전달받은 dayId 사용
          .collection('places')
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return (querySnapshot.docs.first['order'] as int) + 1;
      }
    }
    return 1;
  }

  Future<Map<String, dynamic>> _fetchPlaceDetails(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        // 명시적 타입 변환
        final types = (result['types'] as List<dynamic>?)
                ?.map((item) => item as String)
                .toList() ??
            [];
        final rating = result['rating'] as double? ?? 0.0;
        return {
          'types': types,
          'rating': rating,
        };
      }
    }
    return {'types': [], 'rating': 0.0};
  }

  Future<String?> fetchPhotoReference(String placeId) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final photos = data['result']['photos'];
      if (photos != null && photos.isNotEmpty) {
        return photos[0]['photo_reference'];
      }
    }
    return null;
  }

  String getPhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=100&photoreference=$photoReference&key=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(title: '검색'),
      body: Column(
        children: [
          GooglePlaceAutoCompleteTextField(
            textEditingController: _searchController,
            googleAPIKey: apiKey,
            inputDecoration: const InputDecoration(
              hintText: "장소 검색",
              border: OutlineInputBorder(),
            ),
            debounceTime: 800,
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              final latitude = double.tryParse(prediction.lat ?? '') ?? 0.0;
              final longitude = double.tryParse(prediction.lng ?? '') ?? 0.0;

              if (latitude == 0.0 && longitude == 0.0) {
                print(
                    'Warning: Coordinates are (0.0, 0.0). This may indicate missing or invalid data.');
              }

              print('Coordinates: ($latitude, $longitude)');

              setState(() {
                _selectedPlaces.add(prediction);
                _searchController.clear(); // 검색창 초기화
              });
            },
            itemClick: (Prediction prediction) {
              _searchController.text = prediction.description ?? '';
            },
          ),
          const SizedBox(height: 10),
          const Spacer(),
          SizedBox(
            height: screenHeight / 3,
            child: FutureBuilder<List<Widget>>(
              future: _buildSearchResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return snapshot.data![index];
                    },
                  );
                } else {
                  return const Center(child: Text('No search results'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.91,
        height: 80,
        child: FloatingActionButton(
          onPressed: () async {
            if (_selectedPlaces.isNotEmpty) {
              for (var place in _selectedPlaces) {
                final latitude = double.tryParse(place.lat ?? '') ?? 0.0;
                final longitude = double.tryParse(place.lng ?? '') ?? 0.0;

                if (latitude != 0.0 && longitude != 0.0) {
                  await _addPlaceToFirestore(place, latitude, longitude, widget.dayId);
                } else {
                  print('Invalid coordinates for place: ${place.description}');
                }
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Calendar(
                      calendarId: widget.calendarId, dayId: widget.dayId),
                ),
              );
            } else {
              print('No place selected to add.');
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary, // 버튼 배경색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
          ),
          child: const Text("장소 추가"),
        ),
      ),
    );
  }

  Future<List<Widget>> _buildSearchResults() async {
    List<Widget> searchResults = [];
    for (var place in _selectedPlaces) {
      final photoReference = await fetchPhotoReference(place.placeId ?? '');
      if (photoReference != null) {
        final photoUrl = getPhotoUrl(photoReference);
        searchResults.add(
          ListTile(
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlaces.remove(place);
                  _searchController.clear(); // 검색창 초기화
                });
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(photoUrl, fit: BoxFit.cover),
              ),
            ),
            title: Text(place.description ?? ''),
          ),
        );
      }
    }
    return searchResults;
  }
}
