import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';

VariableWrapper doPeerCells = VariableWrapper(true);
VariableWrapper doPeerDigits = VariableWrapper(true);
VariableWrapper doMistakes = VariableWrapper(true);
VariableWrapper maxHints = VariableWrapper(5);
VariableWrapper initialHints = VariableWrapper(30);
VariableWrapper legalityRadio = VariableWrapper(0);
int selectedRow = -1;
int selectedCol = -1;
double bodySpacing = 2;
List hintsGiven = [];
SudokuProblem problem;

class VariableWrapper {
  var value;
  VariableWrapper(var value) {
    this.value = value;
  }
}
