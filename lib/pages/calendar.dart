import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_place_screen.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  final String calendarId;

  const Calendar({Key? key, required this.calendarId}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CameraPosition _initCameraPosition = const CameraPosition(
    target: LatLng(35.156199, 128.093145), // 초기 위치
    zoom: 15.5,
  );

  GoogleMapController? _googleMapController;
  Set<Marker> _markers = {};
  List<LatLng> _polylineCoordinates = [];
  bool _isEditing = false;
  List<String> _dateList = [];
  String? _selectedDay; // 현재 선택된 날짜

  @override
  void initState() {
    super.initState();
    _loadDateList();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  void _loadDateList() async {
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
        final startDate = (data?['start_date'] as Timestamp).toDate();
        final endDate = (data?['end_date'] as Timestamp).toDate();

        setState(() {
          _dateList = _generateDateList(startDate, endDate);
        });
      }
    }
  }

  List<String> _generateDateList(DateTime startDate, DateTime endDate) {
    List<String> dateList = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dateList.add(DateFormat('yyyy-MM-dd').format(currentDate));
      currentDate = currentDate.add(Duration(days: 1));
    }

    return dateList;
  }

  void _loadDayItinerary(String dayId) async {
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
      List<LatLng> polylineCoordinates = [];

      for (var placeDoc in placesSnapshot.docs) {
        final data = placeDoc.data() as Map<String, dynamic>;
        final geoPoint = data['location'] as GeoPoint;
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        markers.add(Marker(
          markerId: MarkerId(placeDoc.id),
          position: latLng,
          infoWindow: InfoWindow(title: data['name']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));

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
  }

  void _moveCameraToPlace(LatLng target) {
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
  }

  Future<void> _updatePlaceOrder(String dayId, List<DocumentSnapshot> places) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      for (int i = 0; i < places.length; i++) {
        final placeDoc = places[i];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .doc(widget.calendarId)
            .collection('dates')
            .doc(dayId)
            .collection('places')
            .doc(placeDoc.id)
            .update({'order': i});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("여행 일정"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
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
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 3,
                  patterns: const [PatternItem.dot],
                  points: _polylineCoordinates,
                ),
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _dateList.length,
              itemBuilder: (context, index) {
                final dateId = _dateList[index];
                return ExpansionTile(
                  title: Text(dateId),
                  initiallyExpanded: dateId == _selectedDay,
                  onExpansionChanged: (expanded) {
                    if (expanded) {
                      _loadDayItinerary(dateId);
                    }
                  },
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection('calendars')
                          .doc(widget.calendarId)
                          .collection('dates')
                          .doc(dateId)
                          .collection('places')
                          .orderBy('order')
                          .get(),
                      builder: (context, placesSnapshot) {
                        if (!placesSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final places = placesSnapshot.data!.docs;

                        return ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: places.length,
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = places.removeAt(oldIndex);
                            places.insert(newIndex, item);
                            await _updatePlaceOrder(dateId, places);
                            setState(() {
                              _loadDayItinerary(dateId);
                            });
                          },
                          itemBuilder: (context, index) {
                            final placeDoc = places[index];
                            final place = placeDoc.data() as Map<String, dynamic>;
                            final geoPoint = place['location'] as GeoPoint;
                            final order = place['order'] as int;

                            return ListTile(
                              key: ValueKey(placeDoc.id),
                              leading: _isEditing
                                  ? Icon(Icons.menu) // 수정 모드에서는 햄버거 아이콘
                                  : CircleAvatar( // 수정 모드가 아닐 때는 order 아이콘
                                backgroundColor: Colors.grey[200],
                                child: Text(order.toString()),
                              ),
                              title: Text(place['name']),
                              onTap: () {
                                _moveCameraToPlace(LatLng(geoPoint.latitude, geoPoint.longitude));
                              },
                              trailing: _isEditing
                                  ? IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("일정 삭제"),
                                      content: const Text("정말로 삭제하시겠습니까?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("취소"),
                                          onPressed: () => Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text("삭제"),
                                          onPressed: () => Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser?.uid)
                                        .collection('calendars')
                                        .doc(widget.calendarId)
                                        .collection('dates')
                                        .doc(dateId)
                                        .collection('places')
                                        .doc(placeDoc.id)
                                        .delete();

                                    _loadDayItinerary(dateId);
                                  }
                                },
                              )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPlaceScreen(
                              calendarId: widget.calendarId,
                              dayId: dateId,
                            ),
                          ),
                        );
                      },
                      child: Text('일정 추가'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 전체 일정에 대한 추가 논리
        },
        tooltip: "일정 추가",
        child: const Icon(Icons.add),
      ),
    );
  }
}
