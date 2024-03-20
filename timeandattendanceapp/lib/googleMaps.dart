import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const GoogleMaps());

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}


class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  LatLng? _positionNew;
  bool _isLoading = true;
  final LatLng _center = const LatLng(34.757722, 32.464493);
  final List<Marker> markers = [];
  final textController = TextEditingController();
  bool _validate = false; 

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
    getLocation() async {
      print(_isLoading);
      LocationPermission permission;
      permission = await Geolocator.requestPermission();

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double long = position.longitude;

      LatLng location = LatLng(lat, long);

      setState(() {
        _currentPosition = location;
        _positionNew = location;
        print(_currentPosition);
        _isLoading = false;
      });
      print(_isLoading);
    }
  
  @override
  void initState() {
    getLocation();
  }
  
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
        
        body: _isLoading ?  const Center(child: CircularProgressIndicator()) : Column(
    children: [
      Expanded(flex:3, child: Container(child: GoogleMap(
        padding: const EdgeInsets.only(bottom: 16.0),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition != null ? _currentPosition! : _center,
          zoom: 17.0,
        ),
        markers: markers.toSet(), // Use the state variable to hold markers
        onTap: (LatLng latLng) {
          // Add marker on tap
          setState(() {
            markers.clear();
            _positionNew = latLng;
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
      )
      ),
      _buildInfoRow("Current Latitude", _positionNew!.latitude.toString()),
      _buildInfoRow("Current Longtitude", _positionNew!.longitude.toString()),
      Expanded(flex: 1,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              labelText: 'Location',
              errorText: _validate ? 'Please enter location name!' : null,
              errorStyle: const TextStyle(fontSize: 15.0, color: Colors.red),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              hintText: 'Enter Location Name!!',
            ),
          ),
        ),
        ),
        Expanded(flex: 1,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  
                ),
                backgroundColor: Colors.blue
              ),
            onPressed: () {
              setState(() {
                textController.text.isEmpty ? _validate= true: _validate = false;
              });
              print('save functionality');
              print('current position: $_positionNew'); 
              print('location name: ${textController.text}');
            },
            child: const Text(
              'Save Location',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              ),
          )
        )),
 
          ],
        ),
      ) 
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10.0),
          Text(value),
        ],
      ),
    );
  }
  
}

     /*Align(
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
    ),*/