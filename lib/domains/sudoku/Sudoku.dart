import 'dart:math';

class Sudoku {
  int board_size;
  int cell_size;
  int hint_offset;
  List initial_board;
  List final_board;

  Sudoku() {
    _initialize();
    _scrambleBoards();
    _addClues(hint_offset);
  }

  Sudoku.withMoreHints(int hint_offset) {
    _initialize();
    this.hint_offset = hint_offset;
    _scrambleBoards();
    _addClues(hint_offset);
  }

  void _initialize() {
    cell_size = 3;
    board_size = cell_size * cell_size;
    hint_offset = 0;
    var root = [
      [
        // Board 1
        [
          [0, 0, 0, 8, 0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 4, 3],
          [5, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 7, 0, 8, 0, 0],
          [0, 0, 0, 0, 0, 0, 1, 0, 0],
          [0, 2, 0, 0, 3, 0, 0, 0, 0],
          [6, 0, 0, 0, 0, 0, 0, 7, 5],
          [0, 0, 3, 4, 0, 0, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 6, 0, 0]
        ],
        [
          [2, 3, 7, 8, 4, 1, 5, 6, 9],
          [1, 8, 6, 7, 9, 5, 2, 4, 3],
          [5, 9, 4, 3, 2, 6, 7, 1, 8],
          [3, 1, 5, 6, 7, 4, 8, 9, 2],
          [4, 6, 9, 5, 8, 2, 1, 3, 7],
          [7, 2, 8, 1, 3, 9, 4, 5, 6],
          [6, 4, 2, 9, 1, 8, 3, 7, 5],
          [8, 5, 3, 4, 6, 7, 9, 2, 1],
          [9, 7, 1, 2, 5, 3, 6, 8, 4]
        ]
      ],
      //Board 2
      [
        [
          [0, 0, 0, 7, 0, 0, 0, 0, 0],
          [1, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 4, 3, 0, 2, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 6],
          [0, 0, 0, 5, 0, 9, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 4, 1, 8],
          [0, 0, 0, 0, 8, 1, 0, 0, 0],
          [0, 0, 2, 0, 0, 0, 0, 5, 0],
          [0, 4, 0, 0, 0, 0, 3, 0, 0]
        ],
        [
          [2, 6, 4, 7, 1, 5, 8, 3, 9],
          [1, 3, 7, 8, 9, 2, 6, 4, 5],
          [5, 9, 8, 4, 3, 6, 2, 7, 1],
          [4, 2, 3, 1, 7, 8, 5, 9, 6],
          [8, 1, 6, 5, 4, 9, 7, 2, 3],
          [7, 5, 9, 6, 2, 3, 4, 1, 8],
          [3, 7, 5, 2, 8, 1, 9, 6, 4],
          [9, 8, 2, 3, 6, 4, 1, 5, 7],
          [6, 4, 1, 9, 5, 7, 3, 8, 2]
        ]
      ]
    ];
    var root_pos = _getRandom(root.length);
    initial_board = root[root_pos][0];
    final_board = root[root_pos][1];
  }

  void _scrambleBoards() {
    _scrambleRows();
    _scrambleCols();
    _scrambleFloors();
    _scrambleTowers();
    _randomizeDigits();
    _transposeBoards();
    _rotateBoards();
  }

  void _addClues(int hint_offset) {
    var pos1;
    var pos2;
    var i;
    for (i = 0; i < hint_offset; i++) {
      do {
        pos1 = _getRandom(board_size);
        pos2 = _getRandom(board_size);
      } while (initial_board[pos1][pos2] != 0);
      initial_board[pos1][pos2] = final_board[pos1][pos2];
      if (initial_board[pos2][pos1] == 0) {
        initial_board[pos2][pos1] = final_board[pos2][pos1];
        i++;
      }
    }
  }

  void _transposeBoards() {
    var r = _getRandom(2);
    if (r % 2 == 0) {
      _transposeBoard(initial_board);
      _transposeBoard(final_board);
    }
  }

  void _transposeBoard(List board) {
    var temp = List(board_size);
    for (var i = 0; i < board_size; i++) {
      temp[i] = List(board_size);
    }
    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        temp[i][j] = board[j][i];
      }
    }
    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        board[i][j] = temp[i][j];
      }
    }
  }

  void _rotateBoards() {
    var rotations = _getRandom(4);
    for (var i = 0; i < rotations; i++) {
      _rotateBoard(board_size, initial_board);
      _rotateBoard(board_size, final_board);
    }
  }

  void _rotateBoard(int N, List board) {
    for (var x = 0; x < N / 2; x++) {
      for (var y = x; y < N - x - 1; y++) {
        var temp = board[x][y];
        board[x][y] = board[y][N - 1 - x];
        board[y][N - 1 - x] = board[N - 1 - x][N - 1 - y];
        board[N - 1 - x][N - 1 - y] = board[N - 1 - y][x];
        board[N - 1 - y][x] = temp;
      }
    }
  }

  void _randomizeDigits() {
    var digits = List(board_size);
    for (var i = 0; i < board_size; i++) {
      digits[i] = i + 1;
    }
    digits = _getRandomizedOrder(digits);
    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        var temp = final_board[i][j];
        final_board[i][j] = digits[temp - 1];
        temp = initial_board[i][j];
        if (temp != 0) {
          initial_board[i][j] = digits[temp - 1];
        }
      }
    }
  }

  List<int> _getRandomizedOrder(List arr) {
    var r = Random();
    var array = List<int>.from(arr);
    for (var i = 0; i < array.length; i++) {
      var random_pos = r.nextInt(array.length);
      var temp = array[i];
      array[i] = array[random_pos];
      array[random_pos] = temp;
    }
    return array;
  }

  List _getNewPosOrder() {
    var indices = List(board_size);
    for (var i = 0; i < board_size; i++) {
      indices[i] = i;
    }

    for (var i = 0; i < cell_size; i++) {
      var new_order = indices.sublist(i * cell_size, i * cell_size + cell_size);
      new_order = _getRandomizedOrder(new_order);
      for (var j = 0; j < cell_size; j++) {
        indices[i * cell_size + j] = new_order[j];
      }
    }
    return indices;
  }

  void _scrambleRows() {
    var indices = _getNewPosOrder();
    var initial_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);
    var final_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);

    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        initial_copy[i][j] = initial_board[indices[i]][j];
        final_copy[i][j] = final_board[indices[i]][j];
      }
    }

    initial_board = _copyTiles(initial_copy);
    final_board = _copyTiles(final_copy);
  }

  void _scrambleCols() {
    var indices = _getNewPosOrder();
    var initial_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);
    var final_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);

    for (var i = 0; i < board_size; i++) {
      for (var j = 0; j < board_size; j++) {
        initial_copy[i][j] = initial_board[i][indices[j]];
        final_copy[i][j] = final_board[i][indices[j]];
      }
    }

    initial_board = _copyTiles(initial_copy);
    final_board = _copyTiles(final_copy);
  }

  static List _copyTiles(List source) {
    var rows = source.length;
    var columns = source[0].length;
    var dest = List(rows);
    for (var r = 0; r < rows; r++) {
      dest[r] = List(columns);
      for (var c = 0; c < columns; c++) {
        dest[r][c] = source[r][c];
      }
    }
    return dest;
  }

  void _scrambleFloors() {
    var indices = _getNewPosOrder().sublist(0, cell_size);
    var initial_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);
    var final_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);
    for (var i = 0; i < cell_size; i++) {
      for (var j = 0; j < board_size; j++) {
        for (var k = 0; k < cell_size; k++) {
          initial_copy[indices[i] * cell_size + k][j] =
              initial_board[i * cell_size + k][j];
          final_copy[indices[i] * cell_size + k][j] =
              final_board[i * cell_size + k][j];
        }
      }
    }

    initial_board = _copyTiles(initial_copy);
    final_board = _copyTiles(final_copy);
  }

  void _scrambleTowers() {
    var indices = _getNewPosOrder().sublist(0, cell_size);
    var initial_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);
    var final_copy =
        List.generate(board_size, (i) => List(board_size), growable: false);
    for (var i = 0; i < cell_size; i++) {
      for (var j = 0; j < board_size; j++) {
        for (var k = 0; k < cell_size; k++) {
          initial_copy[j][indices[i] * cell_size + k] =
              initial_board[j][i * cell_size + k];
          final_copy[j][indices[i] * cell_size + k] =
              final_board[j][i * cell_size + k];
        }
      }
    }

    initial_board = _copyTiles(initial_copy);
    final_board = _copyTiles(final_copy);
  }

  int _getRandom(int max) {
    var random = Random();
    return random.nextInt(max);
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write(_boardToString(final_board));
    buffer.write('\n');
    buffer.write(_boardToString(initial_board));
    return buffer.toString();
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
}

void main(List<String> arguments) {
  var sudoku = Sudoku.withMoreHints(0);
  print(sudoku.toString());
}
