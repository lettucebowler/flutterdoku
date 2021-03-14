import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';

VariableWrapper doPeerCells = VariableWrapper(true);
VariableWrapper doPeerDigits = VariableWrapper(true);
VariableWrapper doMistakes = VariableWrapper(true);

VariableWrapper maxHints = VariableWrapper(5);
VariableWrapper initialHints = VariableWrapper(30);
VariableWrapper legalityRadio = VariableWrapper(0);
VariableWrapper selectionRadio = VariableWrapper(0);
int selectedRow = -1;
int selectedCol = -1;
int selectedNum = -1;
double bodySpacing = 2;
List hintsGiven = [];
List movesDone = [];
SudokuProblem problem = new SudokuProblem();

class VariableWrapper {
  var value;
  VariableWrapper(var value) {
    this.value = value;
  }
}

class Move {
  late int oldNum;
  late int newNum;
  late int row;
  late int col;

  Move(oldNum, newNum, row, col) {
    this.oldNum = oldNum;
    this.newNum = newNum;
    this.row = row;
    this.col = col;
  }
}
