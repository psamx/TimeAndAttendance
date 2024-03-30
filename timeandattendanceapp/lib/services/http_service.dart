import 'dart:convert';
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

  
}