import 'dart:core';
import '../../framework/problem/State.dart';

/*
 * This class represents states of various tile-moving puzzle problems,
 * including the 8-Puzzle, which involves a 3x3 display area. It can also
 * represent other displays of different dimensions, e.g. 4x4. A puzzle state is
 * represented with a 2D array of integers.
 *
 */
class SudokuState implements State {
  /*
     * A 2D integer array represents the sudoku board.
     */
  late List tiles;

  /*
     * Getter for the underlying 2D array. Most users of this class will not
     * access these representation details. This will be useful when the problem
     * solving framework adds heuristic search to its abilities.
     *
     * @return the underlying 2D array
     */
  List getTiles() {
    return tiles;
  }

  // A puzzle state constructor that accepts a 2D array of integers.
  // @param tiles a 2d array of integers
  SudokuState(List tiles) {
    this.tiles = tiles;
  }

  // A SudokuState constructor that takes a given state, a number, and it's position represented
  // as a row and column integer.
  // and returns a new state with given number in given position, overwriting previous tiles
  // if necessary. The original puzzle state is not changed.
  // @param state an existing puzzle state
  // @throws ArrayIndexOutOfBoundsException if either location is invalid for
  // this state
  SudokuState.applyMove(SudokuState state, int num, int row, int col) {
    tiles = _copyTiles(state.tiles);
    tiles[row][col] = num;
  }

  // Tests for equality of this puzzle state with another.
  // @param o the other state
  // @return true if the underlying arrays are equal, false otherwise
  @override
  bool equals(Object? o) {
    if (o == null) {
      return false;
    }
    if (o.runtimeType != SudokuState) {
      return false;
    }
    SudokuState other = o as SudokuState;
    if (this == other) {
      return true;
    }
    var equal = true;
    for (var i = 0; i < tiles.length; i++) {
      for (var j = 0; j < tiles.length; j++) {
        if (tiles[i][j] != other.getTiles()[i][j]) {
          equal = false;
        }
      }
    }
    return equal;
  }

  static List _copyTiles(List source) {
    var rows = source.length;
    var columns = source[0].length;
    var dest = []..length = rows;
    for (var r = 0; r < rows; r++) {
      dest[r] = []..length = columns;
      for (var c = 0; c < columns; c++) {
        dest[r][c] = source[r][c];
      }
    }
    return dest;
  }
}
