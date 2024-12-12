import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_custom_marker/google_maps_custom_marker.dart';

class OtherUsersCalendarViewer extends StatefulWidget {
  final String calendarId;
  final String dayId;
  final String userId;

  const OtherUsersCalendarViewer(
      {super.key,
      required this.calendarId,
      required this.dayId,
      required this.userId});

  @override
  _OtherUsersCalendarViewerState createState() =>
      _OtherUsersCalendarViewerState();
}

class _OtherUsersCalendarViewerState extends State<OtherUsersCalendarViewer> {
  final CameraPosition _initCameraPosition = const CameraPosition(
    target: LatLng(35.156199, 128.093145),
    zoom: 15.5,
  );

  GoogleMapController? _googleMapController;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  List<LatLng> _defaultLineCoordinates = [];
  List<String> _dateList = [];
  String? _selectedDay;
  String? _calendarName;
  DateTime? _startDate;
  DateTime? _endDate;
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _loadDateList();
    _loadPlaceCoordinates();
  }

  Future<void> _loadPlaceCoordinates() async {
    final placesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('calendars')
        .doc(widget.calendarId)
        .collection('dates')
        .doc(widget.dayId)
        .collection('places')
        .orderBy('order')
        .get();

    List<LatLng> coordinates = [];
    for (var place in placesSnapshot.docs) {
      final geoPoint = place['location'] as GeoPoint;
      coordinates.add(LatLng(geoPoint.latitude, geoPoint.longitude));
    }

    setState(() {
      _defaultLineCoordinates = coordinates;
      _polylineCoordinates = coordinates;
    });
  }

  void _loadDateList() async {
    final calendarDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('calendars')
        .doc(widget.calendarId)
        .get();

    if (calendarDoc.exists) {
      final data = calendarDoc.data();

      setState(() {
        _calendarName = data?['name'];
        _startDate = (data?['start_date'] as Timestamp).toDate();
        _endDate = (data?['end_date'] as Timestamp).toDate();
        _dateList = _generateDayIdList(_startDate!, _endDate!);
        _selectedDay = _dateList.isNotEmpty ? _dateList[0] : null;
        if (_selectedDay != null) {
          _loadDayItinerary(_selectedDay!);
        }
      });
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

  void _loadDayItinerary(String dayId) async {
    final placesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('calendars')
        .doc(widget.calendarId)
        .collection('dates')
        .doc(dayId)
        .collection('places')
        .orderBy('order')
        .get();

    Set<Marker> markers = {};
    List<LatLng> polylineCoordinates = [];

    for (int i = 0; i < placesSnapshot.docs.length; i++) {
      final placeDoc = placesSnapshot.docs[i];
      final data = placeDoc.data();
      final geoPoint = data['location'] as GeoPoint;
      final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

      // 커스텀 마커 생성
      Marker marker = await GoogleMapsCustomMarker.createCustomMarker(
        marker: Marker(
          markerId: MarkerId('pin_labeled_$i'),
          position: latLng,
        ),
        shape: MarkerShape.pin,
        backgroundColor: GoogleMapsCustomMarkerColor
            .markerColors[i % GoogleMapsCustomMarkerColor.markerColors.length],
        title: (i + 1).toString(), // 장소 순서에 맞춰 숫자를 표시
        pinOptions: PinMarkerOptions(diameter: 30), // 마커 크기 조절
      );

      markers.add(marker);
      polylineCoordinates.add(latLng);
    }

    setState(() {
      _markers = markers;
      _polylineCoordinates = polylineCoordinates;
      _selectedDay = dayId;
    });

    if (polylineCoordinates.isNotEmpty) {
      _moveCameraToPlace(polylineCoordinates.first);
    }
  }

  void _moveCameraToPlace(LatLng target) {
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
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
        title: Text(_calendarName ?? '여행 일정'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      offset: const Offset(0, -10),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ]),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                initialCameraPosition: _initCameraPosition,
                onMapCreated: (controller) {
                  _googleMapController = controller;
                },
                markers: _markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('api_route'),
                    color: Colors.blue,
                    width: 3,
                    points: _polylineCoordinates,
                  ),
                },
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dateList.length,
              itemBuilder: (context, index) {
                final dayId = _dateList[index];
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          offset: const Offset(0, 0),
                          blurRadius: 5,
                          spreadRadius: 0.1,
                        )
                      ]),
                  margin: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      backgroundColor: _selectedDay == dayId
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDay = dayId;
                      });
                      _loadDayItinerary(dayId);
                    },
                    child: Text(
                      "Day ${index + 1}",
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            _selectedDay == dayId ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('calendars')
                  .doc(widget.calendarId)
                  .collection('dates')
                  .doc(_selectedDay)
                  .collection('places')
                  .orderBy('order')
                  .get(),
              builder: (context, placesSnapshot) {
                if (!placesSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final places = placesSnapshot.data!.docs;

                return ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final placeDoc = places[index];
                    final place = placeDoc.data() as Map<String, dynamic>;
                    final geoPoint = place['location'] as GeoPoint;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text((index + 1).toString()),
                      ),
                      title: Text(place['name']),
                      onTap: () {
                        _moveCameraToPlace(
                            LatLng(geoPoint.latitude, geoPoint.longitude));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
