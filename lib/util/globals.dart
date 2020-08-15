import 'package:flutter/material.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';

// BoolWrapper doLegality = BoolWrapper(false);
VariableWrapper doPeerCells = VariableWrapper(true);
VariableWrapper doPeerDigits = VariableWrapper(true);
VariableWrapper doMistakes = VariableWrapper(true);
VariableWrapper maxHints = VariableWrapper(5);
VariableWrapper initialHints = VariableWrapper(30);
VariableWrapper legalityRadio = VariableWrapper(0);
int selectedRow = -1;
int selectedCol = -1;
double bodySpacing = 4;
List hintsGiven = [];
SudokuProblem problem;

var settingsMap = {
  'doPeerCells': doPeerCells,
  'doPeerDigits': doPeerDigits,
  'doMistakes': doMistakes,
  'initialHints': initialHints,
  'legalityRadio': legalityRadio
};

// class BoolWrapper {
//   bool value;
//   BoolWrapper(bool value) {
//     this.value = value;
//   }
// }

// class IntWrapper extends VariableWrapper{
//   // int value;
//   IntWrapper(int value) {
//     this.value = value;
//   }
// }

class VariableWrapper {
  var value;
  VariableWrapper(var value) {
    this.value = value;
  }
}

Widget mistakesWidget;
