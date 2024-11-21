import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_place_screen.dart';
import 'package:intl/intl.dart';
import 'package:truple_practice/widgets/appbar.dart';

class Calendar extends StatefulWidget {
  final String calendarId;

  const Calendar({super.key, required this.calendarId});

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
          _selectedDay = _dateList.isNotEmpty ? _dateList[0] : null; // 기본 선택 날짜
          if (_selectedDay != null) {
            _loadDayItinerary(_selectedDay!); // 기본 날짜의 일정을 불러옴
          }
        });
      }
    }
  }

  List<String> _generateDateList(DateTime startDate, DateTime endDate) {
    List<String> dateList = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dateList.add(DateFormat('yyyy-MM-dd').format(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
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
        final data = placeDoc.data();
        final geoPoint = data['location'] as GeoPoint;
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        markers.add(Marker(
          markerId: MarkerId(placeDoc.id),
          position: latLng,
          infoWindow: InfoWindow(title: data['name']),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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

  Future<void> _updatePlaceOrder(String dayId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final places = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('dates')
          .doc(dayId)
          .collection('places')
          .orderBy('order')
          .get();

      for (int i = 0; i < places.docs.length; i++) {
        final placeDoc = places.docs[i];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('calendars')
            .doc(widget.calendarId)
            .collection('dates')
            .doc(dayId)
            .collection('places')
            .doc(placeDoc.id)
            .update({'order': i}); // 순서를 0부터 재설정
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '여행일정 목록', // AppBar 제목 설정
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.done : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing; // 편집 모드 토글
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Google Map
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(20, 0, 0, 0),
                      offset: Offset(0, -10),
                      spreadRadius: 1,
                      blurRadius: 20,
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
                    polylineId: const PolylineId('route'),
                    color: Colors.blue,
                    width: 3,
                    patterns: const [PatternItem.dot],
                    points: _polylineCoordinates,
                  ),
                },
              ),
            ),
          ),
          // 날짜 버튼을 수평으로 배치하여 Google Map 아래에 표시
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dateList.length,
              itemBuilder: (context, index) {
                final dateId = _dateList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedDay == dateId
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300], // 버튼 크기 조절
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDay = dateId;
                      });
                      _loadDayItinerary(dateId);
                    },
                    child: Text(
                      "Day ${index + 1}",
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDay == dateId
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 일정 리스트 및 추가 버튼
          Expanded(
            flex: 1,
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
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

                return Column(
                  children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: places.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = places.removeAt(oldIndex);
                          places.insert(newIndex, item);
                          await _updatePlaceOrder(_selectedDay!);
                          setState(() {
                            _loadDayItinerary(_selectedDay!);
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
                                ? const Icon(Icons.menu)
                                : CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    child: Text((index + 1).toString()),
                                  ),
                            title: Text(place['name']),
                            onTap: () {
                              _moveCameraToPlace(LatLng(
                                  geoPoint.latitude, geoPoint.longitude));
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
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                            ),
                                            TextButton(
                                              child: const Text("삭제"),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser?.uid)
                                            .collection('calendars')
                                            .doc(widget.calendarId)
                                            .collection('dates')
                                            .doc(_selectedDay)
                                            .collection('places')
                                            .doc(placeDoc.id)
                                            .delete();

                                        await _updatePlaceOrder(_selectedDay!);
                                        setState(() {
                                          _loadDayItinerary(_selectedDay!);
                                        });
                                      }
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("일정 추가"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPlaceScreen(
                                calendarId: widget.calendarId,
                                dayId: _selectedDay!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
