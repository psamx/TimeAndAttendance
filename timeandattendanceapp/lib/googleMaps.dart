import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const GoogleMaps());

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(34.757722, 32.464493);
  final List<Marker> markers = [];


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Google Maps'), backgroundColor: Colors.blue[700]),
        
        body: SizedBox(
  height: 500,
  child: Stack(
    children: [
      GoogleMap(
        padding: const EdgeInsets.only(bottom: 16.0),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 17.0,
        ),
        markers: markers.toSet(), // Use the state variable to hold markers
        onTap: (LatLng latLng) {
          // Add marker on tap
          setState(() {
            markers.clear();
            markers.add(
              Marker(
                markerId: MarkerId(latLng.toString()), // Generate unique ID based on tap location
                position: latLng,
                infoWindow: const InfoWindow(title: 'New Marker'),
              ),
            );
          });
        },
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
      ),
      Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: LatLng(34.69852694203089, 33.04781002476253),
                      zoom: 17.0,
                    ),
                  ),
                );
              },
              child: const Text('Office', style: TextStyle(fontSize: 20,color: Colors.red,fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10), // Add a gap between the buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: markers.isNotEmpty ? () {
                final lat = markers[0].position.latitude;
                final long = markers[0].position.longitude;
                final targetLatLng = LatLng(lat, long);

                final cameraPosition = CameraPosition(
                  target: targetLatLng,
                  zoom: 17.0,
                );

                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition),
                );
              } : null,
              child: const Text('Home', style: TextStyle(fontSize: 20,color: Colors.red,fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
          ],
        ),
        )
      )
    );
  }
}