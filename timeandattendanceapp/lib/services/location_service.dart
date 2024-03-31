// location_service.dart

import 'dart:convert';
import 'package:TimeAndAttendance/models/location_model.dart';
import 'package:TimeAndAttendance/services/storage_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final _storageService = StorageService();

  Future<List<Location>> loadLocations() async {
    final String? locationsJson = await _storageService.readData('locations');
    final List<Location> locations = [];

    if (locationsJson != null) {
      final Map<String, dynamic> locationsMap = jsonDecode(locationsJson);
      locations.addAll(locationsMap.entries.map((entry) {
        final name = entry.key;
        final locationData = entry.value as Map<String, dynamic>;
        final longitude = locationData['longitude'] as double;
        final latitude = locationData['latitude'] as double;
        return Location(name: name, longitude: longitude, latitude: latitude);
      }));
    } else {
      locations.add(Location(name: 'WORK', longitude: 33.0480134, latitude: 34.6987503));
      saveLocations(locations);
    }
    return locations;
  }

  Future<void> saveLocations(List<Location> locations) async {
    final Map<String, Map<String, dynamic>> serializedLocations = {};
    locations.forEach((location) {
              serializedLocations[location.name] = {
                'longitude': location.longitude,
                'latitude': location.latitude,
              };
            });
    await _storageService.saveData('locations',jsonEncode(serializedLocations));
  }

  // Method to get the current device location
  Future<Position?> getCurrentLocation() async {
    try {
      // Request permission to access location
      LocationPermission permission = await Geolocator.requestPermission();

      // If permission is granted, get the current position
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        return position;
      } else {
        // Handle case where permission is denied
        print('Location permission not granted');
        return null;
      }
    } catch (e) {
      // Handle exceptions
      print('Error getting location: $e');
      return null;
    }
  }

}
