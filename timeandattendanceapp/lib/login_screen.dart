import 'package:flutter/material.dart';
import 'package:timeandattendanceapp/information_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timeandattendanceapp/config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _entityController = TextEditingController();
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
    final String entity = _entityController.text;

    //store data in local storage
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
    await storage.write(key: 'entity', value: entity);

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
            TextField(
              controller: _entityController,
              decoration: const InputDecoration(labelText: 'Entity'),
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
  
  Future<void> checkSession() async{
    String? username;
    String? password;
    String? entity;
    bool usernameExists = await storage.containsKey(key: 'username');
    bool passwordExists = await storage.containsKey(key: 'password');
    bool entityExists = await storage.containsKey(key: 'entity');
    if (usernameExists){
      username = storage.read(key: 'username') as String;
      _usernameController.text = username;
    } 
    if (passwordExists){
      password = storage.read(key: 'password') as String;
      _passwordController.text = password;
    }
    if (entityExists){
      entity = storage.read(key: 'entity') as String;
      _entityController.text = entity;
    }
    setState(() {});
  }
}
