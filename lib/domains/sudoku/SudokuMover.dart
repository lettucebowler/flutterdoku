import 'dart:core';

import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:lettuce_sudoku/framework/problem/Mover.dart';
import 'package:lettuce_sudoku/framework/problem/State.dart';

class SudokuMover extends Mover {
  SudokuMover(int boardSize) {
    for (var i = 0; i <= boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        for (var k = 0; k < boardSize; k++) {
          super.addMove(
              'Place ' +
                  i.toString() +
                  ' at ' +
                  j.toString() +
                  ' ' +
                  k.toString(),
              (e) => _tryMove(i, j, k, e));
        }
      }
    }
  }

  SudokuState _tryMove(
      final int num, final int row, final int col, final State state1) {
    final SudokuState state2 = state1;

    // Check that input number is valid
    if (num < 0 || num > state2.getTiles().length) {
      return null;
    }

    return SudokuState.applyMove(state2, num, row, col);
  }
}
