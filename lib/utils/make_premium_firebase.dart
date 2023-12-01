import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> makePremium() async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final uid = user?.uid;
  final userRef = firestore.collection('users').doc(uid);

  await userRef.update({'plan': 'premium'});
}
