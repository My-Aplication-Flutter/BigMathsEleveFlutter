import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Data/dataQuestions.dart';
import 'ResultScreenPro.dart';

class QuizScreenPro extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreenPro> {
  int currentIndex = 0;
  int timeLeft = 1800;
  Timer? timer;
  List<int?> answers = [];

  @override
  void initState() {
    super.initState();
    answers = List.filled(questions.length, null);
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft == 0) finishQuiz();
      setState(() => timeLeft--);
    });
  }

  void selectAnswer(int i) {
    setState(() => answers[currentIndex] = i);
  }

  void next() {
    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void finishQuiz() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) score++;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(score: score),
      ),
    );
  }

  String formatTime() {
    int m = timeLeft ~/ 60;
    int s = timeLeft % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Test Sésame",
            style: GoogleFonts.poppins(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            /// Progress bar
            LinearPercentIndicator(
              percent: (currentIndex + 1) / questions.length,
              lineHeight: 8,
              barRadius: Radius.circular(20),
              progressColor: Color(0xFF4A6CF7),
              backgroundColor: Colors.grey.shade300,
            ).animate().fade(),

            SizedBox(height: 10),

            /// Timer
            Text(
              formatTime(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ).animate().scale(),

            SizedBox(height: 20),

            /// Question Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Question ${currentIndex + 1}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    q.question,
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.3),

            SizedBox(height: 20),

            /// Answers
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (context, i) {
                  bool selected = answers[currentIndex] == i;

                  return GestureDetector(
                    onTap: () => selectAnswer(i),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected ? Color(0xFF4A6CF7) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Text(
                        q.options[i],
                        style: GoogleFonts.poppins(
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ).animate().fade().scale(),
                  );
                },
              ),
            ),

            /// Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0
                      ? () => setState(() => currentIndex--)
                      : null,
                  child: Text("Retour"),
                ),
                ElevatedButton(
                  onPressed: next,
                  child: Text("Suivant"),
                ),
              ],
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: finishQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Terminer"),
            )
          ],
        ),
      ),
    );
  }
}
