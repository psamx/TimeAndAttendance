import 'package:TimeAndAttendance/services/http_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final HttpService _httpService = HttpService();
  String? _selectedEntity; // Variable to hold the selected entity
  final List<String> _entities = ['Abacus','Grant Thornton','Hyperion Systems Engineering','Green Dot', 'PwC','Windsor Brokers']; // Example entities

  dynamic _isObscure;
  
  @override
  void initState() {
    super.initState();
    _isObscure = true;
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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.blue
              ),
              onPressed: () {
                _httpService.login(
                  context,
                  _usernameController.text,
                  _passwordController.text,
                  _selectedEntity,
                );
              },
              child: const Text('Login',
              style: TextStyle(
                fontSize:  16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
