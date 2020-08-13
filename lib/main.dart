//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/screens/SudokuPage.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'util/CustomStyles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await readFromPrefs();
  // bool problemGood = await _getGame();
  runApp(MyApp());
}

// _getGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   final initialString = prefs.getString('initialBoard');
//   final currentString = prefs.getString('currentBoard');
//   final finalString = prefs.getString('finalBoard');
//   List initialBoard = List.generate(9, (i) => List(9), growable: false);
//   List currentBoard = List.generate(9, (i) => List(9), growable: false);
//   List finalBoard = List.generate(9, (i) => List(9), growable: false);
//   if (initialString != null && currentString != null && finalString != null) {
//     for (int i = 0; i < initialString.length; i++) {
//       initialBoard[i ~/ 9][i % 9] = int.parse(initialString[i]);
//       currentBoard[i ~/ 9][i % 9] = int.parse(currentString[i]);
//       finalBoard[i ~/ 9][i % 9] = int.parse(finalString[i]);
//     }
//     globals.problem =
//         SudokuProblem.resume(initialBoard, currentBoard, finalBoard);
//   } else {
//     globals.problem =
//         SudokuProblem.withMoreHints(globals.initialHints.value - 17);
//   }
// }

// _saveGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   String initialString = "";
//   String currentString = "";
//   String finalString = "";
//   SudokuState initialState = globals.problem.getInitialState();
//   List initialBoard = initialState.getTiles();
//   SudokuState currentState = globals.problem.getCurrentState();
//   List currentBoard = currentState.getTiles();
//   SudokuState finalState = globals.problem.getFinalState();
//   List finalBoard = finalState.getTiles();
//   for (int i = 0; i < globals.problem.board_size; i++) {
//     for (int j = 0; j < globals.problem.board_size; j++) {
//       initialString += initialBoard[i][j].toString();
//       currentString += currentBoard[i][j].toString();
//       finalString += finalBoard[i][j].toString();
//     }
//   }
//   prefs.setString('initialBoard', initialString);
//   prefs.setString('currentBoard', currentString);
//   prefs.setString('finalBoard', finalString);
// }

// _deleteGame() async {
//   final prefs = await SharedPreferences.getInstance();
//   prefs.remove('initialBoard');
//   prefs.remove('currentBoard');
//   prefs.remove('finalBoard');
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LettuceSudoku',
      theme: ThemeData(
        primarySwatch: CustomStyles.themeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: CustomStyles.snowStorm[2],
      ),
      home: SudokuPage(title: 'LettuceSudoku'),
    );
  }
}
