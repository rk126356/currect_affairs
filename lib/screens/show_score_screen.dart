import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/screens/play_quiz_screen.dart';
import 'package:flutter/material.dart';

class ShowScoreScreen extends StatelessWidget {
  final int score;
  final int totalSecondsTaken;
  final int totalQuestions;
  final QuizModel quizData;

  const ShowScoreScreen({
    Key? key,
    required this.score,
    required this.totalSecondsTaken,
    required this.totalQuestions,
    required this.quizData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Your Score',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$score/$totalQuestions',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Seconds Taken: $totalSecondsTaken',
              style: const TextStyle(
                color: AppColors.secondaryColor,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PlayQuizScreen(
                      quizData: quizData,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Take Again...',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
