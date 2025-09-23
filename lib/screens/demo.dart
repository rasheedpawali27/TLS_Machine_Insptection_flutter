import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Successfullly"),
      ),
      body: Container(
        child: Center(
          child: Text("Login Successfullly"),
        ),
      ),
    );
  }
}
