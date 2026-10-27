import 'package:flutter/material.dart';

// Define as cores e o tema escuro usado no app inteiro
class Tema {
  static const Color fundo = Color(0xFF121212);
  static const Color superficie = Color(0xFF1E1E1E);
  static const Color destaque = Color(0xFF1DB954);
  static const Color texto = Color(0xFFEDEDED);
  static const Color textoFraco = Color(0xFF9A9A9A);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: fundo,
      colorScheme: const ColorScheme.dark(
        primary: destaque,
        secondary: destaque,
        surface: superficie,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: fundo,
        elevation: 0,
        foregroundColor: texto,
      ),
      cardColor: superficie,
      dividerColor: Colors.white12,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textoFraco),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: destaque,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: texto),
      ),
    );
  }
}
