import 'dart:core';
import '../../framework/problem/Mover.dart';
import '../../framework/problem/State.dart';
import 'SudokuState.dart';

class SudokuMover extends Mover {
  SudokuMover(int board_size) {
    for (var i = 0; i <= board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        for (var k = 0; k < board_size; k++) {
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
