import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/information_screen.dart';
import 'services/storage_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time and Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SessionCheckScreen(),
    );
  }
}

class SessionCheckScreen extends StatefulWidget {
  const SessionCheckScreen({super.key});

  @override
  _SessionCheckScreenState createState() => _SessionCheckScreenState();
}

class _SessionCheckScreenState extends State<SessionCheckScreen> { 
  final StorageService _storageService = StorageService();


  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    String? sessionId;

    bool keyExists = await _storageService.containsKey('sessionId');
    if (keyExists) {
        sessionId = await _storageService.readData('sessionId');
    } else {
        print('Key "sessionId" does not exist in storage.');
    }

    if (sessionId != null && sessionId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InformationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can display a loading spinner or splash screen while checking the session
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
