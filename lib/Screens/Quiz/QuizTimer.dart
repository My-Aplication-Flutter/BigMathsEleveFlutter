import 'dart:async';
import 'package:flutter/material.dart';
import '../../Data/dataQuestions.dart';
import 'ResultScreenQuizTimer.dart';

class QuizTimerScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizTimerScreen> {
  int currentIndex = 0;
  int score = 0;
  int timeLeft = 1800; // 30 minutes
  Timer? timer;
  List<int?> userAnswers = [];

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(questions.length, null);
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        finishQuiz();
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void selectAnswer(int index) {
    setState(() {
      userAnswers[currentIndex] = index;
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void finishQuiz() {
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctIndex) {
        score++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(score: score),
      ),
    );
  }

  String formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Test Sésame"),
        actions: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: Text(formatTime(timeLeft))),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(q.question, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ...List.generate(q.options.length, (i) {
              return RadioListTile<int>(
                title: Text(q.options[i]),
                value: i,
                groupValue: userAnswers[currentIndex],
                onChanged: (val) => selectAnswer(val!),
              );
            }),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: prevQuestion,
                  child: Text("Précédent"),
                ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text("Suivant"),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: finishQuiz,
              child: Text("Terminer"),
            )
          ],
        ),
      ),
    );
  }
}
