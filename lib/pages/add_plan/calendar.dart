import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_place_screen.dart';
import 'list_other_users_calendar.dart';
import 'calendar_scheduling.dart';
import 'package:intl/intl.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_custom_marker/google_maps_custom_marker.dart';



class RouteSegment { //경로 관리용
  final LatLng start;
  final LatLng end;
  final List<LatLng> polylinePoints;
  final String mode; // 모드 속성 추

  RouteSegment(this.start, this.end, this.polylinePoints, this.mode);
}

class Calendar extends StatefulWidget {
  final String calendarId;
  final String dayId;

  const Calendar({super.key, required this.calendarId, required this.dayId});

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
  List<LatLng> _defaultLineCoordinates = []; // 기본 직선 경로 저장
  bool _isEditing = false; //장소 수정용
  List<String> _dateList = [];
  String? _selectedDay; // 현재 선택된 날짜
  String? _calendarName;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEditingCalendarDetails = false; //여행 일정 이름, 기간 수정용
  PolylinePoints polylinePoints = PolylinePoints(); // 경로용
  List<String> _currentCities = [];
  bool _showingOtherUsers = false;
  Set<Polyline> _polylines = {};


  final List<Color> markerColors = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];



  @override
  void initState() {
    super.initState();
    _loadDateList();
    _loadPlaceCoordinates();
    _loadCurrentCities();
  }

  // Firestore에서 장소 좌표 가져오기
  Future<void> _loadPlaceCoordinates() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final placesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('dates')
          .doc(widget.dayId)
          .collection('places')
          .orderBy('order')
          .get(GetOptions(source: Source.cache)); // 오프라인 캐시 사용

      List<LatLng> coordinates = [];
      for (var place in placesSnapshot.docs) {
        final geoPoint = place['location'] as GeoPoint;
        coordinates.add(LatLng(geoPoint.latitude, geoPoint.longitude));
      }

      setState(() {
        _defaultLineCoordinates = coordinates;
        _polylineCoordinates = coordinates; // 초기에는 직선 경로 사용
      });
    }
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

        setState(() {
          _calendarName = data?['name'];
          _startDate = (data?['start_date'] as Timestamp).toDate();
          _endDate = (data?['end_date'] as Timestamp).toDate();
          _dateList = _generateDayIdList(_startDate!, _endDate!);
          _selectedDay = _dateList.isNotEmpty ? _dateList[0] : null; // 기본 선택 날짜
          if (_selectedDay != null) {
            _loadDayItinerary(_selectedDay!); // 기본 날짜의 일정을 불러옴
          }
        });
      }
    }
  }

  List<String> _generateDayIdList(DateTime startDate, DateTime endDate) {
    List<String> dayIdList = [];
    DateTime currentDate = startDate;
    int dayCounter = 1;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dayIdList.add('day${dayCounter.toString().padLeft(2, '0')}');
      currentDate = currentDate.add(const Duration(days: 1));
      dayCounter++;
    }

    return dayIdList;
  }

  void _loadDayItinerary(String dayId) async {
    // 일정 불러오기
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
          .get(GetOptions(source: Source.cache)); // 오프라인 캐시 사용

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
          backgroundColor: GoogleMapsCustomMarkerColor.markerBlue,
          title: (i + 1).toString(), // 장소 순서에 맞춰 숫자를 표시
          pinOptions: PinMarkerOptions(diameter: 30),
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
  }

  void _moveCameraToPlace(LatLng target) {
    //각 날짜의 첫번째 장소로 카메라 이동
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
  }

  Future<void> _updatePlaceOrder(String dayId, List<QueryDocumentSnapshot> places) async {
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
            .update({'order': i + 1}); // 0부터 재설정
      }
    }
  }

  Future<void> _updateCalendarDetails() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null &&
        _calendarName != null &&
        _startDate != null &&
        _endDate != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .update({
        'name': _calendarName,
        'start_date': _startDate,
        'end_date': _endDate,
      });

      // 날짜 문서 업데이트 시 기존의 장소 데이터 유지
      final datesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('dates');

      // 기존 문서 유지 및 새로운 문서 추가
      DateTime currentDate = _startDate!;
      int dayCounter = 1;
      while (!currentDate.isAfter(_endDate!)) {
        final dayId = 'day${dayCounter.toString().padLeft(2, '0')}';
        await datesCollection.doc(dayId).set({
          'date': currentDate,
        }, SetOptions(merge: true)); // 기존 데이터 유지
        currentDate = currentDate.add(const Duration(days: 1));
        dayCounter++;
      }
    }
  }

  void _toggleOtherUsersRoutes() async {
    if (_showingOtherUsers) {
      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value.startsWith('otherUser_'));
        _polylines.removeWhere((polyline) => polyline.polylineId.value.startsWith('otherUser_'));
        _showingOtherUsers = false;
      });
    } else {
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;

        final querySnapshots = await FirebaseFirestore.instance
            .collectionGroup('calendars')
            .where('cities', arrayContainsAny: _currentCities)
            .get();

        final otherCalendars = querySnapshots.docs
            .where((doc) {
          final pathSegments = doc.reference.path.split('/');
          final calendarUserId = pathSegments[pathSegments.indexOf('users') + 1];
          return calendarUserId != currentUserId;
        })
            .take(3)
            .toList();

        final colors = [Colors.red, Colors.green, Colors.blue];
        for (int i = 0; i < otherCalendars.length; i++) {
          final calendar = otherCalendars[i];
          final pathSegments = calendar.reference.path.split('/');
          final calendarUserId = pathSegments[pathSegments.indexOf('users') + 1];
          final color = colors[i % colors.length];

          final placesSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(calendarUserId)
              .collection('calendars')
              .doc(calendar.id)
              .collection('dates')
              .doc(_selectedDay)
              .collection('places')
              .orderBy('order')
              .get();

          List<LatLng> otherUserPolylineCoordinates = [];
          for (int j = 0; j < placesSnapshot.docs.length; j++) {
            final place = placesSnapshot.docs[j];
            final geoPoint = place['location'] as GeoPoint;
            final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

            otherUserPolylineCoordinates.add(latLng);

            // 마커 생성
            Marker marker = await GoogleMapsCustomMarker.createCustomMarker(
              marker: Marker(
                markerId: MarkerId('otherUser_${calendar.id}_${place.id}'),
                position: latLng,
              ),
              shape: MarkerShape.pin,
              backgroundColor: color,
              title: (j + 1).toString(),
              pinOptions: PinMarkerOptions(diameter: 30),
            );

            setState(() {
              _markers.add(marker);
            });
          }

          if (otherUserPolylineCoordinates.isNotEmpty) {
            print("Adding polyline with coordinates: $otherUserPolylineCoordinates");
            setState(() {
              _polylines.add(Polyline(
                polylineId: PolylineId('otherUser_route_${calendar.id}'),
                color: color,
                width: 5,
                points: otherUserPolylineCoordinates,
              ));
            });

            // Update camera to include the polyline
            _googleMapController?.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(
                    otherUserPolylineCoordinates.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
                    otherUserPolylineCoordinates.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
                  ),
                  northeast: LatLng(
                    otherUserPolylineCoordinates.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
                    otherUserPolylineCoordinates.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
                  ),
                ),
                50.0, // Padding
              ),
            );
          }
        }

        setState(() {
          _showingOtherUsers = true;
        });
      } catch (e) {
        print("Error showing other users' routes: $e");
      }
    }
  }

  void _loadCurrentCities() async {
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
          _currentCities = List<String>.from(data?['cities'] ?? []);
        });
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isEditingCalendarDetails = true;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _calendarName ?? '여행 일정',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _startDate != null && _endDate != null
                    ? '${DateFormat('yyyy-MM-dd').format(_startDate!)} ~ ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                    : '',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.done : Icons.edit,
              color: Colors.black,
            ),
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
          if (_isEditingCalendarDetails)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: _calendarName),
                    onChanged: (value) {
                      _calendarName = value;
                    },
                    decoration: const InputDecoration(
                      labelText: '일정 이름',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _startDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      _startDate == null
                          ? '시작 날짜 선택'
                          : '시작 날짜: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _endDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      _endDate == null
                          ? '종료 날짜 선택'
                          : '종료 날짜: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _updateCalendarDetails();
                      setState(() {
                        _isEditingCalendarDetails = false;
                        _loadDateList();
                      });
                    },
                    child: const Text('저장'),
                  ),
                ],
              ),
            ),
          // Google Map
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
                // Google Map의 polylines 설정 부분
                polylines: {
                  // 기본 직선 경로
                  Polyline(
                    polylineId: const PolylineId('default_route'),
                    color: Colors.grey,
                    width: 2,
                    points: _defaultLineCoordinates,
                  ),
                  // API 기반 경로
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
          // 날짜 버튼을 수평으로 배치하여 Google Map 아래에 표시
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
                          : Colors.white, // 버튼 크기 조절
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
                        color: _selectedDay == dayId
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
                  .get(GetOptions(source: Source.cache)),
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
                        itemCount: places.length, // 장소 수만큼 아이템 수 설정
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = places.removeAt(oldIndex);
                          places.insert(newIndex, item);
                          await _updatePlaceOrder(_selectedDay!, places);
                          setState(() {
                            _loadDayItinerary(_selectedDay!);
                          });
                        },
                        itemBuilder: (context, index) {
                          // 장소 타일
                          final placeDoc = places[index];
                          final place = placeDoc.data() as Map<String, dynamic>;
                          final geoPoint = place['location'] as GeoPoint;

                          return ListTile(
                            key: ValueKey(placeDoc.id), // 고유한 키 할당
                            leading: _isEditing
                                ? const Icon(Icons.menu)
                                : CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Text((index + 1).toString()),
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
                                      .doc(_selectedDay)
                                      .collection('places')
                                      .doc(placeDoc.id)
                                      .delete();

                                  await _updatePlaceOrder(_selectedDay!, places);
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
                  ],
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 90,
            right: 10,
            child: FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScheduling(
                      calendarId: widget.calendarId,
                      dayId: _selectedDay!,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.red, // 첫 번째 버튼의 색상
              child: const Icon(Icons.map), // 원하는 아이콘
            ),
          ),
          Positioned(
            bottom: 170,
            right: 10,
            child: FloatingActionButton(
              heroTag: "btn2",
              onPressed: _toggleOtherUsersRoutes,
              backgroundColor: Colors.green,
              child: const Icon(Icons.directions),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: "btn3",
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildCalendarDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            _calendarName ?? '여행 일정',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
              '${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : ''} ~ ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : ''}'),
        ],
      ),
    );
  }*/

  /*Widget _buildEditableCalendarDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: TextEditingController(text: _calendarName),
            onChanged: (value) {
              _calendarName = value;
            },
            decoration: const InputDecoration(
              labelText: '일정 이름',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _startDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _startDate = pickedDate;
                });
              }
            },
            child: Text(
              _startDate == null
                  ? '시작 날짜 선택'
                  : '시작 날짜: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _endDate = pickedDate;
                });
              }
            },
            child: Text(
              _endDate == null
                  ? '종료 날짜 선택'
                  : '종료 날짜: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
            ),
          ),
          TextButton(
            onPressed: () async {
              await _updateCalendarDetails();
              setState(() {
                _isEditingCalendarDetails = false;
                _loadDateList();
              });
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
} */
}

// 경로 가져오기
/*Future<List<LatLng>> _getRoute(LatLng origin, LatLng destination, String mode, String dayId) async {
    const apiKey = 'AIzaSyAyvveCFRA-uYPE5JqiYIgN_BLVNEtKFb4';
    final userId = FirebaseAuth.instance.currentUser?.uid; //유저 확인
    final List<LatLng> routeCoordinates = [];

    final routeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('calendars')
        .doc(widget.calendarId)
        .collection('dates')
        .doc(dayId) // 여기서 dayId가 실제로 날짜를 식별하도록 설정합니다.
        .collection('routes')
        .doc('${origin.latitude}_${origin.longitude}_${destination.latitude}_${destination.longitude}'); //경로 식별자

    //print('Firestore path: users/$userId/calendars/${widget.calendarId}/dates/$dayId/routes/${origin.latitude}_${origin.longitude}_${destination.latitude}_${destination.longitude}');

    // Firestore에서 경로 데이터 로드
    //print('Loading route for dayId: $dayId');
    //print('Firestore path: users/$userId/calendars/${widget.calendarId}/dates/$dayId/routes/${origin.latitude}_${origin.longitude}_${destination.latitude}_${destination.longitude}');
    final routeSnapshot = await routeRef.get();
    if (routeSnapshot.exists) {
      // 저장된 경로가 있는 경우
      final data = routeSnapshot.data()!;
      final encodedPolyline = data['polyline'] as String;
      routeCoordinates.addAll(_decodePolyline(encodedPolyline));
      return routeCoordinates;
    }
    //없으면 api 호출
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},'
          '${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$apiKey',
    );

    try {
      //print('Origin: ${origin.latitude}, ${origin.longitude}');
      //print('Destination: ${destination.latitude}, ${destination.longitude}');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final polylinePoints = data['routes'][0]['overview_polyline']['points'];
          routeCoordinates.addAll(_decodePolyline(polylinePoints));

          // Firestore에 경로 데이터 저장
          try {
            // Firestore에 경로 데이터 저장
            await routeRef.set({
              'polyline': polylinePoints,
              'timestamp': FieldValue.serverTimestamp(),
            });
            print('Route successfully saved to Firestore.');
          } catch (e) {
            print('Failed to save route: $e');
          }
        } else {
          print('No routes found');
          // 경로가 없을 때 직선 경로로 되돌리기
          setState(() {
            _polylineCoordinates = _defaultLineCoordinates;
          });
        }
      } else {
        print('Failed to fetch routes: ${response.statusCode}');
        // API 호출 실패 시 직선 경로로 되돌리기
        setState(() {
          _polylineCoordinates = _defaultLineCoordinates;
        });
      }
    } catch (e) {
      print('Error fetching routes: $e');
    }

    return routeCoordinates;
  }

  // 경로 업데이트 함수
  void _updateRoute(LatLng origin, LatLng destination, String mode, String dayId) async {
    List<LatLng> newApiRouteCoordinates = await _getRoute(origin, destination, mode, dayId);

    setState(() {
      // 기존의 _polylineCoordinates에서 현재 구간(origin, destination)에 해당하는 부분을 제거
      _polylineCoordinates.removeWhere((coord) =>
      (coord.latitude == origin.latitude && coord.longitude == origin.longitude) ||
          (coord.latitude == destination.latitude && coord.longitude == destination.longitude)
      );

      // 새로운 경로가 있으면 추가, 없으면 기본 경로 유지
      if (newApiRouteCoordinates.isNotEmpty) {
        _polylineCoordinates.addAll(newApiRouteCoordinates);
      } else {
        // 새로운 경로가 없는 경우 기본 직선 경로 유지
        _polylineCoordinates.addAll(_defaultLineCoordinates.where((coord) =>
        coord == origin || coord == destination
        ));
      }
    });
  }*/

