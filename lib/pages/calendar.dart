import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_place_screen.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CameraPosition _initCameraPosition = const CameraPosition(
    target: LatLng(37.773972, -122.131297), // 초기 위치
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;
  Set<Marker> _markers = {}; //마커 저장 리스트
  List<DocumentSnapshot> _itineraries = []; //장소 리스트
  List<LatLng> _polylineCoordinates = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserItinerary();
  }

  void _loadUserItinerary() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('itineraries')
          .orderBy('order')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _itineraries = snapshot.docs;
          _updateMarkersAndPolylines(_itineraries);
        });
      });
    }
  }

  void _updateMarkersAndPolylines(List<DocumentSnapshot> docs) { //마커 장소 업데이트
    Set<Marker> markers = {};
    List<LatLng> polylineCoordinates = [];

    for (int i = 0; i < docs.length; i++) {
      final data = docs[i].data() as Map<String, dynamic>;
      final geoPoint = data['location'] as GeoPoint;
      final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

      markers.add(Marker(
        markerId: MarkerId(docs[i].id),
        position: latLng,
        infoWindow: InfoWindow(title: '${i + 1}. ${data['name']}'), // 이부분 추후에 수정, 커스텀 마커 사용할것
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));

      polylineCoordinates.add(latLng);
    }

    void updateSelectedPlaces(List<DocumentSnapshot> docs) { // _selectedplaces를 불러와 업데이트

    }

    setState(() {
      _markers = markers;
      _polylineCoordinates = polylineCoordinates;
      _itineraries = docs;
    });
  }

  void _moveCameraToFirstItinerary(DocumentSnapshot firstItinerary) { //카메라 위치 첫 장소로 이동
    final data = firstItinerary.data() as Map<String, dynamic>;
    final geoPoint = data['location'] as GeoPoint;
    final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 14.0),
      ),
    );
  }

  Future<void> _deletePlaceFromFirestore(String documentId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('itineraries')
          .doc(documentId)
          .delete();
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
        title: const Text("여행 일정"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // 편집 모드가 끝났을 때 마커 순서 업데이트
                  _updateMarkersAndPolylines(_itineraries);
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: GoogleMap(
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true, //true로 변경
                  initialCameraPosition: _initCameraPosition,
                  onMapCreated: (controller) {
                    _googleMapController = controller;
                    if (_itineraries.isNotEmpty) {
                      _moveCameraToFirstItinerary(_itineraries.first);
                    }
                  },
                  markers: _markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      color: Colors.blue, // 지누색으로 변경 243 167 172
                      width: 3,
                      patterns: const [PatternItem.dot],
                      points: _polylineCoordinates,
                    ),
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: ReorderableListView(
                  buildDefaultDragHandles: _isEditing,  // 드래그 핸들을 편집 모드에서만 표시
                  onReorder: _isEditing ? (oldIndex, newIndex) {  // 편집 모드에서만 순서 변경 가능
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    setState(() {
                      final item = _itineraries.removeAt(oldIndex);
                      _itineraries.insert(newIndex, item);
                      _updateMarkersAndPolylines(_itineraries);
                      _loadUserItinerary();
                    });
                  } : (oldIndex, newIndex) {}, // 편집 모드가 아닐 때는 순서 변경 불가
                  children: _itineraries.map((doc) {
                    final itinerary = doc.data() as Map<String, dynamic>; //geopoint
                    final documentId = doc.id;
                    return ListTile( // 일정 표시하는 부분, geopoint 안나오게 후처리하고, 리스트에서 거꾸로 표시할것
                      key: ValueKey(documentId),
                      title: Text(itinerary['name']),
                      //subtitle: Text(itinerary['location'].toString()),
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
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text("삭제"),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (confirm) {
                            await _deletePlaceFromFirestore(documentId);
                            setState(() {
                              _itineraries.remove(doc);
                              _updateMarkersAndPolylines(_itineraries);
                              _loadUserItinerary();
                            });
                          }
                        },
                      )
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
                );
              },
              tooltip: "일정 추가",
              child: const Icon(Icons.add),
            ),
          ),
          /*Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              tooltip: "편집",
              child: Icon(_isEditing ? Icons.done : Icons.edit),
            ),
          ),*/
        ],
      ),
    );
  }
}
