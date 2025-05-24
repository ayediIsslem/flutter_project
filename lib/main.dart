import 'package:flutter/material.dart';
import 'package:quiz_projet/pages/high.score.page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_projet/pages/home.page.dart';
import 'package:quiz_projet/pages/quiz.page.dart';
import 'package:quiz_projet/pages/score.page.dart';
import 'package:quiz_projet/pages/settings.page.dart';
import 'package:quiz_projet/models/category.dart'; // Assure-toi que ce fichier existe

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final themeNotifier =
  ValueNotifier<ThemeMode>(isDark ? ThemeMode.dark : ThemeMode.light);
  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Quiz App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: currentMode,
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(themeNotifier: themeNotifier),
            '/score': (context) => ScorePage(),
            '/highscores': (context) => HighScorePage(),
            '/settings': (context) => SettingsPage(
              isDarkMode: currentMode == ThemeMode.dark,
              onThemeChanged: (bool isDark) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDarkMode', isDark);
                themeNotifier.value =
                isDark ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/quiz') {
              final args = settings.arguments as Map<String, dynamic>? ?? {};

              final category = args['category'] as Category?;
              final difficulty = args['difficulty'] as String? ?? 'medium';
              final amount = args['amount'] as int? ?? 10;

              if (category != null) {
                return MaterialPageRoute(
                  builder: (context) => QuizPage(
                    categoryId: category.id,
                    difficulty: difficulty,
                    amount: amount,
                  ),
                );
              } else {
                // Retourne une page d'erreur
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text("Erreur")),
                    body: const Center(
                      child: Text("Catégorie non définie."),
                    ),
                  ),
                );
              }
            }
            return null;
          },
        );
      },
    );
  }
}
