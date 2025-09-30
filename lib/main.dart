import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/screens/login_screen.dart';
import 'package:tls_inspection_machine/screens/demo.dart';
import 'package:tls_inspection_machine/screens/machine_status_screen.dart';
import 'package:tls_inspection_machine/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLS Inspection Machine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AppWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();

    setState(() {
      _isLoggedIn = loggedIn;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Checking authentication...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const MachineStatusScreen() : const LoginScreen();
  }
}
