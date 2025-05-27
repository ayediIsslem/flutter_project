import 'package:flutter/material.dart';
import 'package:quiz_projet/models/category.dart';
import 'package:quiz_projet/services/api.service.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomePage({super.key, required this.themeNotifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Category> categories = [];
  Category? selectedCategory;
  String selectedDifficulty = 'medium';
  int selectedQuestionCount = 10;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final fetched = await ApiService.fetchCategories();
      if (fetched.isNotEmpty) {
        setState(() {
          categories = fetched;
          selectedCategory = fetched.first;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des catégories: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/button-pressed-38129.mp3'));
    } catch (e) {
      print('Erreur lors de la lecture du son: $e');
    }
  }

  void startQuiz() async {
    await playSound();
    if (selectedCategory == null) return;
    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: {
        'category': selectedCategory,
        'difficulty': selectedDifficulty,
        'amount': selectedQuestionCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final theme = Theme.of(context);
        final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "QuizMaster",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Test your knowledge with our interactive quiz!",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Quiz Config Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.play_circle, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            "Start a Quiz",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Customize your quiz experience",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      Text("Category", style: TextStyle(color: textColor)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<Category>(
                        value: selectedCategory,
                        isExpanded: true,
                        decoration: _inputDecoration(theme, isDark),
                        dropdownColor: theme.cardColor,
                        style: TextStyle(color: textColor),
                        items: categories
                            .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name, style: TextStyle(color: textColor)),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Difficulty Dropdown
                      Text("Difficulty", style: TextStyle(color: textColor)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: selectedDifficulty,
                        decoration: _inputDecoration(theme, isDark),
                        dropdownColor: theme.cardColor,
                        style: TextStyle(color: textColor),
                        items: ['easy', 'medium', 'hard']
                            .map((diff) => DropdownMenuItem(
                          value: diff,
                          child: Text(
                            diff[0].toUpperCase() + diff.substring(1),
                            style: TextStyle(color: textColor),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Number of Questions Dropdown
                      Text("Number of Questions", style: TextStyle(color: textColor)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: selectedQuestionCount,
                        decoration: _inputDecoration(theme, isDark),
                        dropdownColor: theme.cardColor,
                        style: TextStyle(color: textColor),
                        items: [5, 10, 15, 20]
                            .map((count) => DropdownMenuItem(
                          value: count,
                          child: Text('$count', style: TextStyle(color: textColor)),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedQuestionCount = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: startQuiz,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Text(
                            "Start Quiz",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navBox(icon: Icons.settings, label: "Settings", route: '/settings'),
                    _navBox(icon: Icons.leaderboard, label: "High Scores", route: '/highscores'),
                  ],
                ),
                const SizedBox(height: 16),
                _navBox(
                  icon: Icons.info_outline,
                  label: "About",
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'QuizMaster',
                      applicationVersion: '1.0',
                      children: const [
                        Text("Questions provided by Open Trivia DB"),
                        Text("https://opentdb.com"),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2E) : theme.inputDecorationTheme.fillColor ?? const Color(0xFFF0F0FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _navBox({
    required IconData icon,
    required String label,
    String? route,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
              () {
            if (route != null) Navigator.pushNamed(context, route);
          },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
