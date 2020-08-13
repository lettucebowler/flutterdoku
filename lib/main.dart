//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/screens/SudokuScreen.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
// import 'util/CustomStyles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await readFromPrefs();
  // bool problemGood = await _getGame();
  runApp(LettuceSudoku());
}

// _deleteGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.remove('initialBoard');
//   prefs.remove('currentBoard');
//   prefs.remove('finalBoard');
// }

class LettuceSudoku extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LettuceSudoku',
      theme: ThemeData(
        primarySwatch: getMaterialColor(CustomStyles.polarNight[3]),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: getMaterialColor(CustomStyles.snowStorm[2]),
      ),
      home: SudokuScreen(title: 'LettuceSudoku'),
    );
  }
}
