import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/screens/search_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/screens/play_quiz_screen.dart';

class InsideCategoryScreen extends StatefulWidget {
  final String category;
  const InsideCategoryScreen({Key? key, required this.category})
      : super(key: key);

  @override
  State<InsideCategoryScreen> createState() => _InsideCategoryScreenState();
}

class _InsideCategoryScreenState extends State<InsideCategoryScreen> {
  List<QuizModel> currentAffairs = [];

  int listLength = 6;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;
  int total = 0;

  void fetchcurrentAffairs(bool next, context) async {
    if (currentAffairs.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collectionGroup('quizzes')
          .orderBy('date', descending: true)
          .where('category', isEqualTo: widget.category)
          .startAfter([lastDocument?['date']])
          .limit(45)
          .get();
    } else {
      quizCollection = await firestore
          .collectionGroup('quizzes')
          .orderBy('date', descending: true)
          .where('category', isEqualTo: widget.category)
          .limit(45)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No more available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocument =
        quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

    List<Questions> questions = [];

    for (final quizDoc in quizCollection.docs) {
      final quizData = quizDoc.data();

      final quizItem = Questions(
        questionTitle: quizData['questionTitle'],
        choices: quizData['choices'],
        correctAnsIndex: quizData['correctAnsIndex'],
        explanation: quizData['explanation'],
        category: quizData['category'],
      );

      questions.add(quizItem);
    }

    int result = questions.length ~/ 15; // Integer division
    int leftover = questions.length % 15; // Remainder

    if (kDebugMode) {
      print(result);
      print(leftover);
    }

    for (var i = 0; i < result; i++) {
      final List<Questions> localQuestions = [];
      for (var i = 0; i < 15; i++) {
        localQuestions.add(questions[total + i]);
      }
      final quizItem = QuizModel(
        quizTitle: '${widget.category} #${total + 1}',
        noOfQuestions: 15,
        quizzes: localQuestions,
      );
      total++;
      currentAffairs.add(quizItem);
    }

    List<Questions> localQuestions = [];
    for (var i = 0; i < leftover; i++) {
      localQuestions.add(questions[i]);
    }

    if (localQuestions.isNotEmpty) {
      final quizItem = QuizModel(
        quizTitle: '${widget.category} #${total + 1}',
        noOfQuestions: leftover,
        quizzes: localQuestions,
      );
      total++;
      currentAffairs.add(quizItem);
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchcurrentAffairs(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.thirdColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: currentAffairs.length + 1,
              itemBuilder: (context, index) {
                if (index == currentAffairs.length) {
                  return Center(
                    child: _isButtonLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  fetchcurrentAffairs(true, context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                child: const Text('Load more...',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(
                                height: 25,
                              )
                            ],
                          ),
                  );
                }
                return QuizCard(quizModel: currentAffairs[index]);
              },
            ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final QuizModel quizModel;

  const QuizCard({Key? key, required this.quizModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    final Color randomColor =
        predefinedColors[random.nextInt(predefinedColors.length)];

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlayQuizScreen(
                quizData: quizModel,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                randomColor.withOpacity(0.9),
                randomColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  quizModel.quizTitle ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quizModel.noOfQuestions} Questions',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
