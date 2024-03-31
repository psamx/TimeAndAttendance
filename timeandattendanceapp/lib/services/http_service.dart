import 'dart:convert';
import 'package:TimeAndAttendance/models/attendancestatus_model.dart';
import 'package:TimeAndAttendance/models/location_model.dart';
import 'package:TimeAndAttendance/screens/information_screen.dart';
import 'package:TimeAndAttendance/services/popup_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:TimeAndAttendance/screens/login_screen.dart';
import 'package:TimeAndAttendance/config/config.dart';
import 'package:TimeAndAttendance/services/storage_service.dart';

class HttpService {
  final AppConfig _appConfig = AppConfig();
  final StorageService _storageService = StorageService();

  Future<void> login(BuildContext context, String username, String password, String? entity) async {
    if (entity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an entity.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'entity': entity,
    };

    final String apiUrl = _appConfig.apiUrl;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final sessionId = responseData['SessionId'];
        final employeeCode = responseData['employeeCodeField'];

        await _storageService.saveData('sessionId',sessionId);
        await _storageService.saveData('employeeCode',employeeCode);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InformationScreen()),
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      PopupService.showResponsePopup(context, 'Exception', 'Exception during login: $e');
    }
  }

  Future<AttendanceStatus?> retrieveData(BuildContext context) async {
    final sessionId = await _storageService.readData('sessionId');
    final employeeCode = await _storageService.readData('employeeCode');

    if (sessionId == null || employeeCode == null) {
      print('Session ID or employee code is null');
      //Redirect to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen())
        );
    }
    else{

      final Map<String, dynamic> data = {
      'SessionId': sessionId,
      'EmployeeCode': employeeCode,
      'DateTime': DateTime.now().toIso8601String(),
      };
      
      final String apiUrl ='${_appConfig.apiUrl}GetEmployeeAttendanceStatus';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(data),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        
        if (response.statusCode == 200) {
          // Authentication successful
          //_showResponsePopup('Response',response.body);
          final responseData = jsonDecode(response.body);
          AttendanceStatus attendanceStatus = AttendanceStatus(
            employeeName: responseData['employeeNameField'],
            status: responseData['statusField'],
            address: responseData['addressField'],
            weeklyHoursWorked: responseData['weeklyHoursWorkedFromTAField'],
            todayHoursWorked: responseData['todayHoursWorkedFromTAField'],
            breakHours: responseData['breakField']
          ); 

          if (attendanceStatus.status == 'In')
          {
            attendanceStatus.longitude = responseData['longitudeField'];
            attendanceStatus.latitude = responseData['latitudeField'];
          }
          
          if(attendanceStatus.employeeName == null)
          {
            await _storageService.deleteData('sessionId');
            await _storageService.deleteData('employeeCode');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen())
            );
          }
          else
          {
            return attendanceStatus;
          }
        } 
        else {
          // Authentication failed
          // Display an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle exceptions
        PopupService.showResponsePopup(context,'Exception','Exception during Fetching Data: $e');
      }
    }
    return null;
  } 

  Future<AttendanceStatus?> updateStatus(BuildContext context, String? status, Location? selectedLocation,String? longitude,String? latitude) async {
    final String newStatus = status == 'In' ? 'Out' : 'In';
    final bool isLocationRequired = newStatus == 'In' && selectedLocation == null;
    if (isLocationRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
    
    final sessionId = await _storageService.readData('sessionId');
    final employeeCode = await _storageService.readData('employeeCode');
    if (sessionId == null || employeeCode == null) {
      print('Session ID or employee code is null');
      //Redirect to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen())
        );
    }
    else{

      final Map<String, dynamic> data = {
      'SessionId': sessionId,
      'EmployeeCode': employeeCode,
      'DateTime': DateTime.now().toIso8601String(),
      'AttendanceStatus': newStatus,
      "Latitude": selectedLocation?.latitude??latitude,
      "Longitude": selectedLocation?.longitude??longitude,
      };
      
      final String apiUrl ='${_appConfig.apiUrl}UpdateAttendanceStatus';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: jsonEncode(data),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (response.statusCode == 200) {
          // Authentication successful
          //_showResponsePopup('Response',response.body);
          final responseData = jsonDecode(response.body);
          AttendanceStatus attendanceStatus = AttendanceStatus(
            //employeeName: responseData['employeeNameField'],
            status: responseData['statusField'],
            address: responseData['addressField'],
            weeklyHoursWorked: responseData['weeklyHoursWorkedFromTAField'],
            todayHoursWorked: responseData['todayHoursWorkedFromTAField'],
            breakHours: responseData['breakField']
          ); 

          if (attendanceStatus.status == 'In')
          {
            attendanceStatus.longitude = responseData['longitudeField'];
            attendanceStatus.latitude = responseData['latitudeField'];
          }

          return attendanceStatus;

        } 
        else {
          // Authentication failed
          // Display an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle exceptions
        PopupService.showResponsePopup(context,'Exception','Exception during Fetching Data: $e');
      }
    }
    return null;
  } 
}