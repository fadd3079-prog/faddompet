import 'package:flutter/material.dart';

void main() {
  runApp(const FaddompetApp());
}

class FaddompetApp extends StatelessWidget {
  const FaddompetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faddompet',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF7F7F8),
        appBar: AppBar(
          title: Text('Faddompet'),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'Faddompet berhasil jalan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
