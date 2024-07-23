import 'package:flutter/material.dart';
import 'package:notes_app/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatefulWidget {
  const NoteApp({super.key});

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Future<void> _loadThemePreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isDarkMode = pref.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme(bool isDarkMode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      pref.setBool('isDarkMode', isDarkMode);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NOTE_APP",
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 181, 63, 63)),
          useMaterial3: true,
          brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: HomeScreen(onThemeChanged: _toggleTheme),
    );
  }
}
