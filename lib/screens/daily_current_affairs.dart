import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/screens/inside_category_screen.dart';
import 'package:currect_affairs/screens/search_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/screens/play_quiz_screen.dart';

class DailyCurrentAffairsScreen extends StatefulWidget {
  const DailyCurrentAffairsScreen({Key? key}) : super(key: key);

  @override
  State<DailyCurrentAffairsScreen> createState() =>
      _DailyCurrentAffairsScreenState();
}

class _DailyCurrentAffairsScreenState extends State<DailyCurrentAffairsScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime initialDate = DateTime.now().subtract(const Duration(days: 5));

  Future<void> _selectDate(context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2017),
      lastDate: initialDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      if (kDebugMode) {
        print('Selected date: $formattedDate');
      }

      final firestore = FirebaseFirestore.instance;

      final quizCollection = await firestore
          .collection('current_affairs')
          .where('date', isEqualTo: formattedDate)
          .get();

      if (quizCollection.docs.isNotEmpty) {
        final quizData = quizCollection.docs.first.data();

        final quizItem = QuizModel(
          quizID: quizData['quizID'],
          quizTitle: quizData['quizTitle'],
          noOfQuestions: quizData['noOfQuestions'],
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlayQuizScreen(
              quizData: quizItem,
            ),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: const Text('Not found!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

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

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collection('current_affairs')
          .orderBy('date', descending: true)
          .startAfter([lastDocument?['date']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('current_affairs')
          .orderBy('date', descending: true)
          .limit(listLength)
          .get();

      final dateData = quizCollection.docs.first.data();
      setState(() {
        initialDate = DateTime.parse(dateData['date']);
      });
    }

    if (quizCollection.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No more quizzes available.'),
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
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
          ),
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
        title: const Text(
          'Daily Current Affairs',
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
