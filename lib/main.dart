import 'package:currect_affairs/models/user_model.dart';
import 'package:currect_affairs/providers/ad_provider.dart';
import 'package:currect_affairs/providers/quiz_language_provider.dart';
import 'package:currect_affairs/providers/user_provider.dart';
import 'package:currect_affairs/screens/bottom_navigation.dart';
import 'package:currect_affairs/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => QuestionsLanguageProvider()),
    ChangeNotifierProvider(create: (context) => AdProvider()),
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            if (user != null) {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.setUserData(UserModel(
                  uid: user.uid,
                  name: user.displayName,
                  avatarUrl: user.photoURL,
                  email: user.email));
              return const BottomNavigationBarScreen();
            } else {
              return const LoginScreen();
            }
          } else {
            // Waiting for the connection to establish
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
