import 'package:flutter/material.dart';
import 'package:quiz_projet/data/local.storage.dart';

class HighScorePage extends StatefulWidget {
  @override
  State<HighScorePage> createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {
  Map<String, int> scores = {};

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> loadScores() async {
    final loadedScores = await LocalStorage.getScores();
    setState(() {
      scores = loadedScores;
    });
  }

  Future<void> clearScores() async {
    await LocalStorage.clearScores();
    setState(() {
      scores = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Scores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Scores?'),
                  content: const Text('Are you sure you want to delete all scores?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                clearScores();
              }
            },
          )
        ],
      ),
      body: scores.isEmpty
          ? const Center(child: Text('No scores saved.'))
          : ListView.builder(
        itemCount: scores.length,
        itemBuilder: (context, index) {
          final key = scores.keys.elementAt(index);
          final score = scores[key]!;
          final parts = key.split('-');
          final category = parts[0];
          final difficulty = parts.length > 1 ? parts[1] : 'N/A';

          return ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: Text('Category: $category'),
            subtitle: Text('Difficulty: $difficulty'),
            trailing: Text('Score: $score'),
          );
        },
      ),
    );
  }
}
