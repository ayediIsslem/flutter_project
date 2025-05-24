//Pour stocker les scores avec SharedPreferences
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String scoresKey = 'quiz_scores';

  static Future<void> saveScore(String category, String difficulty, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$category-$difficulty';

    final scores = await getScores();
    scores[key] = score;

    await prefs.setString(scoresKey, jsonEncode(scores));
  }

  static Future<Map<String, int>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(scoresKey);
    if (data == null) return {};

    final Map<String, dynamic> json = jsonDecode(data);
    return json.map((key, value) => MapEntry(key, value as int));
  }

  static Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(scoresKey);
  }
}
