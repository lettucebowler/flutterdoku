import 'package:flutter/material.dart';

class CustomStyles {
  static const Color black = Color(0xFF000000);

  static const int theme = 0xFF4c566a;

  // Polar Night
  static const nord0 = Color(0xFF2e3440);
  static const nord1 = Color(0xFF3b4252);
  static const nord2 = Color(0xFF434c5e);
  static const nord3 = Color(theme);

  static const nord4 = Color(0xFFd8dee9);
  static const nord5 = Color(0xFFe5e9f0);
  static const nord6 = Color(0xFFeceff4);

  static const nord7 = Color(0xFFd8dee9);
  static const nord8 = Color(0xFFd8dee9);
  static const nord9 = Color(0xFFd8dee9);
  static const nord10 = Color(0xFFd8dee9);

  static const nord11 = Color(0xFFd8dee9);
  static const nord12 = Color(0xFFd8dee9);
  static const nord13 = Color(0xFFd8dee9);
  static const nord14 = Color(0xFFd8dee9);
  static const nord15 = Color(0xFFd8dee9);


  static const MaterialColor themeColor = MaterialColor(
    theme,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  static const List frost = [
    const Color(0xFF8fbcbb),
    const Color(0xFF88c0d0),
    const Color(0xFF81a1c1),
    const Color(0xFF5e81ac)
  ];

  static const List aurora = [
    const Color(0xFFbf616a),
    const Color(0xFFd08770),
    const Color(0xFFebcb8b),
    const Color(0xFFa3be8c),
    const Color(0xFFb48ead)
  ];

  static const TextStyle boardText = TextStyle(
    fontFamily: 'FiraCode',
    fontSize: 26,
    color: nord3,
  );

  static const TextStyle titleText = TextStyle(
//    fontFamily: 'FiraCode',
    fontSize: 30,
    color: nord2,
  );
}
