import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final List<Prediction> _selectedPlaces = [];
  final TextEditingController _searchController = TextEditingController();
  final String apiKey = "AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4"; // Google API Key

  Future<void> _addPlaceToFirestore(Prediction prediction, double latitude, double longitude) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final shortDescription = prediction.structuredFormatting?.mainText ?? 'Unknown Location';
        final placeId = prediction.placeId ?? 'Unknown Place ID';

        final nextOrderValue = await _getNextOrderValue();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('itineraries')
            .add({
          'name': shortDescription,
          'location': GeoPoint(latitude, longitude),
          'timestamp': FieldValue.serverTimestamp(),
          'order': nextOrderValue,
          'placeId': placeId,
        });
        print('Place added with coordinates: ($latitude, $longitude)');
      } catch (e) {
        print('Failed to add place to Firestore: $e');
        print('Prediction details: ${prediction.description}, lat: $latitude, lng: $longitude');
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
          .collection('itineraries')
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return (querySnapshot.docs.first['order'] as int) + 1;
      }
    }
    return 1;
  }

  Future<String?> fetchPhotoReference(String placeId) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
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
      appBar: AppBar(
        title: const Text("장소 추가"),
      ),
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
              if (prediction != null) {
                final latitude = double.tryParse(prediction.lat ?? '') ?? 0.0;
                final longitude = double.tryParse(prediction.lng ?? '') ?? 0.0;

                if (latitude == 0.0 && longitude == 0.0) {
                  print('Warning: Coordinates are (0.0, 0.0). This may indicate missing or invalid data.');
                }

                print('Coordinates: ($latitude, $longitude)');

                setState(() {
                  _selectedPlaces.add(prediction);
                  _searchController.clear(); // 검색창 초기화
                });
              } else {
                print('Prediction was null');
              }
            },
            itemClick: (Prediction prediction) {
              _searchController.text = prediction.description ?? '';
            },
          ),
          const SizedBox(height: 10),
          Spacer(), // This spacer pushes the following elements to the bottom
          SizedBox(
            height: screenHeight / 3, // 화면의 1/3 높이
            child: FutureBuilder<List<Widget>>(
              future: _buildSearchResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => SizedBox(height: 10), // 항목 간의 간격
                    itemBuilder: (context, index) {
                      return snapshot.data![index];
                    },
                  );
                } else {
                  return Center(child: Text('No search results'));
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            child: ElevatedButton(
              onPressed: () async {
                if (_selectedPlaces.isNotEmpty) {
                  for (var place in _selectedPlaces) {
                    final latitude = double.tryParse(place.lat ?? '') ?? 0.0;
                    final longitude = double.tryParse(place.lng ?? '') ?? 0.0;

                    if (latitude != 0.0 && longitude != 0.0) {
                      await _addPlaceToFirestore(place, latitude, longitude);
                    } else {
                      print('Invalid coordinates for place: ${place.description}');
                    }
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Calendar()),
                  );
                } else {
                  print('No place selected to add.');
                }
              },
              child: const Text('선택 완료'),
            ),
          )
        ],
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
                aspectRatio: 1, // 정사각형 비율
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