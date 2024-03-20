import 'package:flutter/material.dart';
import 'package:TimeAndAttendance/information_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:TimeAndAttendance/config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedEntity; // Variable to hold the selected entity
  final List<String> _entities = ['Windsor Brokers']; // Example entities

  final AppConfig _appConfig = AppConfig();
  //if data exists in local storage, fill the text fields with the data
  var _isObscure;
  final storage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    _isObscure = true;
    checkSession();
  } 

  Future<void> _login() async {

    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String? entity = _selectedEntity; // Use the selected entity

    if (entity == null) {
    // Handle the case where the entity is not selected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select an entity.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
    // Create a JSON object with the user input
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
        // Authentication successful
        //_showResponsePopup('Response',response.body);
        final responseData = jsonDecode(response.body);
        final sessionId = responseData['SessionId'];
        final employeeCode = responseData['employeeCodeField'];

        // Save the session ID and employee code
        // TODO: Implement your saving logic here
        // For now, print the session ID and employee code  to the console
        print('Session ID: $sessionId');
        print('Employee code: $employeeCode');
        // Now store the values in local storage in order to use them in the next screens and on app restart

        await storage.write(key: 'sessionId', value: sessionId);
        await storage.write(key: 'employeeCode', value: employeeCode);

        // Navigate to the information screen
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InformationScreen())
        );
        
      } else {
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
      _showResponsePopup('Exception','Exception during login: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username')
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: _isObscure? const Icon(Icons.visibility_off):  const Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
                ),
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField<String>(
              value: _selectedEntity,
              decoration: const InputDecoration(labelText: 'Entity'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEntity = newValue;
                });
              },
              items: _entities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> checkSession() async {
    // No need to declare these variables at the beginning
    // String? username;
    // String? password;
    // String? entity;

    bool usernameExists = await storage.containsKey(key: 'username');
    bool passwordExists = await storage.containsKey(key: 'password');

    if (usernameExists) {
      String? username = await storage.read(key: 'username');
      if (username != null) { // Always check for null when dealing with async operations
        _usernameController.text = username;
      }
    }
    if (passwordExists) {
      String? password = await storage.read(key: 'password');
      if (password != null) {
        _passwordController.text = password;
      }
    }
    String? entity = await storage.read(key: 'entity');
    if (entity != null && _entities.contains(entity)) { // Ensure the read entity is in your list
    setState(() {
      _selectedEntity = entity;
    });
  }
    
    setState(() {});
  }

}
