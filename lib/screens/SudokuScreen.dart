import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:lettuce_sudoku/framework/problem/Problem.dart';
import 'package:lettuce_sudoku/framework/problem/SolvingAssistant.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'package:lettuce_sudoku/util/globals.dart' as globals;
import 'package:lettuce_sudoku/widgets/widgets.dart';

class SudokuScreen extends StatefulWidget {
  SudokuScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  var menuHeight = 70;
  SolvingAssistant _assistant;
  FocusNode focusNode = FocusNode();
  var _actionMap;
  var _correctnessRadio;
  var _legalityRadio;

  Widget _moveButtons;
  Widget _gameButtons;
  List<Widget> sudokuGrid = [];

  @override
  void initState() {
    super.initState();
    if (globals.problem == null) {
      _newGameAndSave();
    }
    _moveButtons = _getMoveButtons();
    _gameButtons = _getGameButtons();
    _assistant = SolvingAssistant(globals.problem);
    _populateGridList();
    _actionMap = {
      // Move Down
      LogicalKeyboardKey.arrowDown: () => _shiftFocus(1, 0),
      LogicalKeyboardKey.keyS: () => _shiftFocus(1, 0),

      // Move Left
      LogicalKeyboardKey.arrowLeft: () => _shiftFocus(0, -1),
      LogicalKeyboardKey.keyA: () => _shiftFocus(0, -1),

      // Move Right
      LogicalKeyboardKey.arrowRight: () => _shiftFocus(0, 1),
      LogicalKeyboardKey.keyD: () => _shiftFocus(0, 1),

      // Move Up
      LogicalKeyboardKey.arrowUp: () => _shiftFocus(-1, 0),
      LogicalKeyboardKey.keyW: () => _shiftFocus(-1, 0),

      // Place 0 / Delete number from cell
      LogicalKeyboardKey.digit0: () =>
          _doMoveAndApply(0, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad0: () =>
          _doMoveAndApply(0, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.keyX: () =>
          _doMoveAndApply(0, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.delete: () =>
          _doMoveAndApply(0, globals.selectedRow, globals.selectedCol),

      // Place 1
      LogicalKeyboardKey.digit1: () =>
          _doMoveAndApply(1, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad1: () =>
          _doMoveAndApply(1, globals.selectedRow, globals.selectedCol),

      // Place 2
      LogicalKeyboardKey.digit2: () =>
          _doMoveAndApply(2, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad2: () =>
          _doMoveAndApply(2, globals.selectedRow, globals.selectedCol),

      // Place 3
      LogicalKeyboardKey.digit3: () =>
          _doMoveAndApply(3, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad3: () =>
          _doMoveAndApply(3, globals.selectedRow, globals.selectedCol),

      // Place 4
      LogicalKeyboardKey.digit4: () =>
          _doMoveAndApply(4, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad4: () =>
          _doMoveAndApply(4, globals.selectedRow, globals.selectedCol),

      // Place 5
      LogicalKeyboardKey.digit5: () =>
          _doMoveAndApply(5, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad5: () =>
          _doMoveAndApply(5, globals.selectedRow, globals.selectedCol),

      // Place 6
      LogicalKeyboardKey.digit6: () =>
          _doMoveAndApply(6, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad6: () =>
          _doMoveAndApply(6, globals.selectedRow, globals.selectedCol),

      // Place 7
      LogicalKeyboardKey.digit7: () =>
          _doMoveAndApply(7, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad7: () =>
          _doMoveAndApply(7, globals.selectedRow, globals.selectedCol),

      // Place 8
      LogicalKeyboardKey.digit8: () =>
          _doMoveAndApply(8, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad8: () =>
          _doMoveAndApply(8, globals.selectedRow, globals.selectedCol),

      // Place 9
      LogicalKeyboardKey.digit9: () =>
          _doMoveAndApply(9, globals.selectedRow, globals.selectedCol),
      LogicalKeyboardKey.numpad9: () =>
          _doMoveAndApply(9, globals.selectedRow, globals.selectedCol),

      // Get Hint
      LogicalKeyboardKey.keyH: () =>
          _giveHintAndApply(globals.selectedRow, globals.selectedCol),
    };
  }

  void _shiftFocus(int rowOffset, int colOffset) {
    if (_cellSelected()) {
      setState(() {
        var currentState = globals.problem.getCurrentState() as SudokuState;
        var currentBoard = currentState.getTiles();
        var num = currentBoard[globals.selectedRow][globals.selectedCol];
        _whiteoutBoard(num, globals.selectedRow, globals.selectedCol);
        globals.selectedRow =
            ((globals.selectedRow + rowOffset) % globals.problem.board_size);
        globals.selectedCol =
            ((globals.selectedCol + colOffset) % globals.problem.board_size);
        _updateCells(globals.selectedRow, globals.selectedCol);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  'Settings',
                  style: CustomStyles.titleText,
                ),
              ),
              decoration: BoxDecoration(
                color: CustomStyles.nord3,
              ),
            ),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Highlight Peer Cells',
                            style: TextStyle(
                              color: CustomStyles.nord3,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Switch(
                            value: globals.doPeerCells.value,
                            onChanged: (bool value) {
                              _toggleBoolWrapper(globals.doPeerCells);
                              _populateGridList();
                            },
                            activeColor: CustomStyles.nord3,
                            inactiveThumbColor: CustomStyles.nord3,
                            activeTrackColor: CustomStyles.nord14,
                            inactiveTrackColor: CustomStyles.nord15,
                          ),
                        ],
                      ),
                      // _doPeerCellsToggle,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Highlight Peer Digits',
                            style: TextStyle(
                              color: CustomStyles.nord3,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Switch(
                            value: globals.doPeerDigits.value,
                            onChanged: (bool value) {
                              _toggleBoolWrapper(globals.doPeerDigits);
                              _populateGridList();
                            },
                            activeColor: CustomStyles.nord3,
                            inactiveThumbColor: CustomStyles.nord3,
                            activeTrackColor: CustomStyles.nord14,
                            inactiveTrackColor: CustomStyles.nord15,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Show Mistakes',
                            style: TextStyle(
                              color: CustomStyles.nord3,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Switch(
                            value: globals.doMistakes.value,
                            onChanged: (bool value) {
                              _toggleBoolWrapper(globals.doMistakes);
                              _populateGridList();
                            },
                            activeColor: CustomStyles.nord3,
                            inactiveThumbColor: CustomStyles.nord3,
                            activeTrackColor: CustomStyles.nord14,
                            inactiveTrackColor: CustomStyles.nord15,
                          ),
                        ],
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) =>
                                SizeTransition(
                          child: child,
                          sizeFactor: animation,
                        ),
                        child: globals.doMistakes.value
                            ? Column(
                                children: [
                                  getStyledRadio(
                                      _correctnessRadio,
                                      'Correctness',
                                      0,
                                      globals.legalityRadio, (var val) {
                                    _setIntWrapper(0, globals.legalityRadio);
                                    _populateGridList();
                                  }),
                                  getStyledRadio(_legalityRadio, 'Legality', 1,
                                      globals.legalityRadio, (var val) {
                                    _setIntWrapper(1, globals.legalityRadio);
                                    _populateGridList();
                                  }),
                                ],
                              )
                            : Container(),
                      ),
                      const Text(
                        'Initial Hints',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: CustomStyles.nord3,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: globals.initialHints.value.toDouble(),
                    onChanged: (double val) =>
                        _setIntWrapper(val.toInt(), globals.initialHints),
                    min: 17,
                    max: 50,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove, color: CustomStyles.nord3),
                  onPressed: () => _setIntWrapper(
                      globals.initialHints.value - 1, globals.initialHints),
                ),
                Text(globals.initialHints.value.toString()),
                IconButton(
                    icon: Icon(Icons.add, color: CustomStyles.nord3),
                    onPressed: () => _setIntWrapper(
                        globals.initialHints.value + 1, globals.initialHints))
              ],
            ),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 33,
                  child: AspectRatio(
                    aspectRatio: 3,
                    child: Container(
                      height: 120,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 2, 2),
                                      child: FlatButton(
                                        color: CustomStyles.nord3,
                                        splashColor: CustomStyles.nord0,
                                        onPressed: () => _solveGameAndApply(),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0)),
                                        child: AutoSizeText(
                                          'Solve game',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: CustomStyles.nord6,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(2, 0, 0, 2),
                                      child: FlatButton(
                                        color: CustomStyles.nord3,
                                        splashColor: CustomStyles.nord0,
                                        onPressed: () => _resetBoard(problem),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0)),
                                        child: AutoSizeText(
                                          'Reset Game',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: CustomStyles.nord6,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      padding: EdgeInsets.only(top: 2),
                                      child: FlatButton(
                                        color: CustomStyles.nord3,
                                        splashColor: CustomStyles.nord0,
                                        onPressed: () => _newGameAndSave(),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0)),
                                        child: AutoSizeText(
                                          'New Game',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: CustomStyles.nord6,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: focusNode,
        onKey: (event) {
          if (event.runtimeType == RawKeyDownEvent) {
            Function action = _actionMap[event.data.logicalKey];
            if (action != null) {
              action();
            }
          }
        },
        child: _getBody(),
      ),
    );
  }

  void _newGame() {
    setState(() {
      globals.problem =
          SudokuProblem.withMoreHints(globals.initialHints.value - 17);
      _assistant = SolvingAssistant(globals.problem);
      _resetGlobals();
      _populateGridList();
    });
  }

  void _newGameAndSave() {
    _newGame();
    saveGame();
  }

  void _resetGlobals() {
    globals.selectedRow = -1;
    globals.selectedCol = -1;
    globals.hintsGiven.clear();
  }

  void _resetBoard(Problem problem) {
    setState(() {
      problem.setCurrentState(problem.getInitialState());
      _resetGlobals();
      _populateGridList();
    });
  }

  EdgeInsets _getBoardPadding(int index) {
    var row = index ~/ globals.problem.board_size;
    var col = index % globals.problem.board_size;
    var thickness = 2;
    var defaultThickness = 0.5;
    var isTop = row == 0;
    var isLeft = col == 0;
    var isBottom =
        row % globals.problem.cell_size == globals.problem.cell_size - 1;
    var isRight =
        col % globals.problem.cell_size == globals.problem.cell_size - 1;
    var top = isTop ? thickness : defaultThickness;
    var left = isLeft ? thickness : defaultThickness;
    var bottom = isBottom ? thickness : defaultThickness;
    var right = isRight ? thickness : defaultThickness;

    return EdgeInsets.fromLTRB(
        left.toDouble(), top.toDouble(), right.toDouble(), bottom.toDouble());
  }

  bool _givenAsHint(int row, int col) {
    bool hint = false;
    for (List pair in globals.hintsGiven) {
      if (pair[0] == row && pair[1] == col) {
        hint = true;
        break;
      }
    }
    return hint;
  }

  void _giveHint(int row, int col) {
    var validRow = row > -1 && row < 10;
    var validCol = col > -1 && col < 10;
    var validCell = validRow && validCol;
    if (!globals.problem.success() && validCell) {
      SudokuState finalState = globals.problem.getFinalState();
      List finalBoard = finalState.getTiles();
      var num = finalBoard[row][col];
      if (!globals.problem.isCorrect(row, col)) {
        globals.hintsGiven.add([row, col]);
        _doMove(num, row, col);
      }
    }
  }

  void _giveHintAndApply(int row, int col) {
    setState(() {
      _giveHint(row, col);
      saveGame();
      _updateCells(row, col);
    });
  }

  void _doMove(int num, int row, int col) {
    var currentState = globals.problem.getCurrentState() as SudokuState;
    var currentBoard = currentState.getTiles();
    if (!problem.success() && _cellSelected()) {
      SudokuState initialState = globals.problem.getInitialState();
      var initialBoard = initialState.getTiles();
      var notInitialHint = initialBoard[row][col] == 0;
      if (!globals.problem.success() && notInitialHint) {
        var move = 'Place ' +
            num.toString() +
            ' at ' +
            row.toString() +
            ' ' +
            col.toString();
        print('doMove: ' + move);
        _whiteoutBoard(currentBoard[globals.selectedRow][globals.selectedCol],
            globals.selectedRow, globals.selectedCol);

        _assistant.tryMove(move);
        var changeIndex =
            row * globals.problem.board_size + col % globals.problem.board_size;
        sudokuGrid[changeIndex] =
            _makeBoardButton(changeIndex, _getCellColor(row, col));
      }
    }
  }

  void _doMoveAndApply(int num, int row, int col) {
    setState(() {
      _doMove(num, row, col);
      saveGame();
      _updateCells(row, col);
    });
  }

  void _solveGame() {
    globals.selectedRow = 0;
    globals.selectedCol = 0;
    int boardSize = problem.board_size;
    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        _giveHint(i, j);
      }
    }
  }

  void _solveGameAndApply() {
    setState(() {
      _solveGame();
      _populateGridList();
      saveGame();
    });
  }

  bool _cellSelected() {
    return globals.selectedRow != -1 && globals.selectedCol != -1;
  }

  Color _getCellColor(int row, int col) {
    Color peerCell = CustomStyles.nord8;
    Color background = CustomStyles.nord6;
    Color peerDigit = CustomStyles.nord9;
    Color success = CustomStyles.nord14;
    Color color = background;

    bool rowSelected = row == globals.selectedRow;
    bool colSelected = col == globals.selectedCol;
    bool floorSelected = row ~/ globals.problem.cell_size ==
        globals.selectedRow ~/ globals.problem.cell_size;
    bool towerSelected = col ~/ globals.problem.cell_size ==
        globals.selectedCol ~/ globals.problem.cell_size;
    bool cells = globals.doPeerCells.value;
    bool digits = globals.doPeerDigits.value;
    SudokuState currentState = globals.problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    bool sameDigit = _cellSelected() &&
        currentBoard[row][col] ==
            currentBoard[globals.selectedRow][globals.selectedCol];
    bool nonZero = _cellSelected() && currentBoard[row][col] != 0;

    color = rowSelected && colSelected ? peerDigit : color;
    color = cells &&
            _cellSelected() &&
            (rowSelected || colSelected || (floorSelected && towerSelected))
        ? peerCell
        : color;
    color = digits &&
            _cellSelected() &&
            ((sameDigit && nonZero) ||
                (sameDigit && rowSelected && colSelected))
        ? peerDigit
        : color;
    color = cells && rowSelected && colSelected ? background : color;
    color = globals.problem.success() ? success : color;

    return color;
  }

  Widget _makeBoardButton(int index, Color color) {
    var row = index ~/ globals.problem.board_size;
    var col = index % globals.problem.board_size;
    SudokuState currentState = globals.problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();
    Container button = Container(
      padding: _getBoardPadding(index),
      child: Material(
        color: color,
        child: InkWell(
          hoverColor: CustomStyles.nord13,
          splashColor: CustomStyles.nord12,
          onTap: () => setState(() {
            if (_cellSelected()) {
              _whiteoutBoard(
                  currentBoard[globals.selectedRow][globals.selectedCol],
                  globals.selectedRow,
                  globals.selectedCol);
            }
            globals.selectedRow = row;
            globals.selectedCol = col;
            _updateCells(globals.selectedRow, globals.selectedCol);
          }),
          child: Center(
            child: AutoSizeText(
              toPlace,
              textAlign: TextAlign.center,
              maxLines: 1,
              stepGranularity: 1,
              minFontSize: 1,
              maxFontSize: 40,
              style: TextStyle(
                color: _getTextColor(row, col),
                fontSize: 40,
              ),
            ),
          ),
        ),
      ),
    );
    return button;
  }

  void _updateCells(int row, int col) {
    if (!problem.success()) {
      if (globals.doPeerCells.value) {
        for (var i = 0; i < globals.problem.board_size; i++) {
          var rowIndex = _getIndex(row, i);
          sudokuGrid[rowIndex] =
              _makeBoardButton(rowIndex, _getCellColor(row, i));

          var colIndex = _getIndex(i, col);
          sudokuGrid[colIndex] =
              _makeBoardButton(colIndex, _getCellColor(i, col));

          var blockRow =
              row ~/ globals.problem.cell_size * globals.problem.cell_size;
          var blockCol =
              col ~/ globals.problem.cell_size * globals.problem.cell_size;
          var blockIndex = _getIndex(blockRow + i ~/ globals.problem.cell_size,
              blockCol + i % globals.problem.cell_size);
          sudokuGrid[blockIndex] = _makeBoardButton(
              blockIndex,
              _getCellColor(blockRow + i ~/ globals.problem.cell_size,
                  blockCol + i % globals.problem.cell_size));
        }
      }
      if (globals.doPeerDigits.value) {
        var currentState = globals.problem.getCurrentState() as SudokuState;
        var currentBoard = currentState.getTiles();
        var num = currentState.getTiles()[row][col];
        for (var i = 0; i < globals.problem.board_size; i++) {
          for (var j = 0; j < globals.problem.board_size; j++) {
            if (currentBoard[i][j] == num) {
              var k = _getIndex(i, j);
              ;
              sudokuGrid[k] = _makeBoardButton(k, _getCellColor(i, j));
            }
          }
        }
      }
      var index = _getIndex(row, col);
      sudokuGrid[index] = _makeBoardButton(index, _getCellColor(row, col));
    } else {
      _populateGridList();
    }
  }

  void _whiteoutBoard(int num, int row, int col) {
    var currentState = globals.problem.getCurrentState() as SudokuState;
    var currentBoard = currentState.getTiles();
    for (var i = 0; i < globals.problem.board_size; i++) {
      for (var j = 0; j < globals.problem.board_size; j++) {
        var sameRow = i == row;
        var sameCol = j == col;
        var sameFloor =
            i ~/ globals.problem.cell_size == row ~/ globals.problem.cell_size;
        var sameTower =
            j ~/ globals.problem.cell_size == col ~/ globals.problem.cell_size;
        var sameBlock = sameFloor && sameTower;
        if (sameRow || sameCol || sameBlock || num == currentBoard[i][j]) {
          var index = _getIndex(i, j);
          sudokuGrid[index] = _makeBoardButton(index, CustomStyles.nord6);
        }
      }
    }
  }

  int _getIndex(int row, int col) {
    return row * globals.problem.board_size + col % globals.problem.board_size;
  }

  void _toggleBoolWrapper(VariableWrapper setting) {
    setState(() {
      setting.value = !setting.value;
      saveToPrefs();
    });
  }

  void _setIntWrapper(int value, VariableWrapper setting) {
    setState(() {
      setting.value = value;
      saveToPrefs();
    });
  }

  void _populateGridList() {
    sudokuGrid = List.generate(
        globals.problem.board_size * globals.problem.board_size, (index) {
      return _makeBoardButton(
          index,
          _getCellColor(index ~/ globals.problem.board_size,
              index % globals.problem.board_size));
    });
  }

  Widget _getMoveButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            children: List.generate(2, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (colIndex) {
                  int offset = rowIndex * 5;
                  int num = (colIndex + 1 + offset) %
                      (globals.problem.board_size + 1);
                  String toPlace = num == 0 ? 'X' : (num).toString();
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.all(2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: getFlatButton(
                          toPlace,
                          CustomStyles.nord6,
                          36,
                          TextAlign.center,
                          CustomStyles.nord3,
                          CustomStyles.nord0,
                          () {
                            _doMoveAndApply(
                                num, globals.selectedRow, globals.selectedCol);
                          },
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  Color _getTextColor(int row, int col) {
    SudokuState initialState = globals.problem.getInitialState();
    var initialBoard = initialState.getTiles();
    var initialHint = initialBoard[row][col] != 0;
    var legal = globals.problem.isLegal(row, col);
    var correct = globals.problem.isCorrect(row, col);
    var doLegality = globals.legalityRadio.value == 1;
    Color color = CustomStyles.nord10;

    color = globals.doMistakes.value && doLegality && !legal
        ? CustomStyles.nord11
        : color;
    color = globals.doMistakes.value && !doLegality && !correct
        ? CustomStyles.nord11
        : color;
    color = initialHint ? CustomStyles.nord3 : color;
    color = _givenAsHint(row, col) ? CustomStyles.nord15 : color;
    return color;
  }

  Widget _getGameButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(2),
              child: getFlatButton(
                'New Game',
                CustomStyles.nord6,
                24,
                TextAlign.center,
                CustomStyles.nord3,
                CustomStyles.nord0,
                () {
                  _newGameAndSave();
                },
              ),
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(2),
              child: getFlatButton(
                'Get Hint',
                CustomStyles.nord6,
                24,
                TextAlign.center,
                CustomStyles.nord3,
                CustomStyles.nord0,
                () {
                  _giveHintAndApply(globals.selectedRow, globals.selectedCol);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getBody() {
    return Container(
      padding: EdgeInsets.all(globals.bodySpacing),
      child: _makeBodyRow(context),
    );
  }

  Widget _makeGameCol(bool doVertical) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          flex: 15,
          child: Container(
            padding: EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: CustomStyles.nord3,
                child: GridView.builder(
                  itemCount: sudokuGrid.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: globals.problem.board_size),
                  itemBuilder: (BuildContext context, int index) =>
                      sudokuGrid[index],
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 6,
          child: AspectRatio(
              aspectRatio: 5 / 2, child: Container(child: _moveButtons)),
        ),
        Flexible(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 15 / 2,
            child: Container(
              child: _gameButtons,
            ),
          ),
        ),
      ],
    );
  }

  Widget _makeBodyRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Container()),
        Container(
          width: getBodyWidth(context),
          child: _makeGameCol(true),
        ),
        Flexible(child: Container()),
      ],
    );
  }
}
