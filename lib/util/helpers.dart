import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';

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

  for (int i = 0; i < problem.boardSize; i++) {
    for (int j = 0; j < problem.boardSize; j++) {
      initialString += initialBoard[i][j].toString();
      currentString += currentBoard[i][j].toString();
      finalString += finalBoard[i][j].toString();
    }
  }

  String hintString = '';
  for (List pair in hintsGiven) {
    hintString += pair[0].toString();
    hintString += pair[1].toString();
  }

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
  prefs.setString('hintsGiven', hintString);
  prefs.setString('movesDone', moveString);
}

Future<bool> applyGameState() async {
  final prefs = await SharedPreferences.getInstance();
  final initialString = prefs.getString('initialBoard') ?? '';
  final currentString = prefs.getString('currentBoard') ?? '';
  final finalString = prefs.getString('finalBoard') ?? '';
  final hintString = prefs.getString('hintsGiven') ?? '';
  final moveString = prefs.getString('movesDone') ?? '';
  List initialBoard = List.generate(9, (i) => []..length = 9);
  List currentBoard = List.generate(9, (i) => []..length = 9);
  List finalBoard = List.generate(9, (i) => []..length = 9);

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
  var correct = problem.isCorrect(row, col);
  var doLegality = legalityRadio.value == 1;
  Color color = CustomStyles.nord10;

  color =
      doMistakes.value && doLegality && !legal ? CustomStyles.nord11 : color;
  color =
      doMistakes.value && !doLegality && !correct ? CustomStyles.nord11 : color;
  color = initialHint ? CustomStyles.nord3 : color;
  color = givenAsHint(row, col) ? CustomStyles.nord3 : color;
  return color;
}

bool givenAsHint(int row, int col) {
  bool hint = false;
  for (List pair in hintsGiven) {
    if (pair[0] == row && pair[1] == col) {
      hint = true;
      break;
    }
  }
  return hint;
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

  var currentState = problem.getCurrentState();
  List currentBoard = currentState.getTiles();

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
  var thickness = 2;
  var defaultThickness = 0.5;
  var isTop = row == 0;
  var isLeft = col == 0;
  var isBottom = row % problem.cellSize == problem.cellSize - 1;
  var isRight = col % problem.cellSize == problem.cellSize - 1;
  var top = isTop ? thickness : defaultThickness;
  var left = isLeft ? thickness : defaultThickness;
  var bottom = isBottom ? thickness : defaultThickness;
  var right = isRight ? thickness : defaultThickness;

  return EdgeInsets.fromLTRB(
      left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
}

void resetGlobals() {
  selectedRow = -1;
  selectedCol = -1;
  selectedNum = -1;
  hintsGiven.clear();
  movesDone.clear();
}

bool digitGood(int num) {
  return num > -1 && num <= 10;
}
