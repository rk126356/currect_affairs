import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/controllers/local.dart';
import 'package:currect_affairs/models/category_model.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/providers/ad_provider.dart';
import 'package:currect_affairs/providers/user_provider.dart';
import 'package:currect_affairs/screens/daily_current_affairs.dart';
import 'package:currect_affairs/screens/inside_category_screen.dart';
import 'package:currect_affairs/screens/inside_gk_screen.dart';
import 'package:currect_affairs/screens/nav_bar.dart';
import 'package:currect_affairs/screens/play_quiz_screen.dart';
import 'package:currect_affairs/screens/remove_ads_screen.dart';
import 'package:currect_affairs/screens/search_screen.dart';
import 'package:currect_affairs/utils/check_update.dart';
import 'package:currect_affairs/widgets/banner_ad_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        .collection('current_affairs')
        .orderBy('date', descending: true)
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

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-3442981380712673/6075546074',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          ad.show();
          ad.dispose();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const RemoveAdsScreen();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
      orientation: 1,
    );
  }

  void checkShouldShowAd(context) async {
    setState(() {
      _isLoading = true;
    });
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    final adProvider = Provider.of<AdProvider>(context, listen: false);
    final appInfoGet =
        await firestore.collection('appInfo').doc('iO8Yck5WE3uvfxiKxT6E').get();

    final userRef = await firestore.collection('users').doc(uid).get();

    final userData = userRef.data();

    final appInfoData = appInfoGet.data();

    final bool isPremium = userData?['plan'] == 'premium' ? true : false;

    if (isPremium) {
      adProvider.setIsPremium(true);
      adProvider.setShouldShowAd(false);
    } else {
      adProvider.setIsPremium(false);
    }

    if (appInfoData?['shouldShowAd'] && !isPremium) {
      adProvider.setShouldShowAd(true);
      adProvider.initializeInterstitialAd();
      // _loadAppOpenAd();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void initializeOneSignal() {
    debugPrint('Initializing one signal');
    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("f316feda-c4ec-4553-9077-e12bd8795a16");

// // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
  }

  void checkNewOpen() {
    final user = Provider.of<UserProvider>(context, listen: false);
    if (user.isNewOpen) {
      checkShouldShowAd(context);
      user.setIsNewOpen(false);
      updateAppLaunched(context);
    } else {
      initializeOneSignal();
    }
  }

  @override
  void initState() {
    super.initState();
    checkNewOpen();
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
          height: 60,
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
                                  'Daily Current Affairs',
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
                                                const DailyCurrentAffairsScreen(),
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
                                            current.quizTitle!.substring(0,
                                                current.quizTitle!.length - 15),
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
                          'Currenr Affairs By Category',
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
                          itemCount: categories.length,
                          itemBuilder: (BuildContext context, int index) {
                            Category category = categories[index];
                            return InkWell(
                              onTap: () {
                                if (!adProvider.isPremium &&
                                    adProvider.shouldShowAd) {
                                  adProvider.showInterstitialAd();
                                }
                                if (category.name ==
                                    'Basic General Knowledge') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const InsideGKScreen(
                                        collection: 'Basic General Knowledge',
                                      ),
                                    ),
                                  );
                                } else if (category.name ==
                                    'Daily Current Affairs') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DailyCurrentAffairsScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InsideCategoryScreen(
                                        category: category.name,
                                      ),
                                    ),
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
