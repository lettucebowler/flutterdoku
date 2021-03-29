import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lettuce_sudoku/util/CustomStyles.dart';
import 'package:lettuce_sudoku/util/globals.dart';
import 'package:lettuce_sudoku/util/helpers.dart';
import 'package:lettuce_sudoku/widgets/widgets.dart';

class SudokuScreen extends StatefulWidget {
  SudokuScreen({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  FocusNode focusNode = FocusNode();
  late var _actionMap;

  late List<Widget> _sudokuGrid;
  late List<Widget> _moveGrid;
  bool canClickNewGame = true;

  @override
  void initState() {
    super.initState();
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
          'Lettuce Sudoku',
          textAlign: TextAlign.left,
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
                              saveToPrefs();
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
                                    saveToPrefs();
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
                              saveToPrefs();
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
                                    saveToPrefs();
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
                              saveToPrefs();
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
                                    saveToPrefs();
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
                            saveToPrefs();
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
                            saveToPrefs();
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
                              saveToPrefs();
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
                              saveToPrefs();
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
                                    saveToPrefs();
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
                                          saveToPrefs();
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
                                          saveToPrefs();
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
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 0),
                                transitionBuilder: (Widget child,
                                        Animation<double> animation) =>
                                    ScaleTransition(
                                  child: child,
                                  scale: animation,
                                ),
                                child: !problem.success()
                                    ? Container(
                                        key: Key('solve'),
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 2, 2),
                                        child: TextButton(
                                          style: CustomStyles.darkButtonStyle,
                                          child: Center(
                                            child: Text(
                                              'Solve Game',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: CustomStyles.nord6,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            _solveGameAndApply();
                                          },
                                        ),
                                      )
                                    : Container(
                                        key: Key('reset'),
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 2, 2),
                                        child: TextButton(
                                          style: CustomStyles.darkButtonStyle,
                                          child: Center(
                                            child: Text(
                                              'Reset Game',
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: CustomStyles.nord6,
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            _resetBoard();
                                          },
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 3,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(2, 0, 0, 2),
                                child: TextButton(
                                  style: CustomStyles.darkButtonStyle,
                                  child: Center(
                                    child: Text(
                                      'New',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: CustomStyles.nord6,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    _newGameAndSave();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
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
            Function action = _actionMap[event.data.logicalKey] ?? () {};
            action();
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
                                      crossAxisCount: problem.boardSize),
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
                            physics: const NeverScrollableScrollPhysics(),
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
                                    child: TextButton(
                                      style: CustomStyles.darkButtonStyle,
                                      child: Center(
                                        child: Text(
                                          'New Game',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: CustomStyles.nord6,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
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
                                    child: TextButton(
                                      onPressed: () {
                                        if (selectionRadio.value == 1) {
                                          selectedNum = 10;
                                        } else {
                                          _doMoveAndApply(
                                              10, selectedRow, selectedCol);
                                        }
                                      },
                                      style: CustomStyles.darkButtonStyle,
                                      child: Center(
                                        child: Icon(
                                          Icons.search_sharp,
                                          size: 30,
                                          color: CustomStyles.nord6,
                                        ),
                                      ),
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
                                    child: TextButton(
                                      onPressed: () {
                                        _undoMove();
                                      },
                                      style: CustomStyles.darkButtonStyle,
                                      child: Center(
                                        child: Icon(
                                          Icons.undo_sharp,
                                          size: 30,
                                          color: CustomStyles.nord6,
                                        ),
                                      ),
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
      _selectCell((selectedRow + rowOffset) % problem.boardSize,
          (selectedCol + colOffset) % problem.boardSize);
    }
  }

  Future<bool> _newGame() async {
    if (canClickNewGame) {
      canClickNewGame = false;
      problem = await getNextGame();

      setState(
        () {
          _resetBoard();
        },
      );
      canClickNewGame = true;
    }
    return true;
  }

  void _newGameAndSave() async {
    await _newGame();
    saveGame();
  }

  void _resetBoard() {
    setState(() {
      problem.reset();
      resetGlobals();
      _populateGridList();
    });
  }

  void _doMove(int num, int row, int col) {
    bool numGood = num > -1 && num < 11;
    if (!problem.success() && cellSelected() && numGood && digitGood(num)) {
      var initialBoard = problem.getInitialState().getTiles();
      var notInitialHint = initialBoard[row][col] == 0;
      if (notInitialHint) {
        if (num == 10) {
          List finalBoard = problem.getFinalState().getTiles();
          num = finalBoard[row][col];
          hintsGiven.add([row, col]);
        }
        problem.applyMove(num, row, col);
      }
    }
  }

  void _undoMove() {
    if (movesDone.isNotEmpty) {
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
    setState(
      () {
        var currentBoard = problem.getCurrentState().getTiles();
        _doMove(num, row, col);
        movesDone.add(Move(currentBoard[row][col], num, row, col));
        _whiteoutBoard(
            currentBoard[selectedRow][selectedCol], selectedRow, selectedCol);
        saveGame();
        _updateCells(row, col);
      },
    );
  }

  void _solveGameAndApply() {
    setState(
      () {
        problem.solve();
        _populateGridList();
        saveGame();
      },
    );
  }

  void _whiteoutBoard(int num, int row, int col) {
    var currentBoard = problem.getCurrentState().getTiles();
    for (var i = 0; i < problem.boardSize; i++) {
      for (var j = 0; j < problem.boardSize; j++) {
        var sameRow = i == row;
        var sameCol = j == col;
        var sameFloor = i ~/ problem.cellSize == row ~/ problem.cellSize;
        var sameTower = j ~/ problem.cellSize == col ~/ problem.cellSize;
        var sameBlock = sameFloor && sameTower;
        var sameNum = num == currentBoard[i][j] && num != 0;
        if (sameRow || sameCol || sameBlock || sameNum) {
          var index = getIndex(i, j, problem.boardSize);
          _sudokuGrid[index] = _makeBoardButton(index, CustomStyles.nord6);
        }
      }
    }
  }

  void _populateGridList() {
    _sudokuGrid = List.generate(problem.boardSize * problem.boardSize, (index) {
      return _makeBoardButton(index,
          getCellColor(index ~/ problem.boardSize, index % problem.boardSize));
    });
  }

  Widget _makeBoardButton(int index, Color color) {
    var row = index ~/ problem.boardSize;
    var col = index % problem.boardSize;
    var currentBoard = problem.getCurrentState().getTiles();
    var cellNum = currentBoard[row][col];
    String toPlace = cellNum == 0 ? '' : cellNum.toString();
    var splashColor = CustomStyles.nord12;
    var textColor = getTextColor(row, col, problem);
    double textSize = 40;
    var buttonColor = color;
    return Container(
      padding: getBoardPadding(index),
      child: AspectRatio(
        aspectRatio: 1,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0))),
            overlayColor: MaterialStateProperty.all(splashColor),
          ),
          onPressed: () {
            _selectCell(row, col);
          },
          child: Center(
            child: AutoSizeText(
              toPlace,
              textAlign: TextAlign.center,
              maxLines: 1,
              stepGranularity: 1,
              minFontSize: 22,
              maxFontSize: textSize,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectCell(int row, int col) {
    setState(
      () {
        var currentBoard = problem.getCurrentState().getTiles();
        if (cellSelected()) {
          var num = currentBoard[selectedRow][selectedCol];
          _whiteoutBoard(num, selectedRow, selectedCol);
        }
        selectedRow = row;
        selectedCol = col;
        if (selectionRadio.value == 1 &&
            selectedNum > -1 &&
            selectedNum <= 10) {
          _doMove(selectedNum, row, col);
        }
        _updateCells(selectedRow, selectedCol);
      },
    );
  }

  void _updateCells(int row, int col) {
    if (!problem.success()) {
      if (doPeerCells.value) {
        for (var i = 0; i < problem.boardSize; i++) {
          var rowIndex = getIndex(row, i, problem.boardSize);
          _sudokuGrid[rowIndex] =
              _makeBoardButton(rowIndex, getCellColor(row, i));

          var colIndex = getIndex(i, col, problem.boardSize);
          _sudokuGrid[colIndex] =
              _makeBoardButton(colIndex, getCellColor(i, col));

          var blockRow = row ~/ problem.cellSize * problem.cellSize;
          var blockCol = col ~/ problem.cellSize * problem.cellSize;
          var blockIndex = getIndex(blockRow + i ~/ problem.cellSize,
              blockCol + i % problem.cellSize, problem.boardSize);
          _sudokuGrid[blockIndex] = _makeBoardButton(
              blockIndex,
              getCellColor(blockRow + i ~/ problem.cellSize,
                  blockCol + i % problem.cellSize));
        }
      }
      if (doPeerDigits.value) {
        var currentBoard = problem.getCurrentState().getTiles();
        var num = currentBoard[row][col];
        for (var i = 0; i < problem.boardSize; i++) {
          for (var j = 0; j < problem.boardSize; j++) {
            if (currentBoard[i][j] == num && num != 0) {
              var k = getIndex(i, j, problem.boardSize);
              _sudokuGrid[k] = _makeBoardButton(k, getCellColor(i, j));
            }
          }
        }
      }
    } else {
      _populateGridList();
    }
  }

  void _buttonMove(var num) {
    if (selectionRadio.value == 1) {
      selectedNum = num;
    } else {
      _doMoveAndApply(num, selectedRow, selectedCol);
    }
  }

  void _populateMoveGrid() {
    var textColor = CustomStyles.nord6;
    double textSize = 36;
    _moveGrid = List.generate(
      9,
      (index) {
        int num = (index + 1) % (problem.boardSize + 1);
        return TextButton(
          onPressed: () {
            _buttonMove(num);
          },
          style: CustomStyles.darkButtonStyle,
          child: Center(
            child: Text(
              num.toString(),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: textColor,
                fontSize: textSize,
              ),
            ),
          ),
        );
      },
    );
    _moveGrid.add(TextButton(
      onPressed: () {
        _buttonMove(0);
      },
      style: CustomStyles.darkButtonStyle,
      child: Center(
        child: Icon(
          Icons.clear_sharp,
          size: textSize,
          color: textColor,
        ),
      ),
    ));
  }
}
