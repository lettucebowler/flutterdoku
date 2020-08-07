import 'package:flutter/material.dart';

class CustomStyles {

  static const Color black = Color(0xFF000000);

  static const int theme = 0xFF4c566a;

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


  static List polarNight = [
    const Color(0xFF2e3440),
    const Color(0xFF3b4252),
    const Color(0xFF434c5e),
    const Color(theme)
  ];

  static List snowStorm = [
    const Color(0xFFd8dee9),
    const Color(0xFFe5e9f0),
    const Color(0xFFeceff4)
  ];

  static List frost = [
    const Color(0xFF8fbcbb),
    const Color(0xFF88c0d0),
    const Color(0xFF81a1c1),
    const Color(0xFF5e81ac)
  ];

  static List aurora = [
    const Color(0xFFbf616a),
    const Color(0xFFd08770),
    const Color(0xFFebcb8b),
    const Color(0xFFa3be8c),
    const Color(0xFFb48ead)
  ];

  static TextStyle boardText = TextStyle(
    fontFamily: 'FiraCode',
    fontSize: 26,
    color: polarNight[3],
  );

  static TextStyle getFiraCode(Color color, double size) {
    return TextStyle(
      fontFamily: 'FiraCode',
      fontSize: size,
      color: color,
    );
  }

  static TextStyle titleText = TextStyle(
//    fontFamily: 'FiraCode',
    fontSize: 30,
    color: snowStorm[2],
  );
}