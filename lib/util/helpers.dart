import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettuce_sudoku/util/globals.dart' as globals;

var settingsMap = {
  'doPeerCells': globals.doPeerCells,
  'doPeerDigits': globals.doPeerDigits,
  'doMistakes': globals.doMistakes,
  'initialHints': globals.initialHints,
  'legalityRadio': globals.legalityRadio
};

Future<bool> readFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final peerCells = prefs.getBool('doPeerCells');
  final peerDigits = prefs.getBool('doPeerDigits');
  final mistakes = prefs.getBool('doMistakes');
  final hints = prefs.getInt('initialHints');
  final legality = prefs.getInt('legalityRadio');
  globals.doPeerCells.value = peerCells != null ? peerCells : true;
  globals.doPeerDigits.value = peerDigits != null ? peerDigits : true;
  globals.doMistakes.value = mistakes != null ? mistakes : true;
  globals.initialHints.value = hints != null ? hints : 30;
  globals.legalityRadio.value = legality == 1 || legality == 0 ? legality : 0;
  return true;
}

saveToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final legalityRadio = globals.legalityRadio.value;
  final doPeerCells = globals.doPeerCells.value;
  final doPeerDigits = globals.doPeerDigits.value;
  final doMistakes = globals.doMistakes.value;
  final hints = globals.initialHints.value;
  prefs.setBool('doPeerCells', doPeerCells);
  prefs.setBool('doPeerDigits', doPeerDigits);
  prefs.setBool('doMistakes', doMistakes);
  prefs.setInt('legalityRadio', legalityRadio);
  prefs.setInt('initialHints', hints);
}

saveGame() async {
  final prefs = await SharedPreferences.getInstance();
  String initialString = "";
  String currentString = "";
  String finalString = "";
  SudokuState initialState = globals.problem.getInitialState();
  List initialBoard = initialState.getTiles();
  SudokuState currentState = globals.problem.getCurrentState();
  List currentBoard = currentState.getTiles();
  SudokuState finalState = globals.problem.getFinalState();
  List finalBoard = finalState.getTiles();

  for (int i = 0; i < globals.problem.board_size; i++) {
    for (int j = 0; j < globals.problem.board_size; j++) {
      initialString += initialBoard[i][j].toString();
      currentString += currentBoard[i][j].toString();
      finalString += finalBoard[i][j].toString();
    }
  }

  String hintString = '';
  for (var i = 0; i < globals.hintsGiven.length; i++) {
    hintString += globals.hintsGiven[i][0].toString();
    hintString += globals.hintsGiven[i][1].toString();
  }

  prefs.setString('initialBoard', initialString);
  prefs.setString('currentBoard', currentString);
  prefs.setString('finalBoard', finalString);
  prefs.setString('hintsGiven', hintString);
}

Future<bool> applyGameState() async {
  final prefs = await SharedPreferences.getInstance();
  final initialString = prefs.getString('initialBoard') ?? '';
  final currentString = prefs.getString('currentBoard') ?? '';
  final finalString = prefs.getString('finalBoard') ?? '';
  final hintString = prefs.getString('hintsGiven') ?? '';
  // SudokuProblem problem;
  List initialBoard = List.generate(9, (i) => List(9), growable: false);
  List currentBoard = List.generate(9, (i) => List(9), growable: false);
  List finalBoard = List.generate(9, (i) => List(9), growable: false);

  if (initialString != '' && currentString != '' && finalString != '') {
    for (int i = 0; i < initialString.length; i++) {
      initialBoard[i ~/ 9][i % 9] = int.parse(initialString[i]);
      currentBoard[i ~/ 9][i % 9] = int.parse(currentString[i]);
      finalBoard[i ~/ 9][i % 9] = int.parse(finalString[i]);
    }
    globals.problem =
        SudokuProblem.resume(initialBoard, currentBoard, finalBoard);
  }

  globals.hintsGiven = [];
  for (var i = 0; i < hintString.length ~/ 2; i++) {
    int row = int.parse(hintString[i * 2]);
    int col = int.parse(hintString[i * 2 + 1]);
    globals.hintsGiven.add([row, col]);
  }

  return true;
}

double getBodyWidth(context) {
  EdgeInsets padding = MediaQuery.of(context).padding;
  double width = MediaQuery.of(context).size.width -
      padding.horizontal -
      2 * globals.bodySpacing;
  double height = MediaQuery.of(context).size.height -
      padding.vertical -
      2 * globals.bodySpacing;
  double aspect = 15 / 23;
  return width / height < aspect ? width : height * aspect;
}

MaterialColor getMaterialColor(Color color) {
  int colorInt = color.value;
  return MaterialColor(colorInt, <int, Color>{
    50: color,
    100: color,
    200: color,
    300: color,
    400: color,
    500: color,
    600: color,
    700: color,
    800: color,
    900: color,
  });
}
