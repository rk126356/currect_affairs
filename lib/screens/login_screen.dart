import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/user_model.dart';
import 'package:currect_affairs/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final User _user;

  bool isLoading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    var data = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;
      _user = user!;

      data.setUserData(UserModel(
        uid: _user.uid,
        email: _user.email,
        name: _user.displayName,
        avatarUrl: _user.photoURL,
      ));

      // Check if the user data already exists in Firestore
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        // If the document exists, update its data
        await userDoc.update({
          // 'displayName': user.displayName,
          // 'email': user.email,
          // 'uid': user.uid,
          // 'avatarUrl': user.photoURL,
        });
      } else {
        await userDoc.set({
          'displayName': user.displayName,
          'email': user.email,
          'uid': user.uid,
          'avatarUrl': user.photoURL,
          'plan': 'free',
        });
      }

      if (kDebugMode) {
        print('User data stored in Firestore');
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in with Google: $error');
      }
      final user = FirebaseAuth.instance.currentUser;

      setState(() {
        isLoading = false;
      });
      if (user != null) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_logo_no_bg.png',
                      height: 300,
                      width: 300,
                    ),
                    const Text(
                      'Daily Current Affairs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        signInWithGoogle(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google-logo.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
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
