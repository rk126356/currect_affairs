import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateBookmarks(QuizModel quizData) async {
  if (quizData.quizID != null) {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final sharedQuizRef = firestore.collection('users/$uid/myBookmarks');
    final sharedQuizSnapshot =
        await sharedQuizRef.where('quizID', isEqualTo: quizData.quizID).get();

    final bool isPlayed = sharedQuizSnapshot.docs.isNotEmpty;

    if (isPlayed) {
      await sharedQuizSnapshot.docs.first.reference.delete();
    }

    if (!isPlayed) {
      await sharedQuizRef.add({
        'quizID': quizData.quizID,
        'quizTitle': quizData.quizTitle,
        'noOfQuestions': quizData.noOfQuestions,
        'createdAt': Timestamp.now(),
      });
    }
  }
}
