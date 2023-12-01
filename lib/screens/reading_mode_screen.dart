import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/providers/quiz_language_provider.dart';
import 'package:currect_affairs/utils/language_selector.dart';
import 'package:currect_affairs/widgets/reading_questions_widget.dart';
import 'package:flutter/material.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:provider/provider.dart'; // Import your QuizModel

class ReadingModeScreen extends StatefulWidget {
  final QuizModel quizData;

  const ReadingModeScreen({Key? key, required this.quizData}) : super(key: key);

  @override
  State<ReadingModeScreen> createState() => _ReadingModeScreenState();
}

class _ReadingModeScreenState extends State<ReadingModeScreen> {
  @override
  Widget build(BuildContext context) {
    final qLanguage = Provider.of<QuestionsLanguageProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                openLanguagePickerDialog(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Colors.white,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    qLanguage.languageName == 'None'
                        ? 'Translate'
                        : '${qLanguage.languageName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )),
        ],
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.quizData.quizTitle!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${widget.quizData.quizTitle}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Number of Questions: ${widget.quizData.noOfQuestions}'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.quizData.quizzes!.length,
                itemBuilder: (context, index) {
                  final quizData = widget.quizData.quizzes![index];
                  return ReadingModeQuestionsWidget(
                    quizData: quizData,
                    index: 'Question ${index + 1}:',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
