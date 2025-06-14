import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool soundEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('sound') ?? false; // Désactivé par défaut
    });
  }

  void _playSound() async {
    if (soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/button-pressed-38129.mp3'));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int score = args['score'] as int;
    final int total = args['total'] as int;
    final List<Map<String, dynamic>> answers = args['answers'];
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your score: $score / $total',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  final bool isCorrect = answer['selectedAnswer'] == answer['correctAnswer'];

                  final Color cardColor = isCorrect
                      ? (isDarkMode ? Colors.green[700]! : Colors.green[100]!)
                      : (isDarkMode ? Colors.red[700]! : Colors.red[100]!);

                  final Color textColor = isDarkMode ? Colors.white : Colors.black;

                  return Card(
                    color: cardColor,
                    child: ListTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        answer['question'],
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your answer: ${answer['selectedAnswer']}',
                            style: TextStyle(color: textColor),
                          ),
                          Text(
                            'Correct answer: ${answer['correctAnswer']}',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  onPressed: () {
                    _playSound();
                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                      arguments: {
                        'categoryId': args['categoryId'],
                        'difficulty': args['difficulty'],
                        'amount': args['amount'],
                      },
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  onPressed: () {
                    _playSound();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
