class QuizModel {
  String? quizID;
  String? quizTitle;
  List<Questions>? quizzes;
  int? noOfQuestions;

  QuizModel({
    this.quizID,
    this.quizTitle,
    this.quizzes,
    this.noOfQuestions,
  });

  QuizModel.fromJson(Map<String, dynamic> json) {
    quizID = json['quizID'];
    quizTitle = json['title'];
    if (json['quizzes'] != null) {
      quizzes = <Questions>[];
      json['quizzes'].forEach((v) {
        quizzes!.add(Questions.fromJson(v));
      });
    }
    noOfQuestions = json['noOfQuestions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quizID'] = quizID;
    data['title'] = quizTitle;
    if (quizzes != null) {
      data['quizzes'] = quizzes!.map((v) => v.toJson()).toList();
    }
    data['noOfQuestions'] = noOfQuestions;
    return data;
  }
}

class Questions {
  String? questionTitle;
  List<dynamic>? choices;
  int? correctAnsIndex;
  String? explanation;
  String? category;

  Questions({
    this.questionTitle,
    this.choices,
    this.correctAnsIndex,
    this.explanation,
    this.category,
  });

  Questions.fromJson(Map<String, dynamic> json) {
    questionTitle = json['questionTitle'];
    choices = json['choices'].cast<dynamic>();
    correctAnsIndex = json['correctAnsIndex'];
    explanation = json['explanation'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['questionTitle'] = questionTitle;
    data['choices'] = choices;
    data['correctAnsIndex'] = correctAnsIndex;
    data['explanation'] = explanation;
    data['category'] = category;
    return data;
  }
}
