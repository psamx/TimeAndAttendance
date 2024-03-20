import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timeandattendanceapp/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeandattendanceapp/config.dart';
import 'package:http/http.dart' as http;

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final storage = const FlutterSecureStorage();
  final AppConfig _appConfig = AppConfig();
  String? sessionId;
  String? employeeCode;
  String? employeeName;
  String? status;
  String? address;
  double? weeklyHoursWorked;
  double? todayHoursWorked;
  double? breakHours;

  @override
  void initState() {
    super.initState();
    retrieveData();

  }

  Future<void> retrieveData() async {
    sessionId = await storage.read(key: 'sessionId');
    employeeCode = await storage.read(key: 'employeeCode');
    //setState(() {}); // Update the UI after retrieving data
    if (sessionId != null && employeeCode != null) {
      // Retrieve additional information from the server
      /*
      "SessionId": "{{SessionId}}",
      "EmployeeCode": "{{EmployeeCode}}",
      "DateTime": "{{URLdate}}{{URLtime}}"
      */
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

          final employeeName = responseData['employeeNameField'];
          final status = responseData['statusField'];
          final address = responseData['addressField'];
          final weeklyHoursWorked = responseData['weeklyHoursWorkedFromTAField'];
          final todayHoursWorked = responseData['todayHoursWorkedFromTAField'];
          final breakHours = responseData['breakField'];

          if(employeeName == null)
          {
            await storage.delete(key: 'sessionId');
            await storage.delete(key: 'employeeCode');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen())
            );
          }
          else
          {
            setState(() {
              this.employeeName = employeeName;
              this.status = status;
              this.address = address;
              this.weeklyHoursWorked = weeklyHoursWorked;
              this.todayHoursWorked = todayHoursWorked;
              this.breakHours = breakHours;
            });
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
        _showResponsePopup('Exception','Exception during Fetching Data: $e');
      }
    }
    else {
      print('Session ID or employee code is null');
      //Redirect to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen())
        );
    }
  }

  void _showResponsePopup(String popUpTitle,String popUpText) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(popUpTitle),
            content: Text(popUpText),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
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
                  _buildInfoRow('Employee Name:', employeeName ?? 'Not available'),
                  _buildInfoRow('Status:', status ?? 'Not available'),
                  _buildInfoRow('Address:', address ?? 'Not available'),
                  _buildInfoRow('Weekly Hours Worked:', weeklyHoursWorked.toString()),
                  _buildInfoRow('Today Hours Worked:', todayHoursWorked.toString()),
                  _buildInfoRow('Break Hours:', breakHours.toString()),
                  _buildInfoRow('Employee Code:', employeeCode ?? 'Not available'),
                ],
              ),
            ),
            
            ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Adjust the button's padding
                textStyle: const TextStyle(fontSize: 20), // Adjust the button's text size
              ),
                child: Text('Clock${status=='In'?'Out':'In'}'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0), // Spacer between label and value
        Text(
          value,
          style: const TextStyle(fontSize: 18.0),
        ),
        const Divider(), // Divider after each group of label-data
      ],
    );
  }
}
