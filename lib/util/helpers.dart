import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettuce_sudoku/util/globals.dart';

Future<bool> readFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final peerCells = prefs.getBool('doPeerCells');
  final peerDigits = prefs.getBool('doPeerDigits');
  final mistakes = prefs.getBool('doMistakes');
  final cellNow = prefs.getInt('cellFirst');
  final hints = prefs.getInt('initialHints');
  final legality = prefs.getInt('legalityRadio');

  final hintsGood = hints != null && hints >= 17 && hints <= 50;

  doPeerCells.value = peerCells ?? true;
  doPeerDigits.value = peerDigits ?? true;
  doMistakes.value = mistakes ?? true;
  initialHints.value = hintsGood ? hints : 30;
  legalityRadio.value = legality == 1 || legality == 0 ? legality : 0;
  selectionRadio.value = cellNow ?? 0;
  return true;
}

saveToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final legality = legalityRadio.value;
  final cells = doPeerCells.value;
  final digits = doPeerDigits.value;
  final mistakes = doMistakes.value;
  final hints = initialHints.value;
  final cellNow = selectionRadio.value;
  prefs.setBool('doPeerCells', cells);
  prefs.setBool('doPeerDigits', digits);
  prefs.setBool('doMistakes', mistakes);
  prefs.setInt('cellFirst', cellNow);
  prefs.setInt('legalityRadio', legality);
  prefs.setInt('initialHints', hints);
}

saveGame() async {
  final prefs = await SharedPreferences.getInstance();
  String initialString = "";
  String currentString = "";
  String finalString = "";
  SudokuState initialState = problem.getInitialState();
  List initialBoard = initialState.getTiles();
  SudokuState currentState = problem.getCurrentState();
  List currentBoard = currentState.getTiles();
  SudokuState finalState = problem.getFinalState();
  List finalBoard = finalState.getTiles();

  for (int i = 0; i < problem.board_size; i++) {
    for (int j = 0; j < problem.board_size; j++) {
      initialString += initialBoard[i][j].toString();
      currentString += currentBoard[i][j].toString();
      finalString += finalBoard[i][j].toString();
    }
  }

  String hintString = '';
  for (var i = 0; i < hintsGiven.length; i++) {
    hintString += hintsGiven[i][0].toString();
    hintString += hintsGiven[i][1].toString();
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
  List initialBoard = List.generate(9, (i) => List(9), growable: false);
  List currentBoard = List.generate(9, (i) => List(9), growable: false);
  List finalBoard = List.generate(9, (i) => List(9), growable: false);

  if (initialString != '' && currentString != '' && finalString != '') {
    for (int i = 0; i < initialString.length; i++) {
      initialBoard[i ~/ 9][i % 9] = int.parse(initialString[i]);
      currentBoard[i ~/ 9][i % 9] = int.parse(currentString[i]);
      finalBoard[i ~/ 9][i % 9] = int.parse(finalString[i]);
    }
    problem = SudokuProblem.resume(initialBoard, currentBoard, finalBoard);
  }

  hintsGiven = [];
  for (var i = 0; i < hintString.length ~/ 2; i++) {
    int row = int.parse(hintString[i * 2]);
    int col = int.parse(hintString[i * 2 + 1]);
    hintsGiven.add([row, col]);
  }

  return true;
}

double getBodyWidth(context) {
  EdgeInsets padding = MediaQuery.of(context).padding;
  double width =
      MediaQuery.of(context).size.width - padding.horizontal - 2 * bodySpacing;
  double height =
      MediaQuery.of(context).size.height - padding.vertical - 2 * bodySpacing;
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

int getIndex(int row, int col, int rowLength) {
  return row * rowLength + col % rowLength;
}
