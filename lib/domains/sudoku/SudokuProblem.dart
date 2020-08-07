import '../../framework/problem/Problem.dart';
import 'Sudoku.dart';
import 'SudokuState.dart';
import 'SudokuMover.dart';

class SudokuProblem extends Problem {
  Sudoku sudoku;
  int cell_size;
  int board_size;

  SudokuProblem() : super() {
    super.setName('Sudoku');
    super.setIntroduction(
        'Place the numbers 1-9 in each of the three 3x3 grids. '
        'Each row must contain each number 1-9. '
        'Each Column must contain each number 1-9'
        'for each cell in the grid, there can be no other cell with the same '
        'row or column that contains the same number. '
        'The game is finished when the grid is full.');
    sudoku = Sudoku();
    cell_size = 3;
    board_size = cell_size * cell_size;
    super.setMover(SudokuMover(cell_size * cell_size));
    super.setInitialState(SudokuState(sudoku.initial_board));
    super.setCurrentState(super.getInitialState());
    super.setFinalState(SudokuState(sudoku.final_board));
  }

  SudokuProblem.withMoreHints(int hint_offset) : super() {
    cell_size = 3;
    board_size = cell_size * cell_size;
    super.setName('Sudoku');
    super.setIntroduction(
        'Place the numbers 1-9 in each of the three 3x3 grids. '
        'Each row must contain each number 1-9. '
        'Each Column must contain each number 1-9'
        'for each cell in the grid, there can be no other cell with the same '
        'row or column that contains the same number. '
        'The game is finished when the grid is full.');
    sudoku = Sudoku.withMoreHints(hint_offset);
    super.setMover(SudokuMover(cell_size * cell_size));
    super.setInitialState(SudokuState(sudoku.initial_board));
    super.setCurrentState(super.getInitialState());
    super.setFinalState(SudokuState(sudoku.final_board));
  }

  SudokuProblem.resume(
      int hint_offset, List initial_board, List current_board, List final_board)
      : super() {
    super.setName('Sudoku');
    super.setIntroduction(
        'Place the numbers 1-9 in each of the three 3x3 grids. '
        'Each row must contain each number 1-9. '
        'Each Column must contain each number 1-9'
        'for each cell in the grid, there can be no other cell with the same '
        'row or column that contains the same number. '
        'The game is finished when the grid is full.');
    cell_size = 3;
    board_size = cell_size * cell_size;
    // sudoku = Sudoku.(cell_size, hint_offset, initial_board, final_board);
    super.setMover(SudokuMover(cell_size * cell_size));
    super.setInitialState(SudokuState(initial_board));
    super.setCurrentState(SudokuState(current_board));
    super.setFinalState(SudokuState(final_board));
  }

  Sudoku getSudoku() {
    return sudoku;
  }

  bool isInitialHint(int row, int col) {
    SudokuState state = getInitialState();
    return (state.getTiles()[row][col] != 0);
  }

  bool isCorrect(int row, int col) {
    SudokuState current = getCurrentState();
    SudokuState goal = getFinalState();
    return (current.getTiles()[row][col] == goal.getTiles()[row][col]);
  }

  bool isLegal(int row, int col) {
    return !(_checkRowForDuplicates(row, col) ||
        _checkColForDuplicates(row, col) ||
        _checkBlockForDuplicates(row, col));
  }

  bool _checkRowForDuplicates(int row, int col) {
    SudokuState current_state = getCurrentState();
    var current_tiles = current_state.getTiles();
    var count = 0;
    for (int i = 0; i < board_size; i++) {
      if (current_tiles[row][i] == current_tiles[row][col]) {
        count++;
      }
    }
    return count > 1;
  }

  bool _checkColForDuplicates(int row, int col) {
    SudokuState current_state = getCurrentState();
    var current_tiles = current_state.getTiles();
    var count = 0;
    for (var i = 0; i < board_size; i++) {
      if (current_tiles[i][col] == current_tiles[row][col]) {
        count++;
      }
    }
    return count > 1;
  }

  bool _checkBlockForDuplicates(int row, int col) {
    SudokuState current_state = getCurrentState();
    var current_tiles = current_state.getTiles();
    var count = 0;
    var start_row = row ~/ cell_size * cell_size;
    var start_col = col ~/ cell_size * cell_size;
    for (var i = 0; i < cell_size; i++) {
      for (var j = 0; j < cell_size; j++) {
        if (current_tiles[start_row + i][start_col + j] ==
            current_tiles[row][col]) {
          count++;
        }
      }
    }
    return count > 1;
  }

  bool checkRowCompletion(int row) {
    var complete = true;
    SudokuState current_state = getCurrentState();
    SudokuState final_state = getFinalState();
    var current_tiles = current_state.getTiles();
    var final_tiles = final_state.getTiles();
    for (var i = 0; i < current_tiles.length; i++) {
      if (current_tiles[row][i] != final_tiles[row][i]) {
        complete = false;
        break;
      }
    }
    return complete;
  }

  bool checkColCompletion(int col) {
    var complete = true;
    SudokuState current_state = getCurrentState();
    SudokuState final_state = getFinalState();
    var current_tiles = current_state.getTiles();
    var final_tiles = final_state.getTiles();
    for (var i = 0; i < current_tiles.length; i++) {
      if (current_tiles[i][col] != final_tiles[i][col]) {
        complete = false;
        break;
      }
    }
    return complete;
  }

  bool checkBlockCompletion(int row, int col) {
    var complete = true;
    SudokuState current_state = getCurrentState();
    SudokuState final_state = getFinalState();
    var current_tiles = current_state.getTiles();
    var final_tiles = final_state.getTiles();
    var start_row = row ~/ cell_size * cell_size;
    var start_col = col ~/ cell_size * cell_size;
    for (var i = 0; i < cell_size; i++) {
      for (var j = 0; j < cell_size; j++) {
        if (current_tiles[start_row + i][start_col + j] !=
            final_tiles[start_row + i][start_col + j]) {
          complete = false;
        }
      }
    }
    return complete;
  }

  String getStateAsString(SudokuState state) {
    var board = state.getTiles();
    return _boardToString(board);
  }

  String _boardToString(List board) {
    var buffer = StringBuffer();
    var space = '';
    var divider = _makeDivider();
    for (var i = 0; i < cell_size; i++) {
      buffer.write(space);
      buffer.write(divider);
      space = '\n';
      for (var j = 0; j < cell_size; j++) {
        buffer.write(space);
        buffer.write(_rowToString(board[(i * cell_size + j) % board_size]));
      }
    }
    buffer.write(space + divider);
    return buffer.toString();
  }

  String _rowToString(List board) {
    var buffer = StringBuffer();
    var spacer = '';
    for (var i = 0; i < board_size; i++) {
      if (i % cell_size == 0) {
        spacer = '|';
      }

      buffer.write(spacer);
      var to_place = board[i] == 0 ? ' ' : board[i];
      buffer.write(to_place);
      spacer = ' ';
    }
    buffer.write('|');
    return buffer.toString();
  }

  String _makeDivider() {
    var buffer = StringBuffer();
    for (var i = 0; i < cell_size + 1; i++) {
      buffer.write('+');
      if (i < cell_size) {
        for (var j = 0; j < cell_size * 2 - 1; j++) {
          buffer.write('-');
        }
      }
    }
    return buffer.toString();
  }

  @override
  bool success() {
    return getCurrentState().equals(getFinalState());
  }
}
