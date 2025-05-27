import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quiz_projet/data/local.storage.dart';
import 'package:quiz_projet/models/question.dart';
import '../services/api.service.dart';

class QuizPage extends StatefulWidget {
  final int categoryId;
  final String difficulty;
  final int amount;

  const QuizPage({
    Key? key,
    required this.categoryId,
    required this.difficulty,
    required this.amount,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  List<List<String>> shuffledAnswersPerQuestion = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;

  int remainingSeconds = 20;
  Timer? countdownTimer;

  List<Map<String, dynamic>> userAnswers = [];

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool soundEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    loadQuestions();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('sound') ?? false;
    });
  }

  void _playSound() async {
    if (soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/button-pressed-38129.mp3'));
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void loadQuestions() async {
    final fetchedQuestions = await ApiService.fetchQuestions(
      categoryId: widget.categoryId,
      difficulty: widget.difficulty,
      amount: widget.amount,
    );

    final shuffledAnswers = fetchedQuestions.map((q) => q.getShuffledAnswers()).toList();

    setState(() {
      questions = fetchedQuestions;
      shuffledAnswersPerQuestion = shuffledAnswers;
      isLoading = false;
    });

    startTimer();
  }

  void startTimer() {
    countdownTimer?.cancel();
    setState(() {
      remainingSeconds = 20;
    });
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        saveAnswerAndNext(null); // No answer
      }
    });
  }

  void stopTimer() {
    countdownTimer?.cancel();
  }

  void saveAnswerAndNext(String? selectedAnswer) {
    final question = questions[currentQuestionIndex];

    userAnswers.add({
      'question': question.question,
      'selectedAnswer': selectedAnswer ?? 'No answer',
      'correctAnswer': question.correctAnswer,
    });

    if (selectedAnswer != null && selectedAnswer == question.correctAnswer) {
      setState(() {
        score++;
      });
    }

    goToNextQuestion();
  }

  void goToNextQuestion() async {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      startTimer();
    } else {
      await LocalStorage.saveScore(
        widget.categoryId.toString(),
        widget.difficulty,
        score,
      );

      Navigator.pushReplacementNamed(
        context,
        '/score',
        arguments: {
          'score': score,
          'total': questions.length,
          'answers': userAnswers,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];
    final answers = shuffledAnswersPerQuestion[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Question ${currentQuestionIndex + 1}/${questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$remainingSeconds seconds',
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...answers.map((answer) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _playSound();
                  stopTimer();
                  saveAnswerAndNext(answer);
                },
                child: Text(answer, style: const TextStyle(fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
