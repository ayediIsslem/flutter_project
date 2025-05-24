import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('sound') ?? true;
      vibrationEnabled = prefs.getBool('vibration') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', soundEnabled);
    await prefs.setBool('vibration', vibrationEnabled);
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  void _resetHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('high_scores');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("High scores reset")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("App Settings")),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Sound & Vibration", "Control sound effects and vibration"),
            _buildSwitch("Sound Effects", soundEnabled, (val) {
              setState(() => soundEnabled = val);
            }),
            _buildSwitch("Vibration", vibrationEnabled, (val) {
              setState(() => vibrationEnabled = val);
            }),
            const SizedBox(height: 20),

            _buildSectionTitle("Appearance", "Customize the app theme"),
            _buildSwitch("Dark Mode", isDarkMode, (val) {
              setState(() => isDarkMode = val);
              widget.onThemeChanged(val);
            }),
            const SizedBox(height: 20),

            _buildSectionTitle("Data", "Manage saved data"),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _resetHighScores,
              icon: const Icon(Icons.delete),
              label: const Text("Reset High Scores"),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _savePreferences();
                widget.onThemeChanged(isDarkMode);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
      ],
    );
  }
}
