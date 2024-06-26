import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/controllers/local.dart';
import 'package:currect_affairs/models/category_model.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/providers/ad_provider.dart';
import 'package:currect_affairs/screens/daily_current_affairs.dart';
import 'package:currect_affairs/screens/inside_gk_screen.dart';
import 'package:currect_affairs/screens/nav_bar.dart';
import 'package:currect_affairs/screens/play_quiz_screen.dart';
import 'package:currect_affairs/screens/search_screen.dart';
import 'package:currect_affairs/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneranKnowledgeScreen extends StatefulWidget {
  const GeneranKnowledgeScreen({Key? key}) : super(key: key);

  @override
  State<GeneranKnowledgeScreen> createState() => _GeneranKnowledgeScreenState();
}

class _GeneranKnowledgeScreenState extends State<GeneranKnowledgeScreen> {
  List<QuizModel> currectAffairs = [];

  int listLength = 6;

  bool _isLoading = false;

  void fetchCurrectAffairs() async {
    if (currectAffairs.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection('Basic General Knowledge')
        .orderBy('createdAt', descending: true)
        .limit(listLength)
        .get();

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
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrectAffairs();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: Image.asset(
          'assets/images/app_logo_no_bg.png',
          height: 70,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
              ))
        ],
      ),
      body: Center(
        child: Container(
          color: AppColors.primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Daily Current Affairs Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Basic General Knowledge',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            SizedBox(
                              height: 60.0,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: currectAffairs.length,
                                itemBuilder: (context, index) {
                                  final current = currectAffairs[index];

                                  if (index == currectAffairs.length - 1) {
                                    return TextButton(
                                      onPressed: () {
                                        if (!adProvider.isPremium &&
                                            adProvider.shouldShowAd) {
                                          adProvider.showInterstitialAd();
                                        }

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const InsideGKScreen(
                                              collection:
                                                  'Basic General Knowledge',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'See All',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Render a regular item for other indices
                                    return TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PlayQuizScreen(
                                              quizData: current,
                                              collection:
                                                  'Basic General Knowledge',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            current.quizTitle!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!adProvider.isPremium && adProvider.shouldShowAd)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Center(child: BannerAdWidget()),
                        ),

                      // Current Affairs by Category
                      const Center(
                        child: Text(
                          'General Knowledge By Category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: categoriesGk.length,
                          itemBuilder: (BuildContext context, int index) {
                            Category category = categoriesGk[index];
                            return InkWell(
                              onTap: () {
                                if (!adProvider.isPremium &&
                                    adProvider.shouldShowAd) {
                                  adProvider.showInterstitialAd();
                                }
                                if (category.name == 'Daily Current Affairs') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DailyCurrentAffairsScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => InsideGKScreen(
                                              collection: category.name,
                                            )),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: category.color,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        category.icon,
                                        size: 36.0,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          category.name,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
