import 'package:flutter/material.dart';
import 'package:moriarty_chess_engine/screens/home.dart';


void main() {
  runApp(const Moriarty());
}

class Moriarty extends StatelessWidget {
  const Moriarty({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moriarty Chess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LandingScreen(),
    );
  }
}
