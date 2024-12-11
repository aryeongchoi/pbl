import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:truple_practice/widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddPlaceScreen extends StatefulWidget {
  final String calendarId;
  final String dayId; // 추가된 dayId

  const AddPlaceScreen({super.key, required this.calendarId, required this.dayId});

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final List<Prediction> _selectedPlaces = [];
  final TextEditingController _searchController = TextEditingController();
  final String apiKey = "AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4"; // Google API Key


  Future<void> _addPlaceToFirestore(Prediction prediction, double latitude, double longitude) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    String shortDescription = 'Unknown Location';
    double nextOrderDouble = 0.0;
    double rating = 0.0;

    if (userId != null) {
      try {
        shortDescription = prediction.structuredFormatting?.mainText ?? 'Unknown Location';
        final placeId = prediction.placeId ?? 'Unknown Place ID';

        // Google Places API를 사용하여 장소 세부 정보를 가져옵니다.
        final placeDetails = await _fetchPlaceDetails(placeId);
        final types = placeDetails['types'] as List<String>? ?? [];
        rating = (placeDetails['rating'] as num?)?.toDouble() ?? 0.0; // Ensure double type

        GeoPoint geoPoint = GeoPoint(latitude.toDouble(), longitude.toDouble());
        final cityName = await getCityName(LatLng(latitude, longitude));
        final nextOrderValue = await _getNextOrderValue();
        nextOrderDouble = nextOrderValue.toDouble(); // Ensure double type

        // 디버깅 로그
        print('Adding place with details: name: $shortDescription, order: $nextOrderDouble, rating: $rating');
        print('Order type: ${nextOrderDouble.runtimeType}, Rating type: ${rating.runtimeType}');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .doc(widget.calendarId)
            .collection('dates')
            .doc(widget.dayId)
            .collection('places')
            .add({
          'name': shortDescription,
          'location': geoPoint,
          'timestamp': FieldValue.serverTimestamp(),
          'order': nextOrderDouble, // Store as double
          'placeId': placeId,
          'types': types,
          'rating': rating, // Ensure double type
          'city': cityName ?? 'Unknown City',
        });
        await _updateCalendarCities(cityName ?? 'Unknown City');
        print('Place added with coordinates: ($latitude, $longitude)');
      } catch (e) {
        print('Failed to add place to Firestore: $e');
        // catch 블록에서도 로그 출력
        print('Error occurred while adding place with details: name: $shortDescription, order: $nextOrderDouble, rating: $rating');
        print('Order type: ${nextOrderDouble.runtimeType}, Rating type: ${rating.runtimeType}');
        print('Prediction details: ${prediction.description}, lat: $latitude, lng: $longitude');
      }
    } else {
      print('User is not logged in.');
    }
  }


  Future<void> _updateCalendarCities(String cityName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final calendarRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId);
      final calendarDoc = await calendarRef.get();
      if (calendarDoc.exists) {
        List<String> cities = List.from(calendarDoc.data()?['cities'] ?? []);
        if (!cities.contains(cityName)) {
          cities.add(cityName);
          await calendarRef.set({'cities': cities}, SetOptions(merge: true));
        }
      } else {
        await calendarRef.set({'cities': [cityName]}, SetOptions(merge: true));
      }
    }
  }

  Future<double> _getNextOrderValue() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('dates')
          .doc(widget.dayId)
          .collection('places')
          .orderBy('order', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastOrder = querySnapshot.docs.first['order'] ?? 0;
        print('Last order found: $lastOrder'); // 디버깅을 위한 로그 추가
        return (lastOrder as num).toDouble() + 1.0;
      }
    }
    return 1.0;
  }

  Future<String?> getCityName(LatLng latLng) async { //각 장소의 도시 파악
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${apiKey}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        for (var component in data['results'][0]['address_components']) {
          if (component['types'].contains('locality')) {
            return component['long_name'];
          }
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _fetchPlaceDetails(String placeId) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final result = data['result'];
        final types = (result['types'] as List<dynamic>?)?.map((item) => item as String).toList() ?? [];
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
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
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
          Container(
            padding: const EdgeInsets.all(8.0),
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
                    MaterialPageRoute(
                      builder: (context) => Calendar(calendarId: widget.calendarId, dayId: widget.dayId),
                    ),
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