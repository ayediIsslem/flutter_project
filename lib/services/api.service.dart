// Récupère les questions et catégories depuis OpenTDB
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/question.dart';

class ApiService {
  static const String _baseUrl = 'https://opentdb.com';

  /// Récupère les catégories disponibles
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/api_category.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['trivia_categories'];
      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Erreur de chargement des catégories');
    }
  }

  /// Récupère une liste de questions selon les paramètres
  static Future<List<Question>> fetchQuestions({
    required int categoryId,
    required String difficulty,
    required int amount,
  }) async {
    final url =
        '$_baseUrl/api.php?amount=$amount&category=$categoryId&difficulty=$difficulty&type=multiple';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['results'];
      return list.map((e) => Question.fromJson(e)).toList();
    } else {
      throw Exception('Erreur de chargement des questions');
    }
  }
}