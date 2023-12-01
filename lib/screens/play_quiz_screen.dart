import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/providers/ad_provider.dart';
import 'package:currect_affairs/providers/quiz_language_provider.dart';
import 'package:currect_affairs/screens/reading_mode_screen.dart';
import 'package:currect_affairs/screens/show_score_screen.dart';
import 'package:currect_affairs/utils/language_selector.dart';
import 'package:currect_affairs/utils/update_bookmarks_firebase.dart';
import 'package:currect_affairs/utils/update_plays_firebase.dart';
import 'package:currect_affairs/widgets/banner_ad_widget.dart';
import 'package:currect_affairs/widgets/choice_button._widget.dart';
import 'package:currect_affairs/widgets/question_name_box_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayQuizScreen extends StatefulWidget {
  final QuizModel quizData;
  final String? collection;

  const PlayQuizScreen({Key? key, required this.quizData, this.collection})
      : super(key: key);

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  Timer? quizTimer;
  Timer? timeTaken;
  late int secondsRemaining;
  int secondsTotal = 0;
  int? noOfAttempts = 0;
  bool _isCorrect = false;
  bool _isWrong = false;
  bool hasInternet = true;
  int _selectedChoice = 100;
  bool _isLoadingAns = false;
  bool _shouldFetch = false;

  Future<void> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    });
  }

  void checkAnswer(int selectedChoice) {
    checkInternetConnection();
    setState(() {
      _isLoadingAns = true;
      _selectedChoice = selectedChoice;
    });

    if (kDebugMode) {
      print('Checking answer');
    }
    final correctIndex =
        widget.quizData.quizzes![currentQuestionIndex].correctAnsIndex;

    if (selectedChoice == correctIndex) {
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return CorrectAnswerScreen(
      //         explanation:
      //             widget.quizData.quizzes![currentQuestionIndex].explanation!,
      //         onNext: () {
      //           Navigator.pop(
      //             context,
      //           );
      //         },
      //       );
      //     });
      setState(() {
        _isCorrect = true;
        score++;
      });
    } else {
      setState(() {
        _isWrong = true;
      });
    }
    // Move to the next question
    if (currentQuestionIndex < widget.quizData.quizzes!.length - 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _selectedChoice = 100;
          currentQuestionIndex++;
          _isLoadingAns = false;
          _isCorrect = false;
          _isWrong = false;
        });
      });
    } else {
      // Quiz is complete, you can navigate to the results screen or perform any other action.
      if (timeTaken != null && timeTaken!.isActive) {
        timeTaken!.cancel();
      }
      final adProvider = Provider.of<AdProvider>(context, listen: false);

      if (!adProvider.isPremium && adProvider.shouldShowAd) {
        adProvider.showInterstitialAd();
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ShowScoreScreen(
              quizData: widget.quizData,
              score: score,
              totalSecondsTaken: secondsTotal,
              totalQuestions: widget.quizData.noOfQuestions!,
            ), // Pass the score
          ),
        );
      });
    }
  }

  startTimeTaken() {
    timeTaken = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      secondsTotal++;
    });
  }

  Future<void> fetchQuizzes() async {
    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection(widget.collection ?? 'current_affairs')
        .where('quizID', isEqualTo: widget.quizData.quizID)
        .get();

    await Future.forEach(quizCollection.docs, (quizDoc) async {
      List<Questions> quizzes = [];

      final subCollectionReference = quizDoc.reference.collection('quizzes');

      final subCollectionSnapshot = await subCollectionReference.get();

      await Future.forEach(subCollectionSnapshot.docs, (quiz) {
        final questionData = quiz.data();

        final quizItem = Questions(
          questionTitle: questionData['questionTitle'],
          choices: questionData['choices'],
          correctAnsIndex: questionData['correctAnsIndex'],
          explanation: questionData['explanation'],
          category: questionData['category'],
        );

        quizzes.add(quizItem);
      });

      widget.quizData.quizzes = quizzes;
    });
    setState(() {
      _shouldFetch = false;
    });
  }

  bool _isBookmarked = false;

  void fetchBookmark() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final sharedQuizRef = firestore.collection('users/$uid/myBookmarks');
    final sharedQuizSnapshot = await sharedQuizRef
        .where('quizID', isEqualTo: widget.quizData.quizID)
        .get();

    final bool isPlayed = sharedQuizSnapshot.docs.isNotEmpty;

    setState(() {
      _isBookmarked = isPlayed;
    });
  }

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    startTimeTaken();
    updatePlays(widget.quizData);
    if (widget.quizData.quizID != null) {
      fetchBookmark();
      setState(() {
        _shouldFetch = true;
      });
      fetchQuizzes();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timeTaken != null && timeTaken!.isActive) {
      timeTaken!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final qLanguage = Provider.of<QuestionsLanguageProvider>(context);
    final adProvider = Provider.of<AdProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReadingModeScreen(
                quizData: widget.quizData,
              ),
            ),
          );
        },
        tooltip: 'Reading Mode',
        child: const Icon(Icons.remove_red_eye),
      ),
      appBar: AppBar(
        actions: [
          if (widget.quizData.quizID != null)
            IconButton(
                onPressed: () {
                  if (_isBookmarked) {
                    setState(() {
                      _isBookmarked = false;
                    });
                  } else {
                    setState(() {
                      _isBookmarked = true;
                    });
                  }
                  updateBookmarks(widget.quizData);
                },
                icon: Icon(_isBookmarked
                    ? Icons.bookmark_added
                    : Icons.bookmark_add_outlined)),
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
      body: !hasInternet
          ? Center(
              child: Column(
                children: [
                  const Text(
                      'No internet connection available, please check your network settings.'),
                  ElevatedButton(
                    onPressed: () {
                      checkInternetConnection();
                    },
                    child: const Text('Try again!'),
                  )
                ],
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.secondaryColor, AppColors.primaryColor],
                ),
              ),
              child: _shouldFetch
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              QuestionNameBox(
                                totalQuestions: widget.quizData.noOfQuestions!,
                                currentIndex: currentQuestionIndex + 1,
                                correct: score,
                                name: widget
                                    .quizData
                                    .quizzes![currentQuestionIndex]
                                    .questionTitle!,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (!adProvider.isPremium &&
                                  adProvider.shouldShowAd)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10.0),
                                  child: Center(child: BannerAdWidget()),
                                ),
                              Column(
                                children: widget.quizData
                                    .quizzes![currentQuestionIndex].choices!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final choice = entry.value;
                                  return InkWell(
                                    onTap: () {
                                      if (!_isLoadingAns) {
                                        checkAnswer(index);
                                      }
                                    },
                                    child: ChoiceButton(
                                      isWrong: _isWrong,
                                      isCorrect: _isCorrect,
                                      index: index + 1,
                                      text: choice,
                                      selectedChoice: _selectedChoice + 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }
}
