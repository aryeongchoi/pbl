import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_place_screen.dart';

class Calendar extends StatefulWidget {

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CameraPosition _initCameraPosition = const CameraPosition(
  );

  GoogleMapController? _googleMapController;
  List<LatLng> _polylineCoordinates = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
  }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
          .collection('users')
          .doc(userId)
        setState(() {
        });
    }
  }

      Set<Marker> markers = {};
      List<LatLng> polylineCoordinates = [];

        final geoPoint = data['location'] as GeoPoint;
        final latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        markers.add(Marker(
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));

        polylineCoordinates.add(latLng);
      }

      setState(() {
        _markers = markers;
        _polylineCoordinates = polylineCoordinates;
      });
  }

    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
      ),
    );
  }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
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
        children: [
          Expanded(
            flex: 1,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              initialCameraPosition: _initCameraPosition,
              onMapCreated: (controller) {
                _googleMapController = controller;
              },
              markers: _markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  width: 3,
                  patterns: const [PatternItem.dot],
                  points: _polylineCoordinates,
                ),
              },
            ),
          ),
          Expanded(
            flex: 1,
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            setState(() {
                            });
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
                                        ),
                                        TextButton(
                                          child: const Text("삭제"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm) {
                                  }
                                },
                              )
                                  : null,
                            );
                    ),
                      onPressed: () {
                        Navigator.push(
                          context,
                        );
        },
        tooltip: "일정 추가",
        child: const Icon(Icons.add),
      ),
    );
  }
}
