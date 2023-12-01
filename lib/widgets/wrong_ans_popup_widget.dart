import 'package:currect_affairs/providers/quiz_language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

class WrongAnswerScreen extends StatefulWidget {
  final VoidCallback onNext;
  final String explanation;
  final String title;

  const WrongAnswerScreen({
    super.key,
    required this.onNext,
    required this.explanation,
    required this.title,
  });

  @override
  State<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen> {
  String? trExplanation;
  int translatrdQuestionNo = 0;

  @override
  Widget build(BuildContext context) {
    final qLanguage =
        Provider.of<QuestionsLanguageProvider>(context, listen: false);
    final translator = GoogleTranslator();
    void translateQ() {
      translator
          .translate(widget.explanation, from: 'en', to: qLanguage.language)
          .then((s) {
        setState(() {
          trExplanation = s.toString();
        });
      });
    }

    if (qLanguage.language != "en" && translatrdQuestionNo == 0) {
      translateQ();
      translatrdQuestionNo++;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  top: BorderSide(
                    width: 2,
                    color: Colors.redAccent,
                  ),
                  bottom: BorderSide(
                    width: 2,
                    color: Colors.redAccent,
                  ),
                  left: BorderSide(
                    width: 2,
                    color: Colors.redAccent,
                  ),
                  right: BorderSide(
                    width: 2,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    trExplanation != null ? trExplanation! : widget.explanation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Try Again!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
