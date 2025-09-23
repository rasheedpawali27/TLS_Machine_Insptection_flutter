import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectionTestScreen extends StatefulWidget {
  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _status = 'Testing...';
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing connection...';
    });

    try {
      final url = 'https://10.12.8.245:8080/api/account/login';
      print('🔄 Testing connection to: $url');

      final response = await http.get(
        Uri.parse(url),
      ).timeout(Duration(seconds: 10));

      print('✅ Response status: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');

      setState(() {
        _status = '✅ SUCCESS: Server is reachable!\nStatus: ${response.statusCode}';
      });
    } catch (e) {
      print('❌ Connection error: $e');
      setState(() {
        _status = '❌ ERROR: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connection Test')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Server: https://10.12.8.245:8080',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _status,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTesting ? null : _testConnection,
              child: _isTesting
                  ? CircularProgressIndicator()
                  : Text('Test Connection'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}