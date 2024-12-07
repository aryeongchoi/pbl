import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';

class CalendarScheduling extends StatefulWidget {
  final String calendarId;
  final String dayId;

  const CalendarScheduling({super.key, required this.calendarId, required this.dayId});

  @override
  _CalendarSchedulingState createState() => _CalendarSchedulingState();
}

class _CalendarSchedulingState extends State<CalendarScheduling> {
  final CameraPosition _initCameraPosition = const CameraPosition(
    target: LatLng(35.156199, 128.093145),
    zoom: 15.5,
  );

  GoogleMapController? _googleMapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _selectedOption = 'distance'; // 기본 옵션 설정
  List<String> _dateList = [];
  String? _selectedDay;
  PolylinePoints polylinePoints = PolylinePoints();

  // 폴리라인 색상 목록
  final List<Color> _polylineColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _loadDateList();
  }

  Future<void> _loadDateList() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final calendarDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .get();

      if (calendarDoc.exists) {
        final data = calendarDoc.data();
        setState(() {
          _dateList = _generateDayIdList(
            (data?['start_date'] as Timestamp).toDate(),
            (data?['end_date'] as Timestamp).toDate(),
          );
          _selectedDay = _dateList.isNotEmpty ? _dateList[0] : null;
          if (_selectedDay != null) {
            _loadDayItinerary(_selectedDay!);
          }
        });
      }
    }
  }

  List<String> _generateDayIdList(DateTime startDate, DateTime endDate) {
    List<String> dayIdList = [];
    DateTime currentDate = startDate;
    int dayCounter = 1;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dayIdList.add('day${dayCounter.toString().padLeft(2, '0')}');
      currentDate = currentDate.add(const Duration(days: 1));
      dayCounter++;
    }

    return dayIdList;
  }

  Future<void> _loadDayItinerary(String dayId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final placesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('dates')
          .doc(dayId)
          .collection('places')
          .orderBy('order')
          .get();

      Set<Marker> markers = {};
      List<LatLng> placeCoordinates = [];

      for (int i = 0; i < placesSnapshot.docs.length; i++) {
        final placeDoc = placesSnapshot.docs[i];
        final data = placeDoc.data();
        final geoPoint = data['location'] as GeoPoint;
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        markers.add(
          Marker(
            markerId: MarkerId('place_$i'),
            position: latLng,
            infoWindow: InfoWindow(
              title: data['name'],
              snippet: 'Type: ${data['types'].join(', ')}\nRating: ${data['rating']}',
            ),
          ),
        );

        placeCoordinates.add(latLng);
      }

      setState(() {
        _markers = markers;
        _selectedDay = dayId;
      });

      if (placeCoordinates.isNotEmpty) {
        _moveCameraToPlace(placeCoordinates.first);
        _calculateRoutes(placeCoordinates);
      }
    }
  }

  void _moveCameraToPlace(LatLng target) {
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
  }

  Future<void> _calculateRoutes(List<LatLng> places) async {
    _polylines.clear(); // 기존 폴리라인 제거

    for (int i = 0; i < places.length - 1; i++) {
      LatLng origin = places[i];
      LatLng destination = places[i + 1];
      await _compareAndSelectRoute(origin, destination, _polylineColors[i % _polylineColors.length]);
    }
  }

  Future<Map<String, dynamic>> _getRouteData(
      LatLng origin, LatLng destination, String mode) async {
    const apiKey = 'AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final polylinePoints = route['overview_polyline']['points'];
        final distance = route['legs'][0]['distance']['value'];
        final duration = route['legs'][0]['duration']['value'];
        return {
          'points': _decodePolyline(polylinePoints),
          'distance': distance,
          'duration': duration,
          'mode': mode,
        };
      }
    }
    return {};
  }

  List<LatLng> _decodePolyline(String encoded) {
    return polylinePoints
        .decodePolyline(encoded)
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  Future<void> _compareAndSelectRoute(LatLng origin, LatLng destination, Color polylineColor) async {
    List<String> modes = ['driving', 'walking', 'transit'];
    List<Map<String, dynamic>> routes = [];

    for (String mode in modes) {
      var routeData = await _getRouteData(origin, destination, mode);
      if (routeData.isNotEmpty) {
        routes.add(routeData);
      }
    }

    routes.sort((a, b) {
      if (_selectedOption == 'distance') {
        return a['distance'].compareTo(b['distance']);
      } else if (_selectedOption == 'duration') {
        return a['duration'].compareTo(b['duration']);
      }
      return 0;
    });

    if (routes.isNotEmpty) {
      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('${origin.latitude}_${origin.longitude}_${destination.latitude}_${destination.longitude}'),
          color: polylineColor,
          width: 3,
          points: routes.first['points'],
        ));
      });
    }
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 일정 스케줄링'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedOption = value;
              });
              if (_selectedDay != null) {
                _loadDayItinerary(_selectedDay!);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'distance', child: Text('최소 거리')),
              const PopupMenuItem(value: 'duration', child: Text('최소 시간')),
              const PopupMenuItem(value: 'price', child: Text('최소 요금')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initCameraPosition,
              onMapCreated: (controller) {
                _googleMapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dateList.length,
              itemBuilder: (context, index) {
                final dayId = _dateList[index];
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDay = dayId;
                    });
                    _loadDayItinerary(dayId);
                  },
                  child: Text("Day ${index + 1}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}