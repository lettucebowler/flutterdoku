import 'package:flutter/material.dart';
import 'package:dartdoku/domains/sudoku/SudokuProblem.dart';
import 'package:dartdoku/domains/sudoku/SudokuState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:dartdoku/dartdoku.dart' as dartdoku;

Future<bool> readFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final peerCells = prefs.getBool('doPeerCells');
  final peerDigits = prefs.getBool('doPeerDigits');
  final mistakes = prefs.getBool('doMistakes');
  final cellNow = prefs.getInt('cellFirst');
  final hints = prefs.getInt('initialHints');
  final hintsGood = hints != null && hints >= 17 && hints <= 50;

  doPeerCells.value = peerCells ?? true;
  doPeerDigits.value = peerDigits ?? true;
  doMistakes.value = mistakes ?? true;
  initialHints.value = hintsGood ? hints : 30;
  selectionRadio.value = cellNow ?? 0;
  return true;
}

saveToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final cells = doPeerCells.value;
  final digits = doPeerDigits.value;
  final mistakes = doMistakes.value;
  final hints = initialHints.value;
  final cellNow = selectionRadio.value;
  prefs.setBool('doPeerCells', cells);
  prefs.setBool('doPeerDigits', digits);
  prefs.setBool('doMistakes', mistakes);
  prefs.setInt('cellFirst', cellNow);
  prefs.setInt('initialHints', hints);
}

saveGame() async {
  final prefs = await SharedPreferences.getInstance();
  SudokuState initialState = problem.initialState;
  SudokuState currentState = problem.currentState;
  SudokuState finalState = problem.finalState;

  var initialString = SudokuProblem.boardToString(initialState);
  var currentString = SudokuProblem.boardToString(currentState);
  var finalString = SudokuProblem.boardToString(finalState);

  String moveString = '';
  for (Move move in movesDone) {
    moveString += move.oldNum.toString();
    moveString += move.newNum.toString();
    moveString += move.row.toString();
    moveString += move.col.toString();
  }

  prefs.setString('initialBoard', initialString);
  prefs.setString('currentBoard', currentString);
  prefs.setString('finalBoard', finalString);
  prefs.setString('movesDone', moveString);
}

Future<bool> applyGameState() async {
  final prefs = await SharedPreferences.getInstance();
  final initialString = prefs.getString('initialBoard') ?? '';
  final currentString = prefs.getString('currentBoard') ?? '';
  final finalString = prefs.getString('finalBoard') ?? '';
  final moveString = prefs.getString('movesDone') ?? '';

  if (initialString != '' && currentString != '' && finalString != '') {
    var initialState = SudokuState.fromString(initialString);
    var currentState = SudokuState.fromString(currentString);
    var finalState = SudokuState.fromString(finalString);
    problem = SudokuProblem.fromStates(initialState, currentState, finalState);
  }

  movesDone = [];
  for (var i = 0; i < moveString.length ~/ 4; i++) {
    int oldNum = int.parse(moveString[i * 4]);
    int newNum = int.parse(moveString[i * 4 + 1]);
    int row = int.parse(moveString[i * 4 + 2]);
    int col = int.parse(moveString[i * 4 + 3]);
    movesDone.add(Move(oldNum, newNum, row, col));
  }

  return true;
}

addGame(SudokuProblem p, int i) {
  problems.add(p);
  print('adding game to list');
  if (i == 2) {
    makingGames = false;
  }
}

Future<SudokuProblem> getNextGame() async {
  return await dartdoku.getProblem(initialHints.value);
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

Color getTextColor(int row, int col, SudokuProblem problem) {
  var initialHint = problem.isInitialHint(row, col);
  var legal = problem.isLegal(row, col);
  var doLegality = doMistakes.value;
  Color color = CustomStyles.nord10;

  color = doLegality && !legal ? CustomStyles.nord11 : color;
  color = initialHint ? CustomStyles.nord3 : color;
  return color;
}

bool cellSelected() {
  var rowGood = selectedRow > -1 && selectedRow < 9;
  var colGood = selectedCol > -1 && selectedCol < 9;
  return rowGood && colGood;
}

Color getCellColor(int row, int col) {
  Color peerCell = CustomStyles.nord8;
  Color background = CustomStyles.nord6;
  Color peerDigit = CustomStyles.nord9;
  Color success = CustomStyles.nord14;
  Color wrong = CustomStyles.nord12;
  Color selected = CustomStyles.nord13;
  Color color = background;

  var currentState = problem.currentState;
  List currentBoard = currentState.board;

  bool rowSelected = row == selectedRow;
  bool colSelected = col == selectedCol;
  bool isSelected = rowSelected && colSelected;

  bool floorSelected =
      row ~/ problem.cellSize == selectedRow ~/ problem.cellSize;
  bool towerSelected =
      col ~/ problem.cellSize == selectedCol ~/ problem.cellSize;
  bool blockSelected = floorSelected && towerSelected;

  bool doCells = doPeerCells.value;
  bool doDigits = doPeerDigits.value;
  bool isPeerCell = cellSelected() &&
      !isSelected &&
      (rowSelected || colSelected || blockSelected);
  bool nonZero = cellSelected() && currentBoard[row][col] != 0;
  bool isPeerDigit = cellSelected() &&
      currentBoard[row][col] == currentBoard[selectedRow][selectedCol] &&
      nonZero;
  bool peerCellNotPeerDigit = isPeerCell && !isPeerDigit;

  if (problem.success()) {
    return success;
  } else if (cellSelected()) {
    if (peerCellNotPeerDigit && doCells) {
      return peerCell;
    } else if (isPeerDigit && nonZero && !isSelected && doDigits) {
      return isPeerCell && !problem.isLegal(row, col) && doMistakes.value
          ? wrong
          : peerDigit;
    } else if (isSelected) {
      return selected;
    } else {
      return color;
    }
  } else {
    return color;
  }
}

EdgeInsets getBoardPadding(int index) {
  var row = index ~/ problem.boardSize;
  var col = index % problem.boardSize;
  var thickness = 2.0;
  var defaultThickness = 0.5;

  var isTop = row == 0;
  var isLeft = col == 0;
  var isInnerBottom = row % problem.cellSize == problem.cellSize - 1;
  var isInnerRight = col % problem.cellSize == problem.cellSize - 1;
  var isBottom = row == problem.boardSize - 1;
  var isRight = col == problem.boardSize - 1;

  var top = isTop ? thickness + defaultThickness : defaultThickness;
  var left = isLeft ? thickness + defaultThickness : defaultThickness;

  var right = defaultThickness;
  if (isRight) {
    right = thickness + defaultThickness;
  } else if (isInnerRight) {
    right = thickness;
  }

  var bottom = defaultThickness;
  if (isBottom) {
    bottom = thickness + defaultThickness;
  } else if (isInnerBottom) {
    bottom = thickness;
  }

  return EdgeInsets.fromLTRB(
      left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
}

void resetGlobals() {
  selectedRow = -1;
  selectedCol = -1;
  selectedNum = -1;
  movesDone.clear();
}

bool digitGood(int num) {
  return num > -1 && num <= 10;
}
