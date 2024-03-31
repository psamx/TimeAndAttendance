import 'package:flutter/material.dart';
import 'package:TimeAndAttendance/models/location_model.dart';

class LocationDropdownWidget extends StatelessWidget {
  final List<Location> locations;
  final Location? selectedLocation;
  final void Function(Location?) onChanged;

  const LocationDropdownWidget({
    required this.locations,
    required this.selectedLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Location>(
      value: selectedLocation,
      hint: const Text("Select location"),
      items: locations.map<DropdownMenuItem<Location>>((Location location) {
        return DropdownMenuItem<Location>(
          value: location,
          child: Text(location.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
