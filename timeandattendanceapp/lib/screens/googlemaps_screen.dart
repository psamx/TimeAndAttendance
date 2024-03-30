import 'package:TimeAndAttendance/services/location_service.dart';
import 'package:TimeAndAttendance/widget/inforow_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:TimeAndAttendance/screens/information_screen.dart';
import 'package:TimeAndAttendance/models/location_model.dart';

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
  final textController = TextEditingController();
  final LocationService _locationService = LocationService();
  LatLng? _currentPosition;
  LatLng? _positionNew;
  bool _isLoading = true;
  bool _validate = false; 
  List<Location> locations = [];
  
  
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  
  @override
  void initState() {
    super.initState();
    getLocation();
    _locationService.loadLocations().then((value) {
      setState(() {
        locations = value;
      });
    });
  }

  Future<void> getLocation() async {
      Position? position = await _locationService.getCurrentLocation();
      LatLng location = LatLng(position!.latitude, position.longitude);
      setState(() {
          _currentPosition = location;
          _positionNew = location;
          _isLoading = false;
        });
  }

  //Create a function to add a new location to the list
  void _addLocation() {
    if (textController.text.isEmpty) {
      setState(() {
        _validate = true;
      });
    } else {
      setState(() {
        _validate = false;
      });
      final newLocation = Location(
        name: textController.text,
        longitude: _positionNew!.longitude,
        latitude: _positionNew!.latitude,
      );
      
      locations.add(newLocation);
      _locationService.saveLocations(locations).then((_) {
        // Add a delay of 1 second before navigating
        Future.delayed(const Duration(seconds: 1), () {
          // Navigate to the InformationScreen and replace the current screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => InformationScreen()),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      InfoRow(label:"Current Latitude", value: _currentPosition!.latitude.toString()),
      InfoRow(label:"Current Longtitude",value:  _positionNew!.longitude.toString()),
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
              _addLocation();
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
}