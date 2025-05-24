// Modèle de question
class Question {
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  

  Question({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: htmlUnescape(json['question']),
      correctAnswer: htmlUnescape(json['correct_answer']),
      incorrectAnswers: List<String>.from(
        (json['incorrect_answers'] as List).map((e) => htmlUnescape(e)),
      ),
    );
  }

  List<String> getShuffledAnswers() {
    final answers = [...incorrectAnswers, correctAnswer];
    answers.shuffle();
    return answers;
  }

  static String htmlUnescape(String input) {
    return input.replaceAll('&quot;', '"')
                .replaceAll('&#039;', "'")
                .replaceAll('&amp;', '&')
                .replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>');
  }
}
