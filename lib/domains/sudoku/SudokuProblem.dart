import '../../framework/problem/Problem.dart';
import 'Sudoku.dart';
import 'SudokuState.dart';
import 'SudokuMover.dart';

class SudokuProblem extends Problem {
  late Sudoku sudoku;
  late int cellSize;
  late int boardSize;

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
    cellSize = 3;
    boardSize = cellSize * cellSize;
    super.setMover(SudokuMover(cellSize * cellSize));
    super.setInitialState(SudokuState(sudoku.initialBoard));
    super.setCurrentState(super.getInitialState());
    super.setFinalState(SudokuState(sudoku.finalBoard));
  }

  SudokuProblem.withMoreHints(int hintOffset) : super() {
    cellSize = 3;
    boardSize = cellSize * cellSize;
    super.setName('Sudoku');
    super.setIntroduction(
        'Place the numbers 1-9 in each of the three 3x3 grids. '
        'Each row must contain each number 1-9. '
        'Each Column must contain each number 1-9'
        'for each cell in the grid, there can be no other cell with the same '
        'row or column that contains the same number. '
        'The game is finished when the grid is full.');
    sudoku = Sudoku.withMoreHints(hintOffset);
    super.setMover(SudokuMover(cellSize * cellSize));
    super.setInitialState(SudokuState(sudoku.initialBoard));
    super.setCurrentState(super.getInitialState());
    super.setFinalState(SudokuState(sudoku.finalBoard));
  }

  SudokuProblem.resume(List initialBoard, List currentBoard, List finalBoard)
      : super() {
    super.setName('Sudoku');
    super.setIntroduction(
        'Place the numbers 1-9 in each of the three 3x3 grids. '
        'Each row must contain each number 1-9. '
        'Each Column must contain each number 1-9'
        'for each cell in the grid, there can be no other cell with the same '
        'row or column that contains the same number. '
        'The game is finished when the grid is full.');
    cellSize = 3;
    boardSize = cellSize * cellSize;
    // sudoku = Sudoku.(cell_size, hint_offset, initial_board, final_board);
    super.setMover(SudokuMover(cellSize * cellSize));
    super.setInitialState(SudokuState(initialBoard));
    super.setCurrentState(SudokuState(currentBoard));
    super.setFinalState(SudokuState(finalBoard));
  }

  Sudoku getSudoku() {
    return sudoku;
  }

  bool isInitialHint(int row, int col) {
    var state = getInitialState() as SudokuState;
    return (state.getTiles()[row][col] != 0);
  }

  bool isCorrect(int row, int col) {
    var current = getCurrentState() as SudokuState;
    var goal = getFinalState() as SudokuState;
    return (current.getTiles()[row][col] == goal.getTiles()[row][col]);
  }

  bool isLegal(int row, int col) {
    return !(_checkRowForDuplicates(row, col) ||
        _checkColForDuplicates(row, col) ||
        _checkBlockForDuplicates(row, col));
  }

  bool _checkRowForDuplicates(int row, int col) {
    var currentState = getCurrentState() as SudokuState;
    var currentTiles = currentState.getTiles();
    var count = 0;
    for (int i = 0; i < boardSize; i++) {
      if (currentTiles[row][i] == currentTiles[row][col]) {
        count++;
      }
    }
    return count > 1;
  }

  bool _checkColForDuplicates(int row, int col) {
    var current_state = getCurrentState() as SudokuState;
    var currentTiles = current_state.getTiles();
    var count = 0;
    for (var i = 0; i < boardSize; i++) {
      if (currentTiles[i][col] == currentTiles[row][col]) {
        count++;
      }
    }
    return count > 1;
  }

  bool _checkBlockForDuplicates(int row, int col) {
    var currentState = getCurrentState() as SudokuState;
    var currentTiles = currentState.getTiles();
    var count = 0;
    var startRow = row ~/ cellSize * cellSize;
    var startCol = col ~/ cellSize * cellSize;
    for (var i = 0; i < cellSize; i++) {
      for (var j = 0; j < cellSize; j++) {
        if (currentTiles[startRow + i][startCol + j] ==
            currentTiles[row][col]) {
          count++;
        }
      }
    }
    return count > 1;
  }

  bool checkRowCompletion(int row) {
    var complete = true;
    var currentState = getCurrentState() as SudokuState;
    var finalState = getFinalState() as SudokuState;
    var currentTiles = currentState.getTiles();
    var finalTiles = finalState.getTiles();
    for (var i = 0; i < currentTiles.length; i++) {
      if (currentTiles[row][i] != finalTiles[row][i]) {
        complete = false;
        break;
      }
    }
    return complete;
  }

  bool checkColCompletion(int col) {
    var complete = true;
    var currentState = getCurrentState() as SudokuState;
    var finalState = getFinalState() as SudokuState;
    var currentTiles = currentState.getTiles();
    var finalTiles = finalState.getTiles();
    for (var i = 0; i < currentTiles.length; i++) {
      if (currentTiles[i][col] != finalTiles[i][col]) {
        complete = false;
        break;
      }
    }
    return complete;
  }

  bool checkBlockCompletion(int row, int col) {
    var complete = true;
    var currentState = getCurrentState() as SudokuState;
    var finalState = getFinalState() as SudokuState;
    var currentTiles = currentState.getTiles();
    var finalTiles = finalState.getTiles();
    var startRow = row ~/ cellSize * cellSize;
    var startCol = col ~/ cellSize * cellSize;
    for (var i = 0; i < cellSize; i++) {
      for (var j = 0; j < cellSize; j++) {
        if (currentTiles[startRow + i][startCol + j] !=
            finalTiles[startRow + i][startCol + j]) {
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
    for (var i = 0; i < cellSize; i++) {
      buffer.write(space);
      buffer.write(divider);
      space = '\n';
      for (var j = 0; j < cellSize; j++) {
        buffer.write(space);
        buffer.write(_rowToString(board[(i * cellSize + j) % boardSize]));
      }
    }
    buffer.write(space + divider);
    return buffer.toString();
  }

  String _rowToString(List board) {
    var buffer = StringBuffer();
    var spacer = '';
    for (var i = 0; i < boardSize; i++) {
      if (i % cellSize == 0) {
        spacer = '|';
      }

      buffer.write(spacer);
      var toPlace = board[i] == 0 ? ' ' : board[i];
      buffer.write(toPlace);
      spacer = ' ';
    }
    buffer.write('|');
    return buffer.toString();
  }

  String _makeDivider() {
    var buffer = StringBuffer();
    for (var i = 0; i < cellSize + 1; i++) {
      buffer.write('+');
      if (i < cellSize) {
        for (var j = 0; j < cellSize * 2 - 1; j++) {
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
