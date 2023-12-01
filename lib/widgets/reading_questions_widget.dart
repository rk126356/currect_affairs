import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/providers/quiz_language_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

class ReadingModeQuestionsWidget extends StatefulWidget {
  const ReadingModeQuestionsWidget({
    Key? key,
    required this.quizData,
    required this.index,
  }) : super(key: key);

  final Questions quizData;
  final String index;

  @override
  State<ReadingModeQuestionsWidget> createState() =>
      _ReadingModeQuestionsWidgetState();
}

class _ReadingModeQuestionsWidgetState
    extends State<ReadingModeQuestionsWidget> {
  String? trQuestion;
  List<String> trChoices = [];
  String? trCorrectAnswer;
  String? trExplanation;

  void translateQ() async {
    final qLanguage =
        Provider.of<QuestionsLanguageProvider>(context, listen: false);
    final translator = GoogleTranslator();

    if (qLanguage.languageName != 'None') {
      translator
          .translate(widget.quizData.questionTitle!,
              from: 'auto', to: qLanguage.language)
          .then((s) {
        setState(() {
          trQuestion = s.toString();
        });
      });
      translator
          .translate(widget.quizData.explanation!,
              from: 'auto', to: qLanguage.language)
          .then((s) {
        setState(() {
          trExplanation = s.toString();
        });
      });
      translator
          .translate(
              widget.quizData.choices![widget.quizData.correctAnsIndex!]!,
              from: 'auto',
              to: qLanguage.language)
          .then((s) {
        setState(() {
          trCorrectAnswer = s.toString();
        });
      });
      for (final c in widget.quizData.choices!) {
        translator
            .translate(c!, from: 'auto', to: qLanguage.language)
            .then((s) {
          setState(() {
            trChoices.add(s.toString());
          });
        });
      }
    } else {
      trQuestion = null;
      trChoices = [];
      trCorrectAnswer = null;
      trExplanation = null;
    }
    if (kDebugMode) {
      print('Translated');
    }
  }

  @override
  void initState() {
    super.initState();
    translateQ();
  }

  @override
  Widget build(BuildContext context) {
    final qLanguage = Provider.of<QuestionsLanguageProvider>(context);
    if (qLanguage.reload) {
      translateQ();
    }
    return Card(
      color: AppColors.primaryColor,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.index,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    // Use the translated question title if available, otherwise use the original
                    trQuestion != null
                        ? trQuestion!
                        : '${widget.quizData.questionTitle}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Choices:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            trChoices.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: trChoices.asMap().entries.map((entry) {
                      final choiceIndex = entry.key;
                      final choice = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          '${choiceIndex + 1}.  $choice',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        widget.quizData.choices!.asMap().entries.map((entry) {
                      final choiceIndex = entry.key;
                      final choice = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          '${choiceIndex + 1}.  $choice',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
        trailing: const Text(''),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(8.0),
            title: Text(
              // Translate the correct answer if available
              trCorrectAnswer != null
                  ? 'Correct Answer: $trCorrectAnswer'
                  : 'Correct Answer: ${widget.quizData.choices![widget.quizData.correctAnsIndex!]}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                widget.quizData.explanation ==
                        "No answer description is available.  Let's discuss."
                    ? const SizedBox()
                    : Text(
                        trExplanation != null
                            ? trExplanation!
                            : 'Explanation: ${widget.quizData.explanation ?? "N/A"}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                const SizedBox(height: 8),
                if (widget.quizData.category != null)
                  Text(
                    'Category: ${widget.quizData.category}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                // Add more information as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
