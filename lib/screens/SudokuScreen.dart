import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuProblem.dart';
import 'package:lettuce_sudoku/domains/sudoku/SudokuState.dart';
import 'package:lettuce_sudoku/framework/problem/Problem.dart';
import 'package:lettuce_sudoku/framework/problem/SolvingAssistant.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'package:lettuce_sudoku/widgets/widgets.dart';

class SudokuScreen extends StatefulWidget {
  SudokuScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  SolvingAssistant _assistant;
  FocusNode focusNode = FocusNode();
  var _actionMap;

  List<Widget> _sudokuGrid = List(81);
  List<Widget> _moveGrid = List(10);

  @override
  void initState() {
    super.initState();
    if (problem == null) {
      _newGameAndSave();
    }
    _assistant = SolvingAssistant(problem);
    _populateGridList();
    _populateMoveGrid();
    _actionMap = {
      // Move Down
      LogicalKeyboardKey.arrowDown: () {
        _shiftFocus(1, 0);
      },
      LogicalKeyboardKey.keyS: () {
        _shiftFocus(1, 0);
      },

      // Move Left
      LogicalKeyboardKey.arrowLeft: () {
        _shiftFocus(0, -1);
      },
      LogicalKeyboardKey.keyA: () {
        _shiftFocus(0, -1);
      },

      // Move Right
      LogicalKeyboardKey.arrowRight: () {
        _shiftFocus(0, 1);
      },
      LogicalKeyboardKey.keyD: () {
        _shiftFocus(0, 1);
      },

      // Move Up
      LogicalKeyboardKey.arrowUp: () {
        _shiftFocus(-1, 0);
      },
      LogicalKeyboardKey.keyW: () {
        _shiftFocus(-1, 0);
      },

      // Place 0 / Delete number from cell
      LogicalKeyboardKey.digit0: () =>
          _doMoveAndApply(0, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad0: () =>
          _doMoveAndApply(0, selectedRow, selectedCol),
      LogicalKeyboardKey.keyX: () =>
          _doMoveAndApply(0, selectedRow, selectedCol),
      LogicalKeyboardKey.delete: () =>
          _doMoveAndApply(0, selectedRow, selectedCol),

      // Place 1
      LogicalKeyboardKey.digit1: () =>
          _doMoveAndApply(1, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad1: () =>
          _doMoveAndApply(1, selectedRow, selectedCol),

      // Place 2
      LogicalKeyboardKey.digit2: () =>
          _doMoveAndApply(2, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad2: () =>
          _doMoveAndApply(2, selectedRow, selectedCol),

      // Place 3
      LogicalKeyboardKey.digit3: () =>
          _doMoveAndApply(3, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad3: () =>
          _doMoveAndApply(3, selectedRow, selectedCol),

      // Place 4
      LogicalKeyboardKey.digit4: () =>
          _doMoveAndApply(4, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad4: () =>
          _doMoveAndApply(4, selectedRow, selectedCol),

      // Place 5
      LogicalKeyboardKey.digit5: () =>
          _doMoveAndApply(5, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad5: () =>
          _doMoveAndApply(5, selectedRow, selectedCol),

      // Place 6
      LogicalKeyboardKey.digit6: () =>
          _doMoveAndApply(6, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad6: () =>
          _doMoveAndApply(6, selectedRow, selectedCol),

      // Place 7
      LogicalKeyboardKey.digit7: () =>
          _doMoveAndApply(7, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad7: () =>
          _doMoveAndApply(7, selectedRow, selectedCol),

      // Place 8
      LogicalKeyboardKey.digit8: () =>
          _doMoveAndApply(8, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad8: () =>
          _doMoveAndApply(8, selectedRow, selectedCol),

      // Place 9
      LogicalKeyboardKey.digit9: () =>
          _doMoveAndApply(9, selectedRow, selectedCol),
      LogicalKeyboardKey.numpad9: () =>
          _doMoveAndApply(9, selectedRow, selectedCol),

      // Get Hint
      LogicalKeyboardKey.keyH: () =>
          _doMoveAndApply(10, selectedRow, selectedCol),
    };
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);

    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'LettuceSudoku',
          textAlign: TextAlign.center,
          style: CustomStyles.titleText,
        ),
        brightness: Brightness.dark,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
            Container(
              height: 130,
              child: const DrawerHeader(
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
            ),
            Row(
              children: [
                Container(width: 4),
                Expanded(
                  flex: 33,
                  child: Column(
                    children: [
                      Material(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              doPeerCells.value = !doPeerCells.value;
                            });
                            _populateGridList();
                          },
                          child: Row(
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
                                value: doPeerCells.value,
                                onChanged: (bool value) {
                                  setState(() {
                                    doPeerCells.value = value;
                                  });
                                  _populateGridList();
                                },
                                activeColor: CustomStyles.nord3,
                                inactiveThumbColor: CustomStyles.nord3,
                                activeTrackColor: CustomStyles.nord14,
                                inactiveTrackColor: CustomStyles.nord15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              doPeerDigits.value = !doPeerDigits.value;
                            });
                            _populateGridList();
                          },
                          child: Row(
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
                                value: doPeerDigits.value,
                                onChanged: (bool value) {
                                  setState(() {
                                    doPeerDigits.value = value;
                                  });
                                  _populateGridList();
                                },
                                activeColor: CustomStyles.nord3,
                                inactiveThumbColor: CustomStyles.nord3,
                                activeTrackColor: CustomStyles.nord14,
                                inactiveTrackColor: CustomStyles.nord15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Material(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              doMistakes.value = !doMistakes.value;
                            });
                            _populateGridList();
                          },
                          child: Row(
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
                                value: doMistakes.value,
                                onChanged: (bool value) {
                                  setState(() {
                                    doMistakes.value = value;
                                  });
                                  _populateGridList();
                                },
                                activeColor: CustomStyles.nord3,
                                inactiveThumbColor: CustomStyles.nord3,
                                activeTrackColor: CustomStyles.nord14,
                                inactiveTrackColor: CustomStyles.nord15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      LettuceRadio(
                        label: 'Correctness',
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        value: 0,
                        groupValue: legalityRadio.value,
                        onChanged: (int value) {
                          setState(() {
                            legalityRadio.value = value;
                          });
                          _populateGridList();
                        },
                      ),
                      LettuceRadio(
                        label: 'Legality',
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        value: 1,
                        groupValue: legalityRadio.value,
                        onChanged: (int value) {
                          setState(() {
                            legalityRadio.value = value;
                          });
                          _populateGridList();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selection Order',
                            style: TextStyle(
                              color: CustomStyles.nord3,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Visibility(
                            visible: false,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Switch(
                              value: doMistakes.value,
                              onChanged: null,
                            ),
                          ),
                        ],
                      ),
                      LettuceRadio(
                        label: 'Cell First',
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        value: 0,
                        groupValue: selectionRadio.value,
                        onChanged: (int value) {
                          setState(
                            () {
                              selectionRadio.value = value;
                            },
                          );
                        },
                      ),
                      LettuceRadio(
                        label: 'Number First',
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        value: 1,
                        groupValue: selectionRadio.value,
                        onChanged: (int value) {
                          setState(
                            () {
                              selectionRadio.value = value;
                            },
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Initial Hints',
                            style: TextStyle(
                              color: CustomStyles.nord3,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Visibility(
                            visible: false,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Switch(
                              value: doMistakes.value,
                              onChanged: null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: initialHints.value.toDouble(),
                              onChanged: (double val) {
                                setState(
                                  () {
                                    initialHints.value = val.toInt();
                                  },
                                );
                              },
                              min: 17,
                              max: 50,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) =>
                                    ScaleTransition(
                              child: child,
                              scale: animation,
                            ),
                            child: initialHints.value > 17
                                ? IconButton(
                                    key: ValueKey(0),
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: CustomStyles.nord11,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          initialHints.value -= 1;
                                        },
                                      );
                                    },
                                  )
                                : IconButton(
                                    key: ValueKey(1),
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: CustomStyles.nord6,
                                    ),
                                    onPressed: () {},
                                  ),
                          ),
                          Text(initialHints.value.toString()),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) =>
                                    ScaleTransition(
                              child: child,
                              scale: animation,
                            ),
                            child: initialHints.value < 50
                                ? IconButton(
                                    key: ValueKey(0),
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: CustomStyles.nord14,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          initialHints.value += 1;
                                        },
                                      );
                                    },
                                  )
                                : IconButton(
                                    key: ValueKey(1),
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: CustomStyles.nord6,
                                    ),
                                    onPressed: () {},
                                  ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 3,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 2, 2),
                                child: LettuceButton(
                                  buttonColor: CustomStyles.nord3,
                                  hoverColor: CustomStyles.nord2,
                                  highlightColor: CustomStyles.nord1,
                                  splashColor: CustomStyles.nord0,
                                  label: 'Solve Game',
                                  textColor: CustomStyles.nord6,
                                  textSize: 24,
                                  onTap: () {
                                    _solveGameAndApply();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 3,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(2, 0, 0, 2),
                                child: LettuceButton(
                                  buttonColor: CustomStyles.nord3,
                                  hoverColor: CustomStyles.nord2,
                                  highlightColor: CustomStyles.nord1,
                                  splashColor: CustomStyles.nord0,
                                  label: 'Reset Game',
                                  textColor: CustomStyles.nord6,
                                  textSize: 24,
                                  onTap: () {
                                    _resetBoard(problem);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AspectRatio(
                        aspectRatio: 6,
                        child: Container(
                          padding: EdgeInsets.only(top: 2),
                          child: LettuceButton(
                            buttonColor: CustomStyles.nord3,
                            hoverColor: CustomStyles.nord2,
                            highlightColor: CustomStyles.nord1,
                            splashColor: CustomStyles.nord0,
                            label: 'New Game',
                            textColor: CustomStyles.nord6,
                            textSize: 24,
                            onTap: () {
                              _newGameAndSave();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 4),
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
        child: Container(
          padding: EdgeInsets.all(bodySpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Container()),
              Container(
                width: getBodyWidth(context),
                child: Column(
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
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _sudokuGrid.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: problem.board_size),
                              itemBuilder: (BuildContext context, int index) =>
                                  _sudokuGrid[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      child: AspectRatio(
                        aspectRatio: 5 / 2,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: GridView.builder(
                            itemCount: _moveGrid.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4),
                            itemBuilder: (BuildContext context, int index) =>
                                _moveGrid[index],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: AspectRatio(
                        aspectRatio: 5,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 3,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    child: LettuceButton(
                                      label: 'New Game',
                                      textColor: CustomStyles.nord6,
                                      textSize: 24,
                                      textAlign: TextAlign.center,
                                      buttonColor: CustomStyles.nord3,
                                      hoverColor: CustomStyles.nord2,
                                      highlightColor: CustomStyles.nord1,
                                      splashColor: CustomStyles.nord0,
                                      onTap: () {
                                        _newGameAndSave();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    child: LettuceIconButton(
                                      icon: Icons.search_sharp,
                                      iconColor: CustomStyles.nord6,
                                      iconSize: 24,
                                      textAlign: TextAlign.center,
                                      buttonColor: CustomStyles.nord3,
                                      hoverColor: CustomStyles.nord2,
                                      highlightColor: CustomStyles.nord1,
                                      splashColor: CustomStyles.nord0,
                                      onTap: () {
                                        if (selectionRadio.value == 1) {
                                          selectedNum = 10;
                                        } else {
                                          _doMoveAndApply(
                                              10, selectedRow, selectedCol);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    child: LettuceIconButton(
                                      icon: Icons.undo_sharp,
                                      iconColor: CustomStyles.nord6,
                                      iconSize: 30,
                                      textAlign: TextAlign.center,
                                      buttonColor: CustomStyles.nord3,
                                      hoverColor: CustomStyles.nord2,
                                      highlightColor: CustomStyles.nord1,
                                      splashColor: CustomStyles.nord0,
                                      onTap: () {
                                        _undoMove();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(child: Container()),
            ],
          ),
        ),
      ),
    );
  }

  void _shiftFocus(int rowOffset, int colOffset) {
    if (cellSelected()) {
      setState(() {
        var currentState = problem.getCurrentState() as SudokuState;
        var currentBoard = currentState.getTiles();
        var num = currentBoard[selectedRow][selectedCol];
        _whiteoutBoard(num, selectedRow, selectedCol);
        selectedRow = ((selectedRow + rowOffset) % problem.board_size);
        selectedCol = ((selectedCol + colOffset) % problem.board_size);
        if (digitGood(selectedNum) && selectedNum == 1) {
          _doMove(selectedNum, selectedRow, selectedCol);
        }
        _updateCells(selectedRow, selectedCol);
      });
    }
  }

  void _newGame() {
    setState(() {
      problem = SudokuProblem.withMoreHints(initialHints.value - 17);
      _assistant = SolvingAssistant(problem);
      resetGlobals();
      _populateGridList();
    });
  }

  void _newGameAndSave() {
    _newGame();
    saveGame();
  }

  void _resetBoard(Problem problem) {
    setState(() {
      _assistant.reset();
      resetGlobals();
      _populateGridList();
    });
  }

  void _doMove(int num, int row, int col) {
    bool numGood = num > -1 && num < 11;
    if (!_assistant.isProblemSolved() &&
        cellSelected() &&
        numGood &&
        digitGood(num)) {
      SudokuState initialState = problem.getInitialState();
      var initialBoard = initialState.getTiles();

      var notInitialHint = initialBoard[row][col] == 0;
      if (notInitialHint) {
        if (num == 10) {
          SudokuState finalState = problem.getFinalState();
          List finalBoard = finalState.getTiles();
          num = finalBoard[row][col];
          hintsGiven.add([row, col]);
        }
        var move = 'Place ' +
            num.toString() +
            ' at ' +
            row.toString() +
            ' ' +
            col.toString();
        _assistant.tryMove(move);
      }
      var changeIndex = row * problem.board_size + col % problem.board_size;
      _sudokuGrid[changeIndex] =
          _makeBoardButton(changeIndex, getCellColor(row, col));
    }
  }

  void _undoMove() {
    var initialState = problem.initialState as SudokuState;
    var currentState = problem.currentState as SudokuState;
    if (!currentState.equals(initialState) && movesDone.isNotEmpty) {
      Move lastMove = movesDone.removeLast();
      var num = lastMove.oldNum;
      var row = lastMove.row;
      var col = lastMove.col;
      _selectCell(row, col);
      _doMoveAndApply(num, row, col);
      movesDone.removeLast();
    }
  }

  void _doMoveAndApply(int num, int row, int col) {
    var currentState = problem.currentState as SudokuState;
    var currentBoard = currentState.getTiles();
    _doMove(num, row, col);
    movesDone.add(Move(currentBoard[row][col], num, row, col));
    _whiteoutBoard(
        currentBoard[selectedRow][selectedCol], selectedRow, selectedCol);
    saveGame();
    _updateCells(row, col);
    setState(() {});
  }

  void _solveGame() {
    selectedRow = 0;
    selectedCol = 0;
    int boardSize = problem.board_size;
    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        _doMove(10, i, j);
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

  void _whiteoutBoard(int num, int row, int col) {
    var currentState = problem.getCurrentState() as SudokuState;
    var currentBoard = currentState.getTiles();
    for (var i = 0; i < problem.board_size; i++) {
      for (var j = 0; j < problem.board_size; j++) {
        var sameRow = i == row;
        var sameCol = j == col;
        var sameFloor = i ~/ problem.cell_size == row ~/ problem.cell_size;
        var sameTower = j ~/ problem.cell_size == col ~/ problem.cell_size;
        var sameBlock = sameFloor && sameTower;
        var sameNum = num == currentBoard[i][j] && num != 0;
        if (sameRow || sameCol || sameBlock || sameNum) {
          var index = getIndex(i, j, problem.board_size);
          _sudokuGrid[index] = _makeBoardButton(index, CustomStyles.nord6);
        }
      }
    }
  }

  void _populateGridList() {
    _sudokuGrid =
        List.generate(problem.board_size * problem.board_size, (index) {
      return _makeBoardButton(
          index,
          getCellColor(
              index ~/ problem.board_size, index % problem.board_size));
    });
  }

  Widget _makeBoardButton(int index, Color color) {
    var row = index ~/ problem.board_size;
    var col = index % problem.board_size;
    SudokuState currentState = problem.getCurrentState();
    List currentBoard = currentState.getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();
    return Container(
      padding: getBoardPadding(index),
      child: LettuceBoardButton(
        buttonColor: color,
        hoverColor: CustomStyles.nord13,
        highlightColor: CustomStyles.nord13,
        splashColor: CustomStyles.nord12,
        textColor: getTextColor(row, col, problem),
        textSize: 40,
        label: toPlace,
        onTap: () {
          _selectCell(row, col);
        },
      ),
    );
  }

  void _selectCell(int row, int col) {
    var currentState = problem.currentState as SudokuState;
    var currentBoard = currentState.getTiles();
    if (cellSelected()) {
      var num = currentBoard[selectedRow][selectedCol];
      _whiteoutBoard(num, selectedRow, selectedCol);
    }
    selectedRow = row;
    selectedCol = col;
    if (selectionRadio.value == 1 && selectedNum > -1 && selectedNum <= 10) {
      _doMove(selectedNum, row, col);
    }
    _updateCells(selectedRow, selectedCol);
    setState(() {});
  }

  void _updateCells(int row, int col) {
    if (!problem.success()) {
      if (doPeerCells.value) {
        for (var i = 0; i < problem.board_size; i++) {
          var rowIndex = getIndex(row, i, problem.board_size);
          _sudokuGrid[rowIndex] =
              _makeBoardButton(rowIndex, getCellColor(row, i));

          var colIndex = getIndex(i, col, problem.board_size);
          _sudokuGrid[colIndex] =
              _makeBoardButton(colIndex, getCellColor(i, col));

          var blockRow = row ~/ problem.cell_size * problem.cell_size;
          var blockCol = col ~/ problem.cell_size * problem.cell_size;
          var blockIndex = getIndex(blockRow + i ~/ problem.cell_size,
              blockCol + i % problem.cell_size, problem.board_size);
          _sudokuGrid[blockIndex] = _makeBoardButton(
              blockIndex,
              getCellColor(blockRow + i ~/ problem.cell_size,
                  blockCol + i % problem.cell_size));
        }
      }
      if (doPeerDigits.value) {
        var currentState = problem.getCurrentState() as SudokuState;
        var currentBoard = currentState.getTiles();
        var num = currentState.getTiles()[row][col];
        for (var i = 0; i < problem.board_size; i++) {
          for (var j = 0; j < problem.board_size; j++) {
            if (currentBoard[i][j] == num && num != 0) {
              var k = getIndex(i, j, problem.board_size);
              _sudokuGrid[k] = _makeBoardButton(k, getCellColor(i, j));
            }
          }
        }
      }
      var index = getIndex(row, col, problem.board_size);
      _sudokuGrid[index] = _makeBoardButton(index, getCellColor(row, col));
    } else {
      _populateGridList();
    }
  }

  void _populateMoveGrid() {
    _moveGrid = List.generate(
      9,
      (index) {
        int num = (index + 1) % (problem.board_size + 1);
        return LettuceButton(
          buttonColor: CustomStyles.nord3,
          hoverColor: CustomStyles.nord2,
          highlightColor: CustomStyles.nord1,
          splashColor: CustomStyles.nord0,
          textSize: 36,
          textColor: CustomStyles.nord6,
          label: num.toString(),
          onTap: () {
            if (selectionRadio.value == 1) {
              selectedNum = num;
            } else {
              if (cellSelected()) {
                _doMoveAndApply(num, selectedRow, selectedCol);
              }
            }
          },
        );
      },
    );
    _moveGrid.add(LettuceIconButton(
      buttonColor: CustomStyles.nord3,
      hoverColor: CustomStyles.nord2,
      highlightColor: CustomStyles.nord1,
      splashColor: CustomStyles.nord0,
      icon: Icons.clear_sharp,
      iconSize: 36,
      iconColor: CustomStyles.nord6,
      onTap: () {
        if (selectionRadio.value == 1) {
          selectedNum = 0;
        } else {
          if (cellSelected()) {
            _doMoveAndApply(0, selectedRow, selectedCol);
          }
        }
      },
    ));
  }
}
