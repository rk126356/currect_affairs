import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/models/quiz_model.dart';
import 'package:currect_affairs/screens/inside_category_screen.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('current_affairs');
  List<DocumentSnapshot> _searchResults = [];

  void _searchUsers(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    _usersCollection
        .where('quizTitleSubstrings', arrayContains: searchText.toLowerCase())
        .limit(3)
        .get()
        .then((querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Search Current Affairs',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Current Affairs',
                  hintText: 'Ex: January 22, 2022',
                  hintStyle: const TextStyle(
                      color: Colors.grey), // Customize hint text color
                  border: OutlineInputBorder(
                    // Customize border
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2.0),
                  ),
                ),
                onChanged: (text) => _searchUsers(text),
              )),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var quizData =
                          _searchResults[index].data() as Map<String, dynamic>;

                      final quiz = QuizModel(
                        quizID: quizData['quizID'],
                        quizTitle: quizData['quizTitle'],
                        noOfQuestions: quizData['noOfQuestions'],
                      );
                      return QuizCard(quizModel: quiz);
                    },
                  )
                : const Center(
                    child: Text(
                      'No Current Affairs found\n\nMake sure to seacrh like: January 22, 2022',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
