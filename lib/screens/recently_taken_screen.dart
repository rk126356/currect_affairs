import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/providers/user_provider.dart';
import 'package:currect_affairs/screens/play_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentlyTakenScreen extends StatefulWidget {
  const RecentlyTakenScreen({super.key});

  @override
  State<RecentlyTakenScreen> createState() => _RecentlyTakenScreenState();
}

class _RecentlyTakenScreenState extends State<RecentlyTakenScreen> {
  List<QuizModel> currectAffairs = [];

  int listLength = 10;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  void fetchCurrectAffairs(bool next, context) async {
    if (currectAffairs.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;
    final user = Provider.of<UserProvider>(context, listen: false).userData;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collection('users/${user.uid}/myPlayedQuizzes')
          .orderBy('createdAt', descending: true)
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('users/${user.uid}/myPlayedQuizzes')
          .orderBy('createdAt', descending: true)
          .limit(listLength)
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

    await Future.forEach(quizCollection.docs, (quizDoc) async {
      final quizData = quizDoc.data();

      final quizItem = QuizModel(
        quizID: quizData['quizID'],
        quizTitle: quizData['quizTitle'],
        noOfQuestions: quizData['noOfQuestions'],
      );

      currectAffairs.add(quizItem);
    });
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrectAffairs(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.thirdColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Recently Taken',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: currectAffairs.length + 1,
              itemBuilder: (context, index) {
                if (index == currectAffairs.length) {
                  return Center(
                    child: _isButtonLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  fetchCurrectAffairs(true, context);
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
                return QuizCard(quizModel: currectAffairs[index]);
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
