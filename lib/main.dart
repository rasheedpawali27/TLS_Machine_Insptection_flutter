import 'package:flutter/material.dart';
import 'package:tls_inspection_machine/screens/Login_screen.dart';
import 'package:tls_inspection_machine/screens/SplashScreens.dart';
import 'package:tls_inspection_machine/screens/Inline_inspection_dashboard_screen.dart';
import 'package:tls_inspection_machine/screens/machine_status_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interloop Denim TLS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const MachineStatusScreen(),

      },
      debugShowCheckedModeBanner: false,
    );
  }
}