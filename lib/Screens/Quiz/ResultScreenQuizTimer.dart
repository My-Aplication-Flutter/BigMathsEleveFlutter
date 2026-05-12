import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;

  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Résultat")),
      body: Center(
        child: Text(
          "Score: $score",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
