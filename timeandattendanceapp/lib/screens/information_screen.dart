import 'package:TimeAndAttendance/screens/googlemaps_screen.dart';
import 'package:TimeAndAttendance/services/http_service.dart';
import 'package:TimeAndAttendance/services/location_service.dart';
import 'package:TimeAndAttendance/services/popup_service.dart';
import 'package:TimeAndAttendance/widget/conditionalinforow_widget.dart';
import 'package:TimeAndAttendance/widget/inforow_widget.dart';
import 'package:TimeAndAttendance/widget/locationDropdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:TimeAndAttendance/models/location_model.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final LocationService _locationService = LocationService();
  final HttpService _httpService = HttpService();

  String? sessionId;
  String? employeeCode;
  String? employeeName;
  String? status;
  String? address;
  String? latitude;
  String? longitude; 
  double? weeklyHoursWorked;
  double? todayHoursWorked;
  double? breakHours;
  List<Location> locations = [];
  Location? selectedLocation;

  @override
  void initState() {
    super.initState();
    retrieveData();
    loadLocations();
  }

  Future<void> retrieveData() async {
    await _httpService.retrieveData(context).then((value){
      if(value != null)
      {
        setState(() {
          employeeName = value.employeeName;
          status = value.status;
          address = value.address;
          weeklyHoursWorked = value.weeklyHoursWorked;
          todayHoursWorked = value.todayHoursWorked;
          breakHours = value.breakHours;
          longitude = value.longitude;
          latitude = value.latitude;
        });
      }
    }); 
    //print the above values on the console
    }

  Future<void> loadLocations() async {
    locations = await _locationService.loadLocations();
    // Add an extra option for navigating to a new screen
    locations.add(Location(name: 'Add New Location', longitude: 0.0, latitude: 0.0));
  }

  Future<void> _updateStatus() async {
    _httpService.updateStatus(
      context,
      status,
      selectedLocation,
      longitude,
      latitude 
      ).then((value) {
        if(value != null)
        {
          setState(() {
            print('Old status: $status');
            status = value.status;
            address = value.address;
            weeklyHoursWorked = value.weeklyHoursWorked;
            todayHoursWorked = value.todayHoursWorked;
            breakHours = value.breakHours;
            longitude = value.longitude;
            latitude = value.latitude;
            print('New status: $status');
          });
        }
      });
  }


  
  @override
  Widget build(BuildContext context) {
    if(employeeName == null)
    {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Information Screen'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    //Todo: Add lebels infront of the texts to make it more readable on an additional column
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  InfoRow(label: 'Employee Name:',value:  employeeName ?? 'Not available'),
                  ConditionalInfoRow(label: 'Status:',value: status ?? 'Not available',condition: status == 'In'),
                  InfoRow(label: 'Address:',value: address ?? 'Not available'),
                  InfoRow(label: 'Weekly Hours Worked:',value: weeklyHoursWorked.toString()),
                  InfoRow(label: 'Today Hours Worked:',value: todayHoursWorked.toString()),
                  InfoRow(label: 'Break Hours:',value: breakHours.toString()),
                  InfoRow(label: 'Employee Code:',value: employeeCode ?? 'Not available'),
                ],
              ),
            ),
            //If longitude and latitude fields are null add a drop down field with values from storage key locations and an extra value that will navigate to a new screen
            status != 'In' && longitude == null && latitude == null ? 
            LocationDropdownWidget(
                  locations: locations,
                  selectedLocation: selectedLocation,
                  onChanged: (Location? value) {
                    if (value != null && value.name == 'Add New Location') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const GoogleMaps()),
                      );
                    } else {
                      setState(() {
                        selectedLocation = value;
                      });
                    }
                  },
                )
             : Container(),
            //_buildLocationDropdown(),
            ElevatedButton(
              onPressed: () {
                PopupService.showConfirmationPopup(context,"Update Status", "Are you sure you want to Clock${status == 'In' ? 'Out' : 'In'}?", _updateStatus);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.blue
              ),
              child: Text(
                  'Clock${status == 'In'?'Out':'In'}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}